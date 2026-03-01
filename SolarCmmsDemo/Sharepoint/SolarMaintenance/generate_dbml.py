import json
import re

def sanitize_table_name(name):
    """Convert table name to valid DBML identifier"""
    # Replace spaces and special characters with underscores
    name = re.sub(r'[^\w]', '_', name)
    # Remove multiple underscores
    name = re.sub(r'_+', '_', name)
    # Remove leading/trailing underscores
    name = name.strip('_')
    return name

def sanitize_column_name(name):
    """Convert column name to valid DBML identifier"""
    return sanitize_table_name(name)

def map_sharepoint_type_to_sql(sp_type, column_data):
    """Map SharePoint column type to SQL type"""
    if sp_type == "text":
        if column_data.get("allowMultipleLines"):
            return "text"
        max_length = column_data.get("maxLength", 255)
        if max_length and max_length <= 255:
            return f"varchar({max_length})"
        return "text"
    elif sp_type == "number":
        decimal_places = column_data.get("decimalPlaces", "0")
        if decimal_places == "0" or decimal_places == 0:
            return "integer"
        elif decimal_places == "Automatic":
            return "decimal"
        else:
            return "decimal(18, 2)"
    elif sp_type == "boolean":
        return "boolean"
    elif sp_type == "dateTime":
        format_type = column_data.get("format", "dateTime")
        if format_type == "dateOnly":
            return "date"
        return "datetime"
    elif sp_type == "lookup":
        return "integer"  # Foreign key ID
    elif sp_type == "personOrGroup":
        return "integer"  # User ID
    elif sp_type == "choice":
        return "varchar(255)"
    elif sp_type == "hyperlinkOrPicture":
        return "varchar(500)"
    else:
        return "text"

def get_column_constraints(column_data):
    """Get column constraints in DBML format"""
    constraints = []
    if column_data.get("required"):
        constraints.append("not null")
    if column_data.get("enforceUniqueValues"):
        constraints.append("unique")
    if column_data.get("indexed") and not column_data.get("enforceUniqueValues"):
        # Note: DBML doesn't have explicit index syntax, but we can note it
        pass
    if constraints:
        return " [" + ", ".join(constraints) + "]"
    return ""

