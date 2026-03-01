# Solar Plant Management System - Entity Relationship Diagram

## System Overview
This diagram represents a comprehensive Solar Plant Maintenance Management System with **73 lookup relationships** across **37 entities**, covering master data, operational workflows, maintenance activities, and inventory management.

## Entity Relationship Diagram

```mermaid
erDiagram
    %% ========================================
    %% MASTER DATA ENTITIES (No Dependencies)
    %% ========================================
    
    Countries {
        int ID PK
        string Title
        string ISOAlpha2
        string ISOAlpha3
    }
    
    Suppliers {
        int ID PK
        string Code UK
        string Title
        text Description
        text Notes
        boolean Active
    }
    
    ManufacturerBrands {
        int ID PK
        string Code UK
        string Title
        string Logo
        text Description
        string Website
        text Notes
        boolean Active
    }
    
    DNO {
        int ID PK
        string Code
        string Title
        string EmergencyNumber
        text Description
        string Telephone
        string Email
        string Website
        text Notes
    }
    
    DeviceChannels {
        int ID PK
        string Title
        string Alias UK
        text Description
        text UserAgentSubstrings
        boolean Active
    }
    
    DocumentSetCategories {
        int ID PK
        string Title
    }
    
    LocationConfigurationItemTypes {
        int ID PK
        string Code UK
        string Title
        text Description
        boolean Active
    }
    
    MaintenanceTeams {
        int ID PK
        string Code UK
        string Title
        text Description
        int TeamLeader
        text Notes
        boolean Active
    }
    
    ServiceCompanys {
        int ID PK
        string Code UK
        string Title
        text Description
        string ContactPerson
        string Email
        string Phone
        string Website
        text Notes
        boolean Active
    }
    
    Settings {
        int ID PK
        string Title UK
        text Value
        text Description
    }
    
    SectionTemplate {
        int ID PK
        string Code UK
        string Title
        text Description
        string TemplateType
        text Notes
        boolean Active
    }
    
    %% ========================================
    %% HIERARCHICAL CATEGORIES (Self-Referencing)
    %% ========================================
    
    EquipmentCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        string MainType
        int ParentID FK
        text Notes
        boolean Active
        string CategoryType
    }
    
    PartsCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        string Level
        int ParentID FK
        text Notes
        boolean Active
    }
    
    AssetsCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        int ParentID FK
        text Notes
        boolean Active
    }
    
    CorrectiveTaskCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        int ParentID FK
        text Notes
        boolean Active
    }
    
    PreventiveTaskCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        int ParentID FK
        text Notes
        boolean Active
    }
    
    OMCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        int CategoryParentID FK
        text Notes
        boolean Active
    }
    
    MaintenanceTeamCategories {
        int ID PK
        string Code UK
        string Title
        string Description
        int ParentID FK
        text Notes
        boolean Active
    }
    
    PreventivePlanCategories {
        int ID PK
        string Code UK
        string Title
        text Description
        string Level
        int ParentID FK
        text Notes
        boolean Active
    }
    
    %% ========================================
    %% ACCOUNT & LOCATION ENTITIES
    %% ========================================
    
    Accounts {
        int ID PK
        string Code UK
        string Title
        string DistinctiveTitle
        text Description
        text AddressDescription
        string Street
        string ZipOrPostalCode
        string City
        string StateOrProvince
        int CountryID FK
        string Telephone
        string Email
        int ManagerID
        text Notes
    }
    
    Locations {
        int ID PK
        string Code UK
        string Title
        date OpenDate
        date CloseDate
        string Stage
        decimal CapacityMW
        decimal AnnualOutputGWh
        boolean StockManagement
        int AccountID FK
        boolean ContainsSections
        int ManagerID
        text Description
        decimal LandSizeHectares
        text AddressDescription
        string Street
        string ZipOrPostalCode
        string StateOrProvince
        int CountryID FK
        decimal Latitude
        decimal Longtitude
        string GoogleEarth
        text EmbedMap
        string What3Words
        boolean Grazed
        text LandOwnerFarmerDetails
        string InverterManufacturer
        string InverterType
        string InverterModel
        int InverterQuantity
        int InverterTotal
        int InverterLVVoltage
        decimal InverterPower
        int AssumedWarrantyPeriod
        date WarrantyExpiry
        date EstimatedExpiry
        string ModuleManufacturer
        string ModuleModel
        int ModuleQuantity
        decimal ModulePower
        decimal ModuleVoc
        decimal ModuleIsc
        decimal ModuleLength
        decimal ModuleWidth
        decimal ModuleDepth
        string ModuleStructure
        string Satellite3G4G
        string LANNetwork
        string SCADAProvider
        boolean ADASInstalled
        string DataLoggers
        int DNOGridOperatorID FK
        string DNOSizeKV
        string DNOContact
        string DNOContact2
        string DNOContact3
        string SiteReferenceNumber
        string HVContractor
        string TBootSub
        int TransformerQuantity
        string TransformerMake
        string TransformerModel
        int TransformerRatingKVA
        string Security
        text SecurityCodes
        text SiteAccessDetails
        text AccessGateCodes
        string ExportMeterLocation
        text ExportMeterAccessDetails
        int SupervisorID
        text OtherInformation
        text Notes
        boolean Active
    }
    
    Sections {
        int ID PK
        string Title
        int LocationID FK
        boolean Active
    }
    
    %% ========================================
    %% INVENTORY ENTITIES
    %% ========================================
    
    Equipment {
        int ID PK
        string Code UK
        string Title
        int CategoryID FK
        text Description
        string ManufacturerID
        int ManufacturerOrBrandID FK
        int SupplierID FK
        boolean StockManagement
        string Photo
        string URL
        text Notes
        boolean Active
        string CategoryType
        boolean Serial
    }
    
    Parts {
        int ID PK
        string Code UK
        string Title
        int CategoryID FK
        text Description
        string Barcode UK
        string UPC UK
        string ManufacturerID
        int ManufacturerOrBrandID FK
        int SupplierID FK
        boolean StockManagement
        boolean Consumable
        string Photo
        string URL
        decimal MinQTY
        text Notes
        boolean Active
    }
    
    Assets {
        int ID PK
        string Code UK
        string Title
        int CategoryID FK
        text Description
        int LocationID FK
        int SectionID FK
        string SerialNumber
        int ManufacturerOrBrandID FK
        date InstallationDate
        date WarrantyExpiry
        text Notes
        boolean Active
    }
    
    Warehouses {
        int ID PK
        string Title
        int LocationID FK
    }
    
    EquipmentSerial {
        int ID PK
        string Title UK
        int EquipmentID FK
        int LocationID FK
        int SectionID FK
        date InstallationDate
        string Status
        text Notes
    }
    
    %% ========================================
    %% MAINTENANCE & TASK ENTITIES
    %% ========================================
    
    CorrectiveTasks {
        int ID PK
        string Code UK
        string Title
        string Description
        int CategoryID FK
        int OMCategoryID FK
        string Frequency
        int MaintenanceTeamCategoryID FK
        string WarrantyType
        string ApplicableUnit
        text Notes
        boolean Active
    }
    
    CorrectiveEvents {
        int ID PK
        string Code UK
        string Title
        int LocationID FK
        int CategoryID FK
        text Description
        string Priority
        string Status
        date ReportedDate
        date DueDate
        int AssignedTeamID FK
        int AssignedToID
        text Notes
        date CompletedDate
    }
    
    SubCorrectiveEvent {
        int ID PK
        string Title
        int CorrectiveEventID FK
        int CategoryID FK
        text Description
        string Priority
        string Status
        int AssignedToID
        date DueDate
        text Notes
    }
    
    PreventivePlan {
        int ID PK
        string Code UK
        string Title
        int LocationID FK
        text Description
        string Frequency
        date StartDate
        date NextDueDate
        int AssignedTeamID FK
        text Notes
        boolean Active
    }
    
    PreventiveTasks {
        int ID PK
        string Code UK
        string Title
        int PlanID FK
        int CategoryID FK
        text Description
        string Status
        date ScheduledDate
        date CompletedDate
        int AssignedToID
        text Notes
    }
    
    Tasks {
        int ID PK
        string Title
        string Priority
        string Status
        decimal PercentComplete
        int AssignedToID
        int TaskGroupID
        text Description
        date StartDate
        date DueDate
        string RelatedItems
    }
    
    ServiceOrder {
        int ID PK
        string Title UK
        int ServiceCompanyID FK
        int LocationID FK
        text Description
        date OrderDate
        date ScheduledDate
        string Status
        string Priority
        text Notes
    }
    
    Service {
        int ID PK
        string Code UK
        string Title
        text Description
        int CategoryID FK
        int DefaultServiceCompanyID FK
        decimal UnitCost
        text Notes
        boolean Active
    }
    
    %% ========================================
    %% TRANSACTION & TRACKING ENTITIES
    %% ========================================
    
    EquipmentTransaction {
        int ID PK
        string Title
        string Warehouse
        string TaskType
        string JobID
        date HandlingDate
        string RecordType
        string Reason
        string ToWarehouse
        decimal Quantity
        decimal CurrentQuantity
        string EquipmentId
        int LocationID FK
        int CategoryID FK
        string WarehouseLocationID
        string LocationId
        string toWarehouseLocationID
        string WarehouseID
        string toWarehouseID
        string EquipmentWarehouseID
        string quid
        boolean Serial
        string SerialNotes
    }
    
    PartsTransaction {
        int ID PK
        string Title
        int PartID FK
        string TransactionType
        decimal Quantity
        int FromWarehouseID FK
        int ToWarehouseID FK
        date TransactionDate
        text Notes
    }
    
    StockAdjustments {
        int ID PK
        string Title
        string ItemType
        int PartID FK
        int EquipmentID FK
        int WarehouseID FK
        string AdjustmentType
        decimal Quantity
        date AdjustmentDate
        text Reason
        text Notes
    }
    
    EquipmentToWarehouse {
        int ID PK
        string Title
        int EquipmentID FK
        int WarehouseID FK
        decimal Quantity
        decimal MinQuantity
        text Notes
    }
    
    WarehouseEquipmentSerial {
        int ID PK
        string Title
        int EquipmentID FK
        int WarehouseID FK
        string SerialNumber UK
        string Status
        text Notes
    }
    
    WarehouseToLocation {
        int ID PK
        string Title
        int WarehouseID FK
        int LocationID FK
        text Description
    }
    
    LocationConfiguration {
        int ID PK
        string Title
        int LocationID FK
        int ItemTypeID FK
        decimal Quantity
        text Description
        text Notes
        boolean Active
    }
    
    %% ========================================
    %% TEAM & MEMBERSHIP ENTITIES
    %% ========================================
    
    MaintenanceTeamMembers {
        int ID PK
        string Title
        int MaintenanceTeamID FK
        int MemberID
        string Role
        date StartDate
        date EndDate
        boolean Active
    }
    
    MaintenanceTeamPerLocation {
        int ID PK
        string Title
        int MaintenanceTeamID FK
        int LocationID FK
        date StartDate
        date EndDate
        boolean Active
    }
    
    %% ========================================
    %% DOCUMENT & MISCELLANEOUS ENTITIES
    %% ========================================
    
    DocumentSets {
        int ID PK
        string Title
        int CategoryID FK
        text Comments
    }
    
    PublishedFeed {
        int ID PK
        string Title
        text Body
        datetime PublishedDate
    }
    
    SiteCollectionDocuments {
        int ID PK
        string FileLeafRef
        string Title
    }
    
    TrackingSerial {
        int ID PK
        string TRID
        string EID
        string Guid
        string WID
        int WarehouseID FK
    }
    
    %% ========================================
    %% RELATIONSHIPS - HIERARCHICAL (SELF-REFERENCING)
    %% ========================================
    
    EquipmentCategories ||--o{ EquipmentCategories : "Parent"
    PartsCategories ||--o{ PartsCategories : "Parent"
    AssetsCategories ||--o{ AssetsCategories : "Parent"
    CorrectiveTaskCategories ||--o{ CorrectiveTaskCategories : "Parent"
    PreventiveTaskCategories ||--o{ PreventiveTaskCategories : "Parent"
    OMCategories ||--o{ OMCategories : "CategoryParent"
    MaintenanceTeamCategories ||--o{ MaintenanceTeamCategories : "Parent"
    PreventivePlanCategories ||--o{ PreventivePlanCategories : "Parent"
    
    %% ========================================
    %% RELATIONSHIPS - MULTI-VALUE LOOKUPS
    %% ========================================
    
    Locations ||--o{ Locations : "Zones [MV]"
    Tasks ||--o{ Tasks : "Predecessors [MV]"
    
    %% ========================================
    %% RELATIONSHIPS - MASTER DATA
    %% ========================================
    
    Countries ||--o{ Accounts : "has"
    Countries ||--o{ Locations : "has"
    
    Suppliers ||--o{ Equipment : "supplies"
    Suppliers ||--o{ Parts : "supplies"
    
    ManufacturerBrands ||--o{ Equipment : "manufactures"
    ManufacturerBrands ||--o{ Parts : "manufactures"
    ManufacturerBrands ||--o{ Assets : "manufactures"
    
    DNO ||--o{ Locations : "manages_grid"
    
    %% ========================================
    %% RELATIONSHIPS - LOCATION & STRUCTURE
    %% ========================================
    
    Accounts ||--o{ Locations : "owns"
    
    Locations ||--o{ Sections : "contains"
    Locations ||--o{ Assets : "houses"
    Locations ||--o{ EquipmentSerial : "has_equipment"
    Locations ||--o{ CorrectiveEvents : "has_events"
    Locations ||--o{ PreventivePlan : "has_plans"
    Locations ||--o{ ServiceOrder : "has_orders"
    Locations ||--o{ EquipmentTransaction : "transaction_at"
    Locations ||--o{ LocationConfiguration : "configured_for"
    Locations ||--o{ MaintenanceTeamPerLocation : "assigned_to"
    Locations ||--o{ WarehouseToLocation : "linked_to"
    Locations ||--o{ Warehouses : "hosts"
    
    Sections ||--o{ Assets : "contains"
    Sections ||--o{ EquipmentSerial : "contains"
    
    %% ========================================
    %% RELATIONSHIPS - CATEGORIES TO ITEMS
    %% ========================================
    
    EquipmentCategories ||--o{ Equipment : "categorizes"
    EquipmentCategories ||--o{ EquipmentTransaction : "categorizes"
    
    PartsCategories ||--o{ Parts : "categorizes"
    
    AssetsCategories ||--o{ Assets : "categorizes"
    
    CorrectiveTaskCategories ||--o{ CorrectiveTasks : "categorizes"
    CorrectiveTaskCategories ||--o{ CorrectiveEvents : "categorizes"
    CorrectiveTaskCategories ||--o{ SubCorrectiveEvent : "categorizes"
    
    PreventiveTaskCategories ||--o{ PreventiveTasks : "categorizes"
    
    OMCategories ||--o{ CorrectiveTasks : "categorizes_om"
    OMCategories ||--o{ Service : "categorizes"
    
    MaintenanceTeamCategories ||--o{ CorrectiveTasks : "assigned_to"
    
    DocumentSetCategories ||--o{ DocumentSets : "categorizes"
    
    LocationConfigurationItemTypes ||--o{ LocationConfiguration : "defines"
    
    %% ========================================
    %% RELATIONSHIPS - INVENTORY & STOCK
    %% ========================================
    
    Equipment ||--o{ EquipmentSerial : "has_serial"
    Equipment ||--o{ EquipmentToWarehouse : "stored_in"
    Equipment ||--o{ WarehouseEquipmentSerial : "has_warehouse_serial"
    Equipment ||--o{ StockAdjustments : "adjusted"
    
    Parts ||--o{ PartsTransaction : "transacted"
    Parts ||--o{ StockAdjustments : "adjusted"
    
    %% ========================================
    %% RELATIONSHIPS - WAREHOUSES
    %% ========================================
    
    Warehouses ||--o{ EquipmentToWarehouse : "stores"
    Warehouses ||--o{ WarehouseEquipmentSerial : "holds"
    Warehouses ||--o{ PartsTransaction : "from_warehouse"
    Warehouses ||--o{ PartsTransaction : "to_warehouse"
    Warehouses ||--o{ StockAdjustments : "adjusted_at"
    Warehouses ||--o{ WarehouseToLocation : "linked_from"
    Warehouses ||--o{ TrackingSerial : "tracks"
    
    %% ========================================
    %% RELATIONSHIPS - MAINTENANCE & TEAMS
    %% ========================================
    
    MaintenanceTeams ||--o{ CorrectiveEvents : "handles"
    MaintenanceTeams ||--o{ PreventivePlan : "assigned"
    MaintenanceTeams ||--o{ MaintenanceTeamMembers : "has_members"
    MaintenanceTeams ||--o{ MaintenanceTeamPerLocation : "assigned_to"
    
    %% ========================================
    %% RELATIONSHIPS - TASKS & WORK ORDERS
    %% ========================================
    
    PreventivePlan ||--o{ PreventiveTasks : "generates"
    
    CorrectiveEvents ||--o{ SubCorrectiveEvent : "has_subtasks"
    
    %% ========================================
    %% RELATIONSHIPS - SERVICE
    %% ========================================
    
    ServiceCompanys ||--o{ Service : "provides_default"
    ServiceCompanys ||--o{ ServiceOrder : "fulfills"
```

