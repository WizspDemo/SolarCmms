# SolarMaintenanceSystem - Dataverse Solution Implementation Plan

## Solution Information

**Solution Name**: SolarMaintenanceSystem  
**Publisher Name**: WIZSP  
**Publisher Prefix**: solar  
**Version**: 1.0.0.0  
**Description**: Complete Solar Plant Maintenance Management System for Microsoft Dataverse  
**Source**: Unified schema from PvTicketing + SolarMaintenance SharePoint systems  
**Total Tables**: 37 custom tables  
**Total Relationships**: 73 lookup relationships  

---

## Executive Summary

This implementation plan guides the migration of a comprehensive Solar Plant Maintenance Management System to Microsoft Dataverse. The system manages:
- **Master Data**: Countries, Suppliers, Manufacturers, DNO operators
- **Inventory**: Equipment, Parts, Assets with serial tracking
- **Locations**: Solar plant sites with 73 columns of specifications
- **Maintenance**: Corrective/Preventive tasks, events, plans
- **Warehousing**: Stock levels, transactions, adjustments
- **Teams**: Maintenance teams, assignments, service orders

---

## Implementation Phases

### Phase 1: Master Data Tables (Wave 1 - Day 1-5)
**Priority**: CRITICAL - No dependencies, foundation for all other data

#### 1.1 Countries (`solar_country`)
- **Purpose**: Country master data for addresses
- **Primary Name**: `solar_name` (Country name)
- **Key Columns**:
  - `solar_name` (Single Line of Text, 255) - Required
  - `solar_isoalpha2` (Single Line of Text, 2) - ISO code
  - `solar_isoalpha3` (Single Line of Text, 3) - ISO code
- **Why Phase 1**: Referenced by Accounts and Locations
- **Migration Priority**: High - Load first

#### 1.2 Suppliers (`solar_supplier`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text, 255) - Unique, Indexed
  - `solar_name` (Single Line of Text, 255) - Required
  - `solar_description` (Multiple Lines of Text)
  - `solar_notes` (Multiple Lines of Text, Rich Text)
  - `solar_active` (Two Options: Yes/No) - Default Yes
- **Business Rules**: Code uniqueness, Active default
- **Why Phase 1**: Referenced by Equipment and Parts

#### 1.3 Manufacturer Brands (`solar_manufacturerbrand`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text, 255) - Unique
  - `solar_logo` (Single Line of Text, 255) - File reference
  - `solar_website` (URL)
  - `solar_active` (Two Options)
- **Why Phase 1**: Referenced by Equipment, Parts, Assets

#### 1.4 DNO - Distribution Network Operators (`solar_dno`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text)
  - `solar_emergencynumber` (Phone)
  - `solar_telephone` (Phone)
  - `solar_email` (Email)
  - `solar_website` (URL)
- **Why Phase 1**: Referenced by Locations

#### 1.5 Device Channels (`solar_devicechannel`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_alias` (Single Line of Text, 255) - Unique
  - `solar_useragentsubstrings` (Multiple Lines of Text)
  - `solar_active` (Two Options)

#### 1.6 Document Set Categories (`solar_documentsetcategory`)
- **Primary Name**: `solar_name`
- Simple reference table for DocumentSets

#### 1.7 Location Configuration Item Types (`solar_locationconfigitemtype`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_active` (Two Options)

#### 1.8 Maintenance Teams (`solar_maintenanceteam`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_teamleader` (Lookup to User)
  - `solar_active` (Two Options)

#### 1.9 Service Companies (`solar_servicecompany`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_contactperson` (Single Line of Text)
  - `solar_email` (Email)
  - `solar_phone` (Phone)
  - `solar_website` (URL)
  - `solar_active` (Two Options)

#### 1.10 Settings (`solar_setting`)
- **Primary Name**: `solar_key` (Configuration key)
- **Key Columns**:
  - `solar_key` (Single Line of Text) - Unique, Required
  - `solar_value` (Multiple Lines of Text)
  - `solar_description` (Multiple Lines of Text)

#### 1.11 Section Template (`solar_sectiontemplate`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_templatetype` (Choice: String, Combiner, Inverter, Transformer)
  - `solar_active` (Two Options)

---

### Phase 2: Hierarchical Categories (Wave 1 - Day 3-7)
**Priority**: CRITICAL - Self-referencing tables, must be created before items

#### 2.1 Equipment Categories (`solar_equipmentcategory`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_maintype` (Choice: Equipment, Asset)
  - `solar_parent` (Lookup to solar_equipmentcategory) - Self-referencing
  - `solar_categorytype` (Single Line of Text) - Calculated
  - `solar_active` (Two Options)