def generate_dbml(custom_list_columns_file, relationship_lookup_file, output_file):
    """Generate DBML file from JSON files"""
    
    # Read JSON files
    with open(custom_list_columns_file, 'r', encoding='utf-8') as f:
        lists_data = json.load(f)
    
    with open(relationship_lookup_file, 'r', encoding='utf-8') as f:
        relationships_data = json.load(f)
    
    # Create lookup map for relationships
    relationships_map = {}
    for rel in relationships_data:
        list_name = rel.get("listName")
        if list_name not in relationships_map:
            relationships_map[list_name] = {}
        for lookup_col in rel.get("lookupColumns", []):
            col_name = lookup_col.get("columnName")
            relationships_map[list_name][col_name] = lookup_col
    
    # Generate DBML
    dbml_lines = []
    dbml_lines.append("// Solar Maintenance Database Schema")
    dbml_lines.append("// Generated from SharePoint list definitions")
    dbml_lines.append("")
    
    # Create tables and name mappings
    tables = {}
    name_to_table = {}  # Map both listName and internalName to table_name
    table_name_counts = {}  # Track how many times each table name is used
    
    # First pass: collect all table names and detect duplicates
    for list_data in lists_data:
        list_name = list_data.get("listName")
        internal_name = list_data.get("internalName", list_name)
        table_name = sanitize_table_name(internal_name)
        table_name_counts[table_name] = table_name_counts.get(table_name, 0) + 1
    
    # Second pass: create tables with unique names
    for list_data in lists_data:
        list_name = list_data.get("listName")
        internal_name = list_data.get("internalName", list_name)
        table_name = sanitize_table_name(internal_name)
        
        # If duplicate table name, use listName instead
        if table_name_counts[table_name] > 1:
            table_name = sanitize_table_name(list_name)
        
        tables[list_name] = table_name
        name_to_table[list_name] = table_name
        name_to_table[internal_name] = table_name
        
        # Special case: "Sections" lookup refers to "SectionTemplate (mistakenly named Sections)"
        if "mistakenly named Sections" in list_name or list_name == "SectionTemplate (mistakenly named Sections)":
            name_to_table["Sections"] = table_name
        
        dbml_lines.append(f"Table {table_name} {{")
        dbml_lines.append(f'  id integer [pk, increment]')
        
        # Add columns
        for column in list_data.get("columns", []):
            col_name = sanitize_column_name(column.get("name"))
            col_display_name = column.get("displayName", col_name)
            col_type = column.get("type")
            
            # Skip lookup columns - they'll be handled as relationships
            if col_type == "lookup":
                # Add the foreign key column
                lookup_list_name = column.get("lookupListName")
                if lookup_list_name:
                    sql_type = "integer"
                    constraints = get_column_constraints(column)
                    note = f' // Lookup to {lookup_list_name}'
                    dbml_lines.append(f'  {col_name} {sql_type}{constraints}{note}')
            else:
                sql_type = map_sharepoint_type_to_sql(col_type, column)
                constraints = get_column_constraints(column)
                note = f' // {col_display_name}'
                dbml_lines.append(f'  {col_name} {sql_type}{constraints}{note}')
        
        dbml_lines.append("}")
        dbml_lines.append("")
    
    # Track processed relationships to avoid duplicates
    processed_relationships = set()
    junction_tables_needed = {}
    
    # Collect all relationships first
    all_relationships = []
    for list_data in lists_data:
        list_name = list_data.get("listName")
        internal_name = list_data.get("internalName", list_name)
        table_name = sanitize_table_name(internal_name)
        
        # Process columns for lookup relationships
        for column in list_data.get("columns", []):
            if column.get("type") == "lookup":
                lookup_list_name = column.get("lookupListName")
                if lookup_list_name:
                    # Try to find the table name using lookup_list_name
                    target_table_name = None
                    if lookup_list_name in name_to_table:
                        target_table_name = name_to_table[lookup_list_name]
                    else:
                        # Try sanitized version
                        sanitized_lookup = sanitize_table_name(lookup_list_name)
                        for key, val in name_to_table.items():
                            if sanitize_table_name(key) == sanitized_lookup:
                                target_table_name = val
                                break
                    
                    if target_table_name:
                        col_name = column.get("name")
                        col_name_sanitized = sanitize_column_name(col_name)
                        allow_multiple = column.get("allowMultipleValues", False)
                        is_self_ref = (table_name == target_table_name)
                        
                        rel_key = (table_name, col_name_sanitized, target_table_name)
                        if rel_key not in processed_relationships:
                            processed_relationships.add(rel_key)
                            all_relationships.append({
                                "source_table": table_name,
                                "source_column": col_name_sanitized,
                                "target_table": target_table_name,
                                "allow_multiple": allow_multiple,
                                "is_self_ref": is_self_ref
                            })
    
    # Create junction tables for many-to-many relationships
    dbml_lines.append("// Junction Tables for Many-to-Many Relationships")
    dbml_lines.append("")
    
    for rel in all_relationships:
        if rel["allow_multiple"]:
            source_table = rel["source_table"]
            target_table = rel["target_table"]
            col_name = rel["source_column"]
            
            if rel["is_self_ref"]:
                junction_table = f"{source_table}_{col_name}"
            else:
                junction_table = f"{source_table}_{target_table}_{col_name}"
            
            if junction_table not in junction_tables_needed:
                junction_tables_needed[junction_table] = {
                    "source_table": source_table,
                    "target_table": target_table,
                    "is_self_ref": rel["is_self_ref"]
                }
                
                dbml_lines.append(f"Table {junction_table} {{")
                dbml_lines.append(f'  id integer [pk, increment]')
                if rel["is_self_ref"]:
                    dbml_lines.append(f'  parent_id integer [ref: > {source_table}.id]')
                    dbml_lines.append(f'  child_id integer [ref: > {source_table}.id]')
                else:
                    dbml_lines.append(f'  {source_table.lower()}_id integer [ref: > {source_table}.id]')
                    dbml_lines.append(f'  {target_table.lower()}_id integer [ref: > {target_table}.id]')
                dbml_lines.append("}")
                dbml_lines.append("")
    
    # Add relationships
    dbml_lines.append("// Relationships")
    dbml_lines.append("")
    
    for rel in all_relationships:
        source_table = rel["source_table"]
        source_column = rel["source_column"]
        target_table = rel["target_table"]
        
        if rel["allow_multiple"]:
            # Many-to-many: relationship is handled by junction table
            if rel["is_self_ref"]:
                junction_table = f"{source_table}_{source_column}"
            else:
                junction_table = f"{source_table}_{target_table}_{source_column}"
            # Relationships already defined in junction table
        else:
            # One-to-many relationship
            dbml_lines.append(f"Ref: {source_table}.{source_column} > {target_table}.id")
    
    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(dbml_lines))
    
    print(f"DBML file generated: {output_file}")
    print(f"Total tables: {len(tables)}")

if __name__ == "__main__":
    custom_list_file = "custom_list_columns.json"
    relationship_file = "relationship_lookup_columns.json"
    output_file = "schema.dbml"
    
    generate_dbml(custom_list_file, relationship_file, output_file)
