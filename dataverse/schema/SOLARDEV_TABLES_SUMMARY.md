# Solardev – Πλήρης λίστα πινάκων (26 tables)

Έκδοση από Dataverse export (Φεβρουάριος 2025).

## Πίνακες στο Solardev

| # | Logical Name | Display Name | Τύπος |
|---|--------------|--------------|-------|
| 1 | account | Account | System |
| 2 | contact | Contact | System |
| 3 | new_account | Account (custom) | Custom |
| 4 | solar_location | Locations | Custom |
| 5 | solar_section | Sections | Custom |
| 6 | solar_solarcountry | Countries (legacy) | Custom |
| 7 | solar_country | Country | Custom |
| 8 | solar_clients | Clients | Custom |
| 9 | solar_maintenance_team | Maintenance Teams | Custom |
| 10 | solar_maintenanceteamcategory | Maintenance Team Category | Custom |
| 11 | solar_maintenanceteammember | Maintenance Team Member | Custom |
| 12 | solar_maintenanceteamperlocation | Maintenance Team Per Location | Custom |
| 13 | solar_sitecredentials | Site Credentials | Custom |
| 14 | solar_sitecomments | Site Comments | Custom |
| 15 | solar_corrective_category | Corrective Category | Custom |
| 16 | solar_corrective_work_order | Corrective Work Order | Custom |
| 17 | solar_task | Task | Custom |
| 18 | solar_notification | Notification | Custom |
| 19 | solar_solarassetcategory | Asset Category | Custom |
| 20 | solar_solarpreventiveplan | Preventive Plan | Custom |
| 21 | solar_solarpreventiveplancategory | Preventive Plan Category | Custom |
| 22 | solar_solarpreventivetask | Preventive Task | Custom |
| 23 | solar_solarpreventivetaskcategory | Preventive Task Category | Custom |
| 24 | solar_solarmodule | Module | Custom |
| 25 | solar_solarinverter | Inverter | Custom |
| 26 | solar_equipmentwarehouse | Equipment Warehouse | Custom |
| 27 | solar_inverter | Inverter (alt) | Custom |
| 28 | solar_module | Module (alt) | Custom |

**Σημείωση:** Οι πίνακες `solar_inverter` και `solar_module` μπορεί να είναι εναλλακτικές ονομασίες ή παλιές εκδόσεις των `solar_solarinverter` και `solar_solarmodule`.

## Αρχεία schema

- **solardev_tables.csv** – Λίστα πινάκων
- **solardev_attributes.csv** – Attributes (μόνο για τους παλιούς πίνακες)
- **solardev_relationships.csv** – Relationships
- **solardev_schema.dbml** – DBML schema (από csv_to_dbml.py)
- **solardev_full_schema.json** – Πλήρες JSON export από Dataverse MCP
- **solardev_diagram.mmd** – Mermaid ER diagram

## Επόμενα βήματα

Για να ενημερωθεί το `solardev_schema.dbml` με όλους τους πίνακες:

1. Ενημέρωση του `solardev_attributes.csv` με τα attributes των νέων πινάκων (solar_section, solar_clients, solar_country, κ.λπ.)
2. Εκτέλεση: `python csv_to_dbml.py`

Ή χρήση του `solardev_full_schema.json` για δημιουργία DBML από το Dataverse MCP export.