- **Special**: Hierarchical with Parent lookup to itself
- **Migration**: Import top-level categories first, then children

#### 2.2 Parts Categories (`solar_partscategory`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_level` (Choice: Category Level #1, #2, #3) - Default #1
  - `solar_parent` (Lookup to solar_partscategory) - Self-referencing
  - `solar_active` (Two Options)

#### 2.3 Assets Categories (`solar_assetscategory`)
- Self-referencing hierarchy like Equipment Categories

#### 2.4 Corrective Task Categories (`solar_correctivetaskcategory`)
- Self-referencing for corrective maintenance categories

#### 2.5 Preventive Task Categories (`solar_preventivetaskcategory`)
- Self-referencing for preventive maintenance categories

#### 2.6 O&M Categories (`solar_omcategory`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_categoryparent` (Lookup to solar_omcategory) - Self-referencing
  - `solar_active` (Two Options)

#### 2.7 Maintenance Team Categories (`solar_maintenanceteamcategory`)
- Self-referencing for team categorization

#### 2.8 Preventive Plan Categories (`solar_preventiveplancategory`)
- Self-referencing with Level field

---

### Phase 3: Accounts & Locations (Wave 2 - Day 5-10)
**Priority**: HIGH - Core operational data

#### 3.1 Accounts (`solar_account`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_distinctivetitle` (Single Line of Text)
  - `solar_street` (Single Line of Text)
  - `solar_ziporpostalcode` (Single Line of Text)
  - `solar_city` (Single Line of Text)
  - `solar_stateorprovince` (Single Line of Text)
  - `solar_country` (Lookup to solar_country)
  - `solar_telephone` (Phone)
  - `solar_email` (Email)
  - `solar_manager` (Lookup to User)
  - `solar_description` (Multiple Lines of Text, Rich Text)
  - `solar_notes` (Multiple Lines of Text, Rich Text)

#### 3.2 Locations (`solar_location`) **MOST COMPLEX TABLE - 73 columns**
- **Primary Name**: `solar_name`
- **Key Columns** (Grouped):

**Basic Information**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_opendate` (Date Only)
  - `solar_closedate` (Date Only)
  - `solar_stage` (Choice: Construction, Oem, Repower) - Default Oem
  - `solar_capacitymw` (Decimal Number, 2 decimals)
  - `solar_annualoutputgwh` (Decimal Number, 2 decimals)
  - `solar_stockmanagement` (Two Options) - Default Yes
  - `solar_account` (Lookup to solar_account)
  - `solar_containssections` (Two Options) - Default Yes
  - `solar_manager` (Lookup to User)

**Address & Location**:
  - `solar_landsizehectares` (Decimal Number)
  - `solar_street`, `solar_ziporpostalcode`, `solar_stateorprovince`
  - `solar_country` (Lookup to solar_country)
  - `solar_latitude` (Decimal Number, 6 decimals)
  - `solar_longitude` (Decimal Number, 6 decimals)
  - `solar_googleearth` (URL)
  - `solar_embedmap` (Multiple Lines of Text)
  - `solar_what3words` (Single Line of Text)
  - `solar_grazed` (Two Options)

**Inverter Specifications** (11 columns):
  - `solar_invertermanufacturer`, `solar_invertertype`, `solar_invertermodel`
  - `solar_inverterquantity` (Whole Number)
  - `solar_invertertotal`, `solar_inverterlvvoltage`
  - `solar_inverterpower` (Decimal Number)
  - `solar_assumedwarrantyperiod` (Whole Number)
  - `solar_warrantyexpiry`, `solar_estimatedexpiry` (Date Only)

**Module Specifications** (11 columns):
  - `solar_modulemanufacturer`, `solar_modulemodel`
  - `solar_modulequantity` (Whole Number)
  - `solar_modulepower`, `solar_modulevoc`, `solar_moduleisc`
  - `solar_modulelength`, `solar_modulewidth`, `solar_moduledepth` (Decimal)
  - `solar_modulestructure` (Single Line of Text)

**Network & Monitoring**:
  - `solar_satellite3g4g`, `solar_lannetwork`, `solar_scadaprovider`
  - `solar_adasinstalled` (Two Options)
  - `solar_dataloggers` (Single Line of Text)

**DNO & Grid** (7 columns):
  - `solar_dnogridoperator` (Lookup to solar_dno)
  - `solar_dnosizekv`, `solar_dnocontact`, `solar_dnocontact2`, `solar_dnocontact3`
  - `solar_sitereferencenumber`, `solar_hvcontractor`

**Transformer** (5 columns):
  - `solar_tbootsub`, `solar_transformerquantity`, `solar_transformermake`
  - `solar_transformermodel`, `solar_transformerratingkva`

**Security & Access** (6 columns):
  - `solar_security`, `solar_securitycodes`, `solar_siteaccessdetails`
  - `solar_accessgatecodes`, `solar_exportmeterlocation`
  - `solar_exportmeteraccessdetails`

**Additional**:
  - `solar_supervisor` (Lookup to User)
  - `solar_otherinformation` (Multiple Lines of Text)
  - `solar_active` (Two Options)

- **Relationships**:
  - **Multi-Value**: `solar_zones` (N:N to solar_location) - Implemented via separate relationship table
  - **Lookups**: Country, Account, DNO, Users

#### 3.3 Location Zones (`solar_locationzone` - N:N Relationship Table)
- **Purpose**: Many-to-many relationship for location zones
- **Columns**:
  - `solar_location` (Lookup to solar_location)
  - `solar_zone` (Lookup to solar_location)
- **Implementation**: Use native Dataverse N:N relationship

#### 3.4 Sections (`solar_section`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_location` (Lookup to solar_location)
  - `solar_active` (Two Options)

