#!/usr/bin/env python3
"""Generate DBML from solardev_attributes.csv and solardev_relationships.csv."""

import csv
from pathlib import Path
from collections import defaultdict

SCHEMA_DIR = Path(__file__).resolve().parent
TABLES_CSV = SCHEMA_DIR / "solardev_tables.csv"
ATTRIBUTES_CSV = SCHEMA_DIR / "solardev_attributes.csv"
RELATIONSHIPS_CSV = SCHEMA_DIR / "solardev_relationships.csv"
OUTPUT_DBML = SCHEMA_DIR / "solardev_schema.dbml"

# Our tables (from solardev_tables LogicalName) - fallback when CSV empty
# Πλήρης λίστα 26+ tables από solardev (Φεβ 2025)
OUR_TABLES = {
    "solar_solarcountry", "solar_location", "solar_maintenance_team",
    "solar_solarassetcategory", "solar_solarpreventivetask", "account",
    "solar_solarpreventiveplan", "solar_corrective_work_order",
    "solar_corrective_category", "solar_task", "solar_notification",
    "new_account", "solar_solarpreventiveplancategory", "solar_solarmodule",
    "solar_solarpreventivetaskcategory", "solar_solarinverter",
    # Νέοι πίνακες από solardev
    "solar_clients", "solar_country", "solar_maintenanceteamcategory",
    "solar_maintenanceteammember", "solar_maintenanceteamperlocation",
    "solar_section", "solar_sitecredentials", "solar_sitecomments",
    "solar_equipmentwarehouse", "solar_inverter", "solar_module", "contact",
}

def _clean(s: str) -> str:
    return s.strip().strip('"') if s else ""

def _bool(s: str) -> bool:
    return _clean(s).lower() == "true"

def type_to_dbml(attr_type: str, max_len: str, precision: str, scale: str) -> str:
    attr_type = _clean(attr_type)
    max_len = _clean(max_len)
    precision = _clean(precision)
    scale = _clean(scale)
    n = int(max_len) if max_len.isdigit() else 0
    p = int(precision) if precision and precision.isdigit() else 18
    s = int(scale) if scale and scale.isdigit() else 2
    if attr_type == "Uniqueidentifier":
        return "uuid"
    if attr_type == "String":
        return f"varchar({n})" if n else "varchar(255)"
    if attr_type == "DateTime":
        return "datetime"
    if attr_type == "Integer":
        return "int"
    if attr_type in ("Decimal", "Money", "Double"):
        return f"decimal({p},{s})"
    if attr_type == "Boolean":
        return "boolean"
    if attr_type == "BigInt":
        return "bigint"
    if attr_type in ("State", "Status", "Picklist", "StatusCode", "StateCode"):
        return "int"
    if attr_type in ("Owner", "Lookup"):
        return "uuid"
    if attr_type == "EntityName":
        return "varchar(100)"
    return "varchar(255)"

def skip_attribute(logical_name: str, attr_type: str, is_primary_name: bool) -> bool:
    n = _clean(logical_name).lower()
    t = _clean(attr_type)
    if t == "Virtual":
        return True
    if is_primary_name:
        return False  # keep primary name (e.g. solar_countryname)
    if n.endswith("name") and t == "String" and "id" not in n:
        return True
    if "yominame" in n:
        return True
    return False

