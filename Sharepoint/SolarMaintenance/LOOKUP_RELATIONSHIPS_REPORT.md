# SharePoint Lookup Relationships - Complete Documentation
Generated: 2026-01-26 23:43:51

## Summary Statistics
- **Total Lists with Lookup Relationships**: 27
- **Total Lookup Columns**: 56
- **Self-Referencing Hierarchical Lookups**: 6
- **Multi-Value Lookups**: 2
- **Standard Single-Value Lookups**: 48

## Self-Referencing Hierarchical Lookups (6)
These lists have parent-child relationships to themselves:
- **Corrective Task Categories**  Parent column
- **Locations**  Zones column
- **Tasks**  Predecessors column
- **Equipment Categories**  Parent column
- **Parts Categories**  Parent column
- **OM Categories**  Parent column
## Multi-Value Lookups (2)
These columns allow selecting multiple values:
- **Locations**  Zones  Locations
  - Description: Multi-value lookup to Locations
- **Tasks**  Predecessors  Tasks
  - Description: Self-referencing multi-value lookup for task dependencies
## Lists with Multiple Lookup Columns
Lists that have complex relationships with multiple lookups:
### Equipment (4 lookups)
- Category  EquipmentCategories
- Manufacturer or Brand  ManufacturerBrands
- Supplier  Suppliers
- CategoryType  EquipmentCategories

### Locations (4 lookups)
- Zones  Locations
- Account  
- Country  Countries
- DNO - Grid Operator  DNO

### Assets (4 lookups)
- Category  AssetsCategories
- Location  Locations
- Section  Sections
- Manufacturer or Brand  ManufacturerBrands

### Parts (3 lookups)
- Category  PartsCategories
- Manufacturer or Brand  ManufacturerBrands
- Supplier  Suppliers

### EquipmentSerial (3 lookups)
- Equipment  Equipment
- Location  Locations
- Section  Sections

### Stock Adjustments (3 lookups)
- Part  Parts
- Equipment  Equipment
- Warehouse  Warehouses

### Corrective Events (3 lookups)
- Location  Locations
- Category  CorrectiveTaskCategories
- Assigned Team  MaintenanceTeams

### PartsTransaction (3 lookups)
- Part  Parts
- From Warehouse  Warehouses
- To Warehouse  Warehouses

### EquipmentToWarehouse (2 lookups)
- Equipment  Equipment
- Warehouse  Warehouses

### Maintenance Team Per Location (2 lookups)
- Maintenance Team  MaintenanceTeams
- Location  Locations

### Preventive Tasks (2 lookups)
- Plan  PreventivePlan
- Category  PreventiveTaskCategories

### Warehouse To Location (2 lookups)
- Warehouse  Warehouses
- Location  Locations

### Preventive Plan (2 lookups)
- Location  Locations
- Assigned Team  MaintenanceTeams

### SubCorrectiveEvent (2 lookups)
- Corrective Event  CorrectiveEvents
- Category  CorrectiveTaskCategories

### WarehouseEquipmentSerial (2 lookups)
- Equipment  Equipment
- Warehouse  Warehouses

### Location Configuration (2 lookups)
- Location  Locations
- Item Type  LocationConfigurationItemTypes

### ServiceOrder (2 lookups)
- Service Company  ServiceCompanys
- Location  Locations

### Service (2 lookups)
- Category  OMCategories
- Default Service Company  ServiceCompanys

## Key Relationships by Target List

### Locations (Most Referenced - 15 references)
The Locations list is the central hub for site data:- Locations  Zones
- Warehouses  Location
- Assets  Location
- Location Configuration  Location
- Preventive Plan  Location
- Warehouse To Location  Location
- Corrective Events  Location
- Maintenance Team Per Location  Location
- EquipmentSerial  Location
- ServiceOrder  Location
### Warehouses (8 references)
Inventory management relationships:- WarehouseEquipmentSerial  Warehouse
- Warehouse To Location  Warehouse
- PartsTransaction  From Warehouse
- PartsTransaction  To Warehouse
- Stock Adjustments  Warehouse
- EquipmentToWarehouse  Warehouse
### Equipment (6 references)
Equipment tracking and management:- WarehouseEquipmentSerial  Equipment
- Stock Adjustments  Equipment
- EquipmentSerial  Equipment
- EquipmentToWarehouse  Equipment
## Data Migration Notes for Dataverse

### Hierarchical Relationships (Self-Referencing)
These 6 hierarchical lookups need special handling in Dataverse:
1. CorrectiveTaskCategories  Parent
2. EquipmentCategories  Parent
3. PartsCategories  Parent
4. AssetsCategories  Parent
5. PreventiveTaskCategories  Parent
6. OMCategories  CategoryParent

**Dataverse Implementation**: Use self-referential Many-to-One relationships with proper cascade rules.

### Multi-Value Lookups
These 2 multi-value lookups require many-to-many relationships:
1. Locations  Zones (self-referencing multi-zone assignment)
2. Tasks  Predecessors (task dependency tracking)

**Dataverse Implementation**: Create junction/intersect tables to represent many-to-many relationships.

### Missing List IDs
Some lists are missing listId values in the source data:
- Warehouses
- Assets
- AssetsCategories
- LocationConfiguration
- LocationConfigurationItemTypes
- WarehouseEquipmentSerial
- SubCorrectiveEvent
- PreventivePlan
- PreventiveTaskCategories
- Settings
- WarehouseToLocation
- CorrectiveEvents
- PartsTransaction
- PreventiveTasks
- StockAdjustments
- MaintenanceTeamPerLocation
- MaintenanceTeamMembers
- EquipmentSerial
- EquipmentToWarehouse
- ServiceOrder
- Service
- SectionTemplate
- MaintenanceTeams

**Action Required**: Retrieve actual list IDs from SharePoint before migration.

### External Lookup
- Locations  Account (lookup to external list)

**Action Required**: Identify and document the external Accounts list structure.

## File Location
`c:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo\Sharepoint\SolarMaintenance\relationship_lookup_columns.json`

## Usage
This file serves as the complete reference for:
1. Understanding data dependencies between lists
2. Planning Dataverse relationship schema
3. Identifying migration complexity points
4. Documenting data integrity requirements