#### 3.5 Warehouses (`solar_warehouse`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_location` (Lookup to solar_location)

---

### Phase 4: Inventory Management (Wave 2 - Day 8-12)
**Priority**: HIGH - Core business functionality

#### 4.1 Equipment (`solar_equipment`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_category` (Lookup to solar_equipmentcategory)
  - `solar_manufacturerid` (Single Line of Text) - Manufacturer part #
  - `solar_manufactureror brand` (Lookup to solar_manufacturerbrand)
  - `solar_supplier` (Lookup to solar_supplier)
  - `solar_stockmanagement` (Two Options) - Default Yes
  - `solar_photo` (Single Line of Text) - File reference
  - `solar_url` (URL)
  - `solar_serial` (Two Options) - Serial tracking enabled
  - `solar_active` (Two Options)

#### 4.2 Parts (`solar_part`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_category` (Lookup to solar_partscategory)
  - `solar_barcode` (Single Line of Text) - Unique
  - `solar_upc` (Single Line of Text) - Unique
  - `solar_manufacturerid` (Single Line of Text)
  - `solar_manufactureror brand` (Lookup to solar_manufacturerbrand)
  - `solar_supplier` (Lookup to solar_supplier)
  - `solar_stockmanagement` (Two Options) - Default Yes
  - `solar_consumable` (Two Options) - Default Yes
  - `solar_minqty` (Whole Number) - Minimum quantity threshold
  - `solar_active` (Two Options)

#### 4.3 Assets (`solar_asset`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_category` (Lookup to solar_assetscategory)
  - `solar_location` (Lookup to solar_location)
  - `solar_section` (Lookup to solar_section)
  - `solar_serialnumber` (Single Line of Text)
  - `solar_manufactureror brand` (Lookup to solar_manufacturerbrand)
  - `solar_installationdate` (Date Only)
  - `solar_warrantyexpiry` (Date Only)
  - `solar_active` (Two Options)

#### 4.4 Equipment Serial (`solar_equipmentserial`)
- **Primary Name**: `solar_serialnumber`
- **Key Columns**:
  - `solar_serialnumber` (Single Line of Text) - Unique, Required
  - `solar_equipment` (Lookup to solar_equipment)
  - `solar_location` (Lookup to solar_location)
  - `solar_section` (Lookup to solar_section)
  - `solar_installationdate` (Date Only)
  - `solar_status` (Choice: Active, Inactive, Maintenance, Retired)

---

### Phase 5: Warehouse & Stock Management (Wave 3 - Day 10-15)
**Priority**: MEDIUM - Inventory tracking

#### 5.1 Equipment To Warehouse (`solar_equipmenttowarehouse`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_equipment` (Lookup to solar_equipment)
  - `solar_warehouse` (Lookup to solar_warehouse)
  - `solar_quantity` (Whole Number)
  - `solar_minquantity` (Whole Number)
- **Purpose**: Track equipment stock levels by warehouse

#### 5.2 Warehouse Equipment Serial (`solar_warehouseequipmentserial`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_equipment` (Lookup to solar_equipment)
  - `solar_warehouse` (Lookup to solar_warehouse)
  - `solar_serialnumber` (Single Line of Text) - Unique
  - `solar_status` (Choice: In Stock, In Use, Maintenance, Disposed)