## Legend

### Relationship Notation
- `||--o{` : One-to-Many relationship
- `[MV]` : Multi-Value lookup (allows selecting multiple values)
- `UK` : Unique Key (enforceUniqueValues = true)
- `FK` : Foreign Key (lookup relationship)
- `PK` : Primary Key

### Color Coding by Source System

**PvTicketing Entities (BGE System):**
- Services, BGE Owned Spares Tracking, Plant Remedials, DNOs, Clients, PVGroup, Remedial Docs, SCB, Warehouses (original), PlantPreventativeCopy, CategoriesPerFarm, Contracts, Contact Info Misc, Health And Safety On-site, PV Plants Contact Info, BGE Owned Spares, Plant Engineer, SLA Levels, Documents To Fill, Content and Structure Reports, Periodic Scheduled Actions, PV Plants CCTV Gate Codes, PV Plants DNO Stations, PV Plants, PV Plants System Info, Asset Categories, DailyDocs, Countries (PV version), Equipment Tracking (PV version), Strings, Plant Preventative, Translation Status, PV Plants Site Credentials, Comments - Remarks

**SolarMaintenance Unique Entities:**
- Suppliers, Equipment, Parts, DeviceChannels, DNO (SM version), Corrective Task Categories, Locations (comprehensive), Tasks, PublishedFeed, SiteCollectionDocuments, Equipment Categories, Parts Categories, Manufacturer Brands, Assets, Assets Categories, Location Configuration, Location Configuration Item Types, WarehouseEquipmentSerial, SubCorrectiveEvent, Preventive Plan, Preventive Task Categories, Settings, Warehouse To Location, Corrective Events, PartsTransaction, Preventive Tasks, Stock Adjustments, Maintenance Team Per Location, Maintenance Team Members, Service Companys, OM Categories, Maintenance Teams, EquipmentSerial, EquipmentToWarehouse, ServiceOrder, Service, SectionTemplate, DocumentSetCategories, MaintenanceTeamCategories, Accounts, PreventivePlanCategories, DocumentSets, CorrectiveTasks, EquipmentTransaction, Sections, Tasks (Timeline), TrackingSerial