def load_tables() -> set[str]:
    tables = set()
    with open(TABLES_CSV, "r", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            ln = _clean(row.get("LogicalName", ""))
            if ln:
                tables.add(ln)
    return tables or OUR_TABLES

def load_attributes(all_tables: set[str]) -> dict[str, list[dict]]:
    by_entity: dict[str, list[dict]] = defaultdict(list)
    with open(ATTRIBUTES_CSV, "r", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            entity = _clean(row.get("EntityLogicalName", ""))
            if entity not in all_tables:
                continue
            logical = _clean(row.get("AttributeLogicalName", ""))
            schema_name = _clean(row.get("AttributeSchemaName", ""))
            attr_type = _clean(row.get("AttributeType", ""))
            is_pk = _bool(row.get("IsPrimaryId", ""))
            is_name = _bool(row.get("IsPrimaryName", ""))
            if skip_attribute(logical, attr_type, is_name):
                continue
            req = _clean(row.get("RequiredLevel", ""))
            max_len = _clean(row.get("MaxLength", ""))
            prec = _clean(row.get("Precision", ""))
            scale = _clean(row.get("Scale", ""))
            dbml_type = type_to_dbml(attr_type, max_len, prec, scale)
            constraints = []
            # Only main entity ID as pk (e.g. accountid, solar_solarcountryid)
            main_pk = logical.lower() == entity.lower().replace("-", "") + "id"
            if is_pk and main_pk:
                constraints.append("pk")
            if req == "SystemRequired" and not (is_pk and main_pk):
                constraints.append("not null")
            by_entity[entity].append({
                "logical": logical,
                "schema": schema_name or logical,
                "type": dbml_type,
                "constraints": constraints,
                "is_pk": is_pk and main_pk,
                "is_name": is_name,
            })
    return dict(by_entity)

def load_relationships(all_tables: set[str]) -> list[dict]:
    seen: set[tuple[str, str, str, str]] = set()
    rels = []
    with open(RELATIONSHIPS_CSV, "r", encoding="utf-8-sig") as f:
        r = csv.DictReader(f)
        for row in r:
            ref_ent = _clean(row.get("ReferencedEntity", ""))
            refing_ent = _clean(row.get("ReferencingEntity", ""))
            if ref_ent not in all_tables or refing_ent not in all_tables:
                continue
            ref_attr = _clean(row.get("ReferencedAttribute", ""))
            refing_attr = _clean(row.get("ReferencingAttribute", ""))
            rel_type = _clean(row.get("RelationshipType", ""))
            if not ref_attr or not refing_attr:
                continue
            key = (refing_ent, refing_attr, ref_ent, ref_attr)
            if key in seen:
                continue
            seen.add(key)
            rels.append({
                "ref_entity": ref_ent,
                "refing_entity": refing_ent,
                "ref_attr": ref_attr,
                "refing_attr": refing_attr,
                "type": rel_type,
            })
    return rels

def get_primary_key(entity: str) -> str:
    """Infer primary key column name for entity (e.g. solar_locationid)."""
    if entity == "account":
        return "accountid"
    if entity == "contact":
        return "contactid"
    if entity == "new_account":
        return "new_accountid"
    # solar_* entities: entity + id (e.g. solar_location -> solar_locationid)
    return f"{entity}id" if not entity.endswith("id") else entity

def main():
    all_tables = load_tables()
    attrs = load_attributes(all_tables)
    rels = load_relationships(all_tables)

    lines = [
        "// Solar Dataverse schema (solardev)",
        "// Generated from solardev_attributes.csv and solardev_relationships.csv",
        "// Includes all 26+ tables from solardev (Φεβ 2025)",
        "",
    ]

    # Include tables that have attributes
    entities_with_attrs = set(attrs.keys())
    # Add tables from all_tables that have no attributes (minimal stub)
    for t in all_tables:
        if t not in entities_with_attrs:
            pk = get_primary_key(t)
            attrs[t] = [{"logical": pk, "type": "uuid", "constraints": ["pk"], "is_pk": True, "is_name": False}]

    for entity in sorted(attrs.keys()):
        cols = attrs[entity]
        lines.append(f"Table {entity} {{")
        for c in cols:
            # use logical for column names so Ref matches
            col_name = c["logical"]
            parts = [f"  {col_name}", c["type"]]
            if c["constraints"]:
                parts.append(f"[{', '.join(c['constraints'])}]")
            if c.get("is_name"):
                parts.append("// primary name")
            lines.append(" ".join(parts))
        lines.append("}")
        lines.append("")

    lines.append("// Relationships (only between solardev tables)")
    for r in rels:
        lines.append(f"Ref: {r['refing_entity']}.{r['refing_attr']} > {r['ref_entity']}.{r['ref_attr']}")

    out = "\n".join(lines)
    OUTPUT_DBML.write_text(out, encoding="utf-8")
    print(f"Wrote {OUTPUT_DBML}")

if __name__ == "__main__":
    main()