#### 5.3 Parts Transaction (`solar_partstransaction`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_part` (Lookup to solar_part)
  - `solar_transactiontype` (Choice: In, Out, Transfer, Adjustment)
  - `solar_quantity` (Whole Number)
  - `solar_fromwarehouse` (Lookup to solar_warehouse)
  - `solar_towarehouse` (Lookup to solar_warehouse)
  - `solar_transactiondate` (Date Only) - Default Today

#### 5.4 Stock Adjustments (`solar_stockadjustment`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_itemtype` (Choice: Part, Equipment)
  - `solar_part` (Lookup to solar_part)
  - `solar_equipment` (Lookup to solar_equipment)
  - `solar_warehouse` (Lookup to solar_warehouse)
  - `solar_adjustmenttype` (Choice: Increase, Decrease, Recount)
  - `solar_quantity` (Whole Number)
  - `solar_adjustmentdate` (Date Only) - Default Today
  - `solar_reason` (Multiple Lines of Text)

#### 5.5 Equipment Transaction (`solar_equipmenttransaction`) **COMPLEX - 22 columns**
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_warehouse` (Single Line of Text) - Legacy
  - `solar_tasktype` (Choice: Choice, Corrective, Preventative, Repower, Service)
  - `solar_jobid` (Single Line of Text)
  - `solar_handlingdate` (Date Only) - Default Today
  - `solar_recordtype` (Choice: In, Out) - Default In
  - `solar_reason` (Choice: Failure, Move, Install, Uninstall, Service, Other)
  - `solar_towarehouse` (Single Line of Text) - Legacy
  - `solar_quantity` (Decimal Number) - Required
  - `solar_currentquantity` (Decimal Number)
  - `solar_equipmentid` (Single Line of Text)
  - `solar_location` (Lookup to solar_location)
  - `solar_category` (Lookup to solar_equipmentcategory)
  - `solar_serial` (Two Options)
  - `solar_serialnotes` (Single Line of Text)
  - **Legacy IDs**: Multiple text fields for backward compatibility

#### 5.6 Warehouse To Location (`solar_warehousetolocation`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_warehouse` (Lookup to solar_warehouse)
  - `solar_location` (Lookup to solar_location)

#### 5.7 Tracking Serial (`solar_trackingserial`)
- **Primary Name**: Auto-number
- **Key Columns**:
  - `solar_trid` (Single Line of Text)
  - `solar_eid` (Single Line of Text)
  - `solar_guid` (Single Line of Text)
  - `solar_wid` (Single Line of Text)
  - `solar_warehouse` (Lookup to solar_warehouse)

---

### Phase 6: Location Configuration (Wave 3 - Day 13-16)

#### 6.1 Location Configuration (`solar_locationconfiguration`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_location` (Lookup to solar_location)
  - `solar_itemtype` (Lookup to solar_locationconfigitemtype)
  - `solar_quantity` (Whole Number)
  - `solar_active` (Two Options)

---

### Phase 7: Maintenance & Tasks (Wave 3 - Day 14-20)
**Priority**: HIGH - Core maintenance functionality

#### 7.1 Corrective Tasks Template (`solar_correctivetask`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_category` (Lookup to solar_correctivetaskcategory)
  - `solar_omcategory` (Lookup to solar_omcategory)
  - `solar_frequency` (Choice: As needed, 2 years) - Default "As needed"
  - `solar_maintenanceteamcategory` (Lookup to solar_maintenanceteamcategory)
  - `solar_warrantytype` (Choice: N/A, EPC, Inverter, Module (Product), Monitoring)
  - `solar_applicableunit` (Choice: Acres, Block, Combiner Box, Inverter, Module, MW, Site, String, Tracker, Transformer)
  - `solar_active` (Two Options)

#### 7.2 Corrective Events (`solar_correctiveevent`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_location` (Lookup to solar_location)
  - `solar_category` (Lookup to solar_correctivetaskcategory)
  - `solar_priority` (Choice: Critical, High, Normal, Low) - Default Normal
  - `solar_status` (Choice: Reported, In Progress, Completed, Cancelled) - Default Reported
  - `solar_reporteddate` (Date Only) - Default Today
  - `solar_duedate` (Date Only)
  - `solar_assignedteam` (Lookup to solar_maintenanceteam)
  - `solar_assignedto` (Lookup to User, Multi-Select)
  - `solar_completeddate` (Date Only)