### Special Relationship Types

**Self-Referencing (Hierarchical):**
1. EquipmentCategories → EquipmentCategories (Parent)
2. PartsCategories → PartsCategories (Parent)
3. AssetsCategories → AssetsCategories (Parent)
4. CorrectiveTaskCategories → CorrectiveTaskCategories (Parent)
5. PreventiveTaskCategories → PreventiveTaskCategories (Parent)
6. OMCategories → OMCategories (CategoryParent)
7. MaintenanceTeamCategories → MaintenanceTeamCategories (Parent)
8. PreventivePlanCategories → PreventivePlanCategories (Parent)

**Multi-Value Lookups:**
1. Locations → Locations (Zones) - Allows location to contain multiple zone references
2. Tasks → Tasks (Predecessors) - Task dependency management

### Key Observations

1. **Most Connected Entity**: `Locations` (73 columns, 4 lookups out, 14+ lookups in)
2. **Critical Junction Tables**: 
   - EquipmentToWarehouse
   - WarehouseToLocation
   - MaintenanceTeamPerLocation
   - LocationConfiguration
3. **Transaction Tables**: EquipmentTransaction, PartsTransaction, StockAdjustments
4. **8 Hierarchical Categories**: All self-referencing for unlimited depth
5. **2 Multi-Value Lookups**: Locations.Zones and Tasks.Predecessors

---
**Generated**: January 27, 2026  
**Total Entities**: 37  
**Total Relationships**: 73  
**Source Systems**: PvTicketing + SolarMaintenance