- **Business Rules**: 
  - Auto-calculate overdue status
  - Status workflow validation

#### 7.3 Sub Corrective Event (`solar_subcorrectiveevent`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_correctiveevent` (Lookup to solar_correctiveevent)
  - `solar_category` (Lookup to solar_correctivetaskcategory)
  - `solar_priority` (Choice: High, Normal, Low)
  - `solar_status` (Choice: Open, In Progress, Completed, Cancelled)
  - `solar_assignedto` (Lookup to User, Multi-Select)
  - `solar_duedate` (Date Only)

#### 7.4 Preventive Plan (`solar_preventiveplan`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_location` (Lookup to solar_location)
  - `solar_frequency` (Choice: Daily, Weekly, Monthly, Quarterly, Semi-Annual, Annual)
  - `solar_startdate` (Date Only)
  - `solar_nextduedate` (Date Only)
  - `solar_assignedteam` (Lookup to solar_maintenanceteam)
  - `solar_active` (Two Options)

#### 7.5 Preventive Tasks (`solar_preventivetask`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_plan` (Lookup to solar_preventiveplan)
  - `solar_category` (Lookup to solar_preventivetaskcategory)
  - `solar_status` (Choice: Scheduled, In Progress, Completed, Skipped)
  - `solar_scheduleddate` (Date Only)
  - `solar_completeddate` (Date Only)
  - `solar_assignedto` (Lookup to User, Multi-Select)

#### 7.6 Tasks (`solar_task`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_priority` (Choice: High, Normal, Low) - Default Normal
  - `solar_status` (Choice: Not Started, In Progress, Completed, Deferred, Waiting) - Default "Not Started"
  - `solar_percentcomplete` (Whole Number, 0-100) - Default 0
  - `solar_assignedto` (Lookup to User, Multi-Select)
  - `solar_taskgroup` (Lookup to User)
  - `solar_startdate` (Date Only) - Default Today
  - `solar_duedate` (Date Only)

#### 7.7 Task Predecessors (`solar_taskpredecessor` - N:N Relationship)
- **Purpose**: Many-to-many for task dependencies
- **Implementation**: N:N relationship between solar_task and solar_task

---

### Phase 8: Service Management (Wave 4 - Day 18-22)

#### 8.1 Service (`solar_service`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_code` (Single Line of Text) - Unique
  - `solar_category` (Lookup to solar_omcategory)
  - `solar_defaultservicecompany` (Lookup to solar_servicecompany)
  - `solar_unitcost` (Currency)
  - `solar_active` (Two Options)

#### 8.2 Service Order (`solar_serviceorder`)
- **Primary Name**: `solar_ordernumber` (Unique)
- **Key Columns**:
  - `solar_ordernumber` (Single Line of Text) - Unique, Required
  - `solar_servicecompany` (Lookup to solar_servicecompany)
  - `solar_location` (Lookup to solar_location)
  - `solar_orderdate` (Date Only) - Default Today
  - `solar_scheduleddate` (Date Only)
  - `solar_status` (Choice: Draft, Ordered, In Progress, Completed, Cancelled) - Default Draft
  - `solar_priority` (Choice: High, Normal, Low) - Default Normal

---

### Phase 9: Team Management (Wave 4 - Day 20-24)

#### 9.1 Maintenance Team Members (`solar_maintenanceteammember`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_maintenanceteam` (Lookup to solar_maintenanceteam)
  - `solar_member` (Lookup to User)
  - `solar_role` (Choice: Team Leader, Technician, Helper, Supervisor)
  - `solar_startdate` (Date Only)
  - `solar_enddate` (Date Only)
  - `solar_active` (Two Options)

#### 9.2 Maintenance Team Per Location (`solar_maintenanceteamperlocation`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_maintenanceteam` (Lookup to solar_maintenanceteam)
  - `solar_location` (Lookup to solar_location)
  - `solar_startdate` (Date Only)
  - `solar_enddate` (Date Only)
  - `solar_active` (Two Options)

---

### Phase 10: Documents & Miscellaneous (Wave 4 - Day 22-25)

#### 10.1 Document Sets (`solar_documentset`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_category` (Lookup to solar_documentsetcategory)
  - `solar_comments` (Multiple Lines of Text, Rich Text)

#### 10.2 Published Feed (`solar_publishedfeed`)
- **Primary Name**: `solar_name`
- **Key Columns**:
  - `solar_body` (Multiple Lines of Text, Rich Text)
  - `solar_publisheddate` (Date and Time)

#### 10.3 Site Collection Documents (`solar_sitecollectiondocument`)
- **Primary Name**: `solar_fileleafref`
- Standard document library functionality

---

## Relationship Summary (73 Total Lookups)

### Master Data Relationships (4)
1. Accounts → Countries
2. Locations → Countries
3. Locations → DNO
4. Locations → Accounts

### Self-Referencing (Hierarchical) Relationships (8)
5. EquipmentCategories → EquipmentCategories (Parent)
6. PartsCategories → PartsCategories (Parent)
7. AssetsCategories → AssetsCategories (Parent)
8. CorrectiveTaskCategories → CorrectiveTaskCategories (Parent)
9. PreventiveTaskCategories → PreventiveTaskCategories (Parent)
10. OMCategories → OMCategories (CategoryParent)
11. MaintenanceTeamCategories → MaintenanceTeamCategories (Parent)
12. PreventivePlanCategories → PreventivePlanCategories (Parent)

### Multi-Value Relationships (2)
13. Locations → Locations (Zones) - N:N
14. Tasks → Tasks (Predecessors) - N:N

### Inventory Relationships (13)
15. Equipment → EquipmentCategories
16. Equipment → ManufacturerBrands
17. Equipment → Suppliers
18. Parts → PartsCategories
19. Parts → ManufacturerBrands
20. Parts → Suppliers
21. Assets → AssetsCategories
22. Assets → Locations
23. Assets → Sections
24. Assets → ManufacturerBrands
25. EquipmentSerial → Equipment
26. EquipmentSerial → Locations
27. EquipmentSerial → Sections

### Warehouse Relationships (10)
28. Warehouses → Locations
29. EquipmentToWarehouse → Equipment
30. EquipmentToWarehouse → Warehouses
31. WarehouseEquipmentSerial → Equipment
32. WarehouseEquipmentSerial → Warehouses
33. PartsTransaction → Parts
34. PartsTransaction → Warehouses (From)
35. PartsTransaction → Warehouses (To)
36. StockAdjustments → Parts
37. StockAdjustments → Equipment
38. StockAdjustments → Warehouses
39. EquipmentTransaction → Locations
40. EquipmentTransaction → EquipmentCategories
41. TrackingSerial → Warehouses
42. WarehouseToLocation → Warehouses
43. WarehouseToLocation → Locations

### Location & Section Relationships (2)
44. Sections → Locations
45. LocationConfiguration → Locations
46. LocationConfiguration → LocationConfigurationItemTypes

### Maintenance Relationships (14)
47. CorrectiveTasks → CorrectiveTaskCategories
48. CorrectiveTasks → OMCategories
49. CorrectiveTasks → MaintenanceTeamCategories
50. CorrectiveEvents → Locations
51. CorrectiveEvents → CorrectiveTaskCategories
52. CorrectiveEvents → MaintenanceTeams
53. SubCorrectiveEvent → CorrectiveEvents
54. SubCorrectiveEvent → CorrectiveTaskCategories
55. PreventivePlan → Locations
56. PreventivePlan → MaintenanceTeams
57. PreventiveTasks → PreventivePlan
58. PreventiveTasks → PreventiveTaskCategories

### Service Relationships (4)
59. Service → OMCategories
60. Service → ServiceCompanys
61. ServiceOrder → ServiceCompanys
62. ServiceOrder → Locations

### Team Management Relationships (4)
63. MaintenanceTeamMembers → MaintenanceTeams
64. MaintenanceTeamPerLocation → MaintenanceTeams
65. MaintenanceTeamPerLocation → Locations

### Document Relationships (1)
66. DocumentSets → DocumentSetCategories

### Cascade Behavior Recommendations
- **Master Data → Transactional**: Restrict Delete (prevent orphaned records)
- **Parent-Child (e.g., CorrectiveEvent → SubCorrectiveEvent)**: Cascade Delete
- **Self-Referencing**: Remove Link (set null)
- **User Lookups**: Remove Link (preserve records if user deleted)

---

## Security Roles

### 1. Solar Plant Administrator
**Permissions**: Full CRUD on all tables
- Create, Read, Update, Delete: Organization-level
- Share: Organization-level
- Append, Append To: Organization-level

### 2. Solar Plant Manager
**Permissions**: Manage locations and maintenance
- Create, Read, Update: Business Unit-level
- Delete: User-level (own records only)
- Full access to Locations, CorrectiveEvents, PreventiveTasks, ServiceOrders
- Read-only access to master data

### 3. Maintenance Technician
**Permissions**: Execute maintenance tasks
- Read: Business Unit-level
- Update: User-level (assigned tasks only)
- Full access to CorrectiveEvents, PreventiveTasks (assigned records)
- Read-only access to Equipment, Parts, Locations
- Update stock levels in warehouses

### 4. Read-Only Viewer
**Permissions**: View-only access
- Read: Business Unit-level
- No Create, Update, or Delete

---

## Business Rules & Workflows

### Calculated Fields
1. **Equipment.CategoryType**: Derived from Equipment.Category.CategoryType (Rollup)
2. **CorrectiveEvent.Overdue**: Calculated based on DueDate < Today AND Status NOT IN ('Completed', 'Cancelled')
3. **PreventivePlan.NextDueDate**: Calculated based on Frequency and last completed task

### Required Field Validations
1. All tables: Title/Name is required
2. Equipment/Parts: Code must be unique if provided
3. CorrectiveEvent: Location and Category required
4. ServiceOrder: OrderNumber must be unique

### Choice Dependencies
1. **StockAdjustments.ItemType**: If "Part", require Part lookup; if "Equipment", require Equipment lookup
2. **EquipmentTransaction.Reason**: Based on RecordType (In/Out)

### Workflows (Power Automate)
1. **CorrectiveEvent Creation**: Notify assigned team and users
2. **Stock Below Minimum**: Alert when Equipment/Parts quantity ≤ MinQuantity
3. **PreventiveTask Due**: Generate tasks based on PreventivePlan schedule
4. **ServiceOrder Status**: Notify ServiceCompany when status changes

---

## Model-Driven App Structure

### App Name: Solar Plant Maintenance Hub

#### Area 1: Master Data
**Group**: Reference Data
- Countries
- Suppliers
- Manufacturer Brands
- DNO
- Service Companies

**Group**: Categories
- Equipment Categories
- Parts Categories
- Corrective Task Categories
- Preventive Task Categories
- O&M Categories

#### Area 2: Locations & Assets
**Group**: Sites
- Locations (Map view with GPS coordinates)
- Sections
- Accounts

**Group**: Inventory
- Equipment
- Parts
- Assets
- Equipment Serial Tracking

#### Area 3: Maintenance
**Group**: Corrective Maintenance
- Corrective Events (Active Events dashboard)
- Sub-Tasks
- Corrective Task Templates

**Group**: Preventive Maintenance
- Preventive Plans
- Preventive Tasks
- Schedule Calendar

**Group**: Tasks
- Tasks (Kanban board view)
- Timeline View

#### Area 4: Warehouse
**Group**: Stock Management
- Warehouses
- Equipment Stock Levels
- Parts Transactions
- Stock Adjustments

**Group**: Transactions
- Equipment Transactions
- Tracking Serial

#### Area 5: Service
**Group**: Service Orders
- Service Orders (Active Orders view)
- Service Catalog

#### Area 6: Teams
**Group**: Maintenance Teams
- Teams
- Team Members
- Team Assignments

#### Area 7: Reports
**Group**: Dashboards
- Maintenance Overview
- Stock Levels
- Overdue Tasks
- Location Performance

---

## Migration Steps

### Step 1: Environment Preparation (Day 1)
1. Create Development environment
2. Create Publisher: Name="WIZSP", Prefix="solar"
3. Create Solution: "SolarMaintenanceSystem" v1.0.0.0
4. Enable Audit on all tables

### Step 2: Wave 1 - Master Data Tables (Day 1-5)
1. Create all master data tables (Countries, Suppliers, etc.)
2. Create all hierarchical category tables
3. Configure self-referencing relationships
4. Import master data:
   - Countries (250 records)
   - Suppliers (from existing data)
   - Manufacturers (from existing data)
   - Categories (hierarchical - top-down)

### Step 3: Wave 2 - Accounts & Locations (Day 5-10)
1. Create Accounts table
2. Create Locations table (73 columns)
3. Create LocationZones N:N relationship
4. Create Sections and Warehouses tables
5. Import account data
6. Import location data with full specifications
7. Link zones

### Step 4: Wave 2 - Inventory Tables (Day 8-12)
1. Create Equipment, Parts, Assets tables
2. Create EquipmentSerial table
3. Configure relationships
4. Import equipment master data
5. Import parts master data
6. Import assets with serial numbers

### Step 5: Wave 3 - Warehouse & Stock (Day 10-15)
1. Create warehouse junction tables
2. Create transaction tables
3. Import initial stock levels
4. Configure stock alerts

### Step 6: Wave 3 - Maintenance Tables (Day 14-20)
1. Create CorrectiveTasks, CorrectiveEvents, SubCorrectiveEvent
2. Create PreventivePlan, PreventiveTasks
3. Create Tasks with Predecessors N:N
4. Import task templates
5. Migrate historical events

### Step 7: Wave 4 - Service & Teams (Day 18-24)
1. Create Service and ServiceOrder tables
2. Create team membership tables
3. Import service catalog
4. Import team assignments

### Step 8: Wave 4 - Documents (Day 22-25)
1. Create DocumentSets and PublishedFeed
2. Migrate document references
3. Set up SharePoint integration (if needed)

### Step 9: Business Logic (Day 25-30)
1. Create calculated fields
2. Implement business rules
3. Create Power Automate workflows:
   - Event notifications
   - Stock alerts
   - Task scheduling
   - Status updates

### Step 10: Model-Driven App (Day 30-35)
1. Create app shell with site map
2. Create forms for each table:
   - Main form
   - Quick Create form (where applicable)
   - Quick View forms
3. Create views:
   - Active records
   - My records
   - Custom filtered views
4. Create dashboards:
   - Maintenance Overview
   - Stock Levels
   - Overdue Tasks
   - Location Performance

### Step 11: Security (Day 35-37)
1. Create security roles
2. Assign field-level security (if needed)
3. Configure sharing
4. Test access levels

### Step 12: Testing (Day 37-45)
1. Unit testing per table
2. Integration testing across relationships
3. Workflow testing
4. Performance testing
5. User Acceptance Testing (UAT)

### Step 13: Training & Go-Live (Day 45-50)
1. Train administrators
2. Train end users
3. Prepare cutover plan
4. Execute data migration
5. Go live
6. Hypercare support (2 weeks)

---

## Data Migration Considerations

### Data Volume Estimates
- **Countries**: 250 records
- **Suppliers**: 100-500 records
- **Manufacturers**: 50-200 records
- **Equipment**: 500-2,000 records
- **Parts**: 1,000-5,000 records
- **Locations**: 50-200 sites
- **Assets**: 10,000-50,000 records
- **Transactions**: Historical data (retain 2 years)

### Migration Tools
1. **Configuration Migration Tool**: For reference data
2. **Dataflows**: For large datasets (Equipment, Parts, Assets)
3. **Power Automate**: For incremental updates
4. **Custom C# Console App**: For complex transformations

### Data Quality Rules
1. Validate all Code fields for uniqueness
2. Ensure all required lookups resolve
3. Validate choice field values against schema
4. Check date field formats
5. Validate decimal precision
6. Ensure email/phone/URL formats

---

## Performance Optimization

### Indexing
- All Code fields: Unique index
- All lookup fields: Index
- Commonly filtered fields (Status, Priority, Active): Index

### Rollup Fields (Limit Use)
- EquipmentToWarehouse: Current quantity rollup
- Location: Count of active sections
- CorrectiveEvent: Count of sub-tasks

### Views Optimization
- Limit columns in list views
- Use appropriate filters
- Avoid nested lookups in views

### Form Optimization
- Use tabs to organize 70+ fields (Locations)
- Conditional visibility for dependent fields
- Quick View forms for related records
- Business Process Flows for maintenance workflows

---

## Post-Deployment Enhancements

### Phase 2 Features
1. Mobile app for field technicians
2. Power BI embedded reports
3. Integration with SCADA systems
4. IoT sensor data integration
5. Predictive maintenance using AI
6. Barcode/QR code scanning for equipment

### Integration Points
1. **SharePoint**: Document storage
2. **Power BI**: Advanced analytics
3. **Power Automate**: External system integration
4. **Azure Functions**: Custom processing
5. **External APIs**: Weather data, parts suppliers

---

## Appendix: Quick Reference

### Table Count by Category
- Master Data: 11 tables
- Hierarchical Categories: 8 tables
- Accounts & Locations: 5 tables
- Inventory: 5 tables
- Warehouse & Stock: 7 tables
- Maintenance & Tasks: 6 tables
- Service: 2 tables
- Team Management: 2 tables
- Documents: 3 tables
- **Total**: 37 tables

### Relationship Count by Type
- 1:N Standard Lookups: 59
- Self-Referencing (Hierarchical): 8
- N:N (Multi-Value): 2
- Special (Multi-select User): 6
- **Total**: 73 relationships (+ 2 N:N)

---

**End of Implementation Plan**

**Document Version**: 1.0  
**Last Updated**: January 27, 2026  
**Author**: Solar CMMS Migration Team
