# Solar lists — fields and lookup relationships

This document contains all `solar_` custom lists, their custom fields (attributes), and lookup connections.

---

## solar_corrective_category
- Primary key: `solar_corrective_categoryid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_isactive` (BIT, **Required**)
  - `solar_description` (MULTILINE TEXT)
  - `solar_comments` (TEXT AREA (NVARCHAR(100)))
  - `solar_team` (NVARCHAR(100))
- Lookups: none (custom)

---

## solar_corrective_work_order
- Primary key: `solar_corrective_work_orderid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_code` (NVARCHAR(255))
  - `solar_description` (MULTILINE TEXT)
  - `solar_comments` (TEXT AREA (NVARCHAR(100)))
  - `solar_status` (CHOICE: Open, In Progress, Closed) **Required**
- Lookups:
  - `solar_categoryid` → `solar_corrective_category`
  - `solar_employee` → `new_account`
  - `solar_locationid` → `solar_location`
  - `solar_maintenanceteamid` → `solar_maintenance_team`
  - `solar_team` → `solar_maintenance_team`

---

## solar_inverter
- Primary key: `solar_inverterid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_inverter_manufacturer` (NVARCHAR(100))
  - `solar_inverter_model` (NVARCHAR(100))
  - `solar_inverter_power` (DECIMAL)
  - `solar_inverter_type` (CHOICE: String Inverter, Central Inverter, Power Optimizer, Microinverter)
  - `solar_inverter_total_cost` (MONEY)
  - `solar_warranty_expiry` (DATE)
- Lookups: none (custom)

---

## solar_location
- Primary key: `solar_locationid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_address` (NVARCHAR(500))
  - `solar_city` (NVARCHAR(100))
  - `solar_country` (NVARCHAR(100))
  - `solar_capacity_mw` (DECIMAL)
  - `solar_stage` (CHOICE: Oem, Full, Owend)
  - `solar_inverter_type` (CHOICE: String Inverter, Central Inverter, Power Optimizer, Microinverter)
- Lookups:
  - `solar_account` → `new_account`
  - `solar_parkmanager` → `account`

---

## solar_maintenance_team
- Primary key: `solar_maintenance_teamid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_contactinfo` (NVARCHAR(500))
  - `solar_specialization` (NVARCHAR(255))
  - `solar_isactive` (BIT, **Required**)
- Lookups: none

---

## solar_module
- Primary key: `solar_moduleid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_module_manufacturer` (NVARCHAR(100))
  - `solar_module_model` (NVARCHAR(100))
  - `solar_module_power` (DECIMAL)
  - `solar_module_quantity` (INT)
  - `solar_module_voc` / `solar_module_isc` (DECIMAL)
- Lookups: none

---

## solar_notification
- Primary key: `solar_notificationid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_message` (MULTILINE TEXT, **Required**)
  - `solar_isread` (BIT, **Required**)
  - `solar_type` (CHOICE: Info, Warning, Alert, Critical)
- Lookups: none

---

## solar_solarassetcategory
- Primary key: `solar_solarassetcategoryid` (GUID)
- Fields:
  - `solar_categorytitle` (NVARCHAR(850))
  - `solar_categorydescription` (NVARCHAR(100))
  - `solar_categorylevel` (CHOICE)
  - `solar_parentcategoryreference` (NVARCHAR(100))
- Lookups: none

---

## solar_solarcountry
- Primary key: `solar_solarcountryid` (GUID)
- Fields:
  - `solar_countryname` (NVARCHAR(850))
  - `solar_countryalpha2code` (NVARCHAR(100))
  - `solar_countryalpha3code` (NVARCHAR(100))
- Lookups: none

---

## solar_solarinverter
- Primary key: `solar_solarinverterid` (GUID)
- Fields:
  - `solar_invertername` (NVARCHAR(850))
  - `solar_manufacturer` (NVARCHAR(100))
  - `solar_model` (NVARCHAR(100))
  - `solar_poweroutput` (DECIMAL)
  - `solar_quantity` (INT)
  - `solar_warrantyperiodyears` (INT)
- Lookups:
  - `solar_park` → `solar_location`

---

## solar_solarmodule
- Primary key: `solar_solarmoduleid` (GUID)
- Fields:
  - `solar_modulename` (NVARCHAR(850))
  - `solar_solarmodulemanufacturer` (NVARCHAR(100))
  - `solar_solarmodulemodel` (NVARCHAR(100))
  - `solar_powerratingw` (DECIMAL)
  - `solar_quantity` (INT)
- Lookups:
  - `solar_park` → `solar_location`

---

## solar_solarpreventiveplan
- Primary key: `solar_solarpreventiveplanid` (GUID)
- Fields:
  - `solar_plantitle` (NVARCHAR(850))
  - `solar_plancode` (NVARCHAR(100))
  - `solar_plandays` (INT)
  - `solar_plandescription` (TEXT AREA)
  - `solar_planrecurrence` (CHOICE)
- Lookups:
  - `solar_plancategory` → `solar_solarpreventiveplancategory`
  - `solar_planlocation` → `solar_location`

---

## solar_solarpreventivetask
- Primary key: `solar_solarpreventivetaskid` (GUID)
- Fields:
  - `solar_preventivetitle` (NVARCHAR(850))
  - `solar_preventivecode` (NVARCHAR(100))
  - `solar_taskimportance` (CHOICE: Low, Medium, High)
  - `solar_taskfrequency` (CHOICE)
- Lookups:
  - `solar_park` → `solar_location`
  - `solar_solarpreventivetaskcategory` → `solar_solarpreventivetaskcategory`

---

## solar_solarpreventivetaskcategory
- Primary key: `solar_solarpreventivetaskcategoryid` (GUID)
- Fields:
  - `solar_preventivecategorytitle` (NVARCHAR(100))
  - `solar_preventivecategorydescription` (TEXT AREA)
  - `solar_isactive` (BIT)
- Lookups: none

---

## solar_task
- Primary key: `solar_taskid` (GUID)
- Fields:
  - `solar_name` (NVARCHAR(100), **Required**)
  - `solar_description` (MULTILINE TEXT)
  - `solar_estimatedhours` (INT)
  - `solar_priority` (CHOICE: Low, Medium, High, Critical)
- Lookups:
  - `solar_workorderid` → `solar_corrective_work_order`

---

> Notes:
> - Only custom fields (`solar_` prefix) are included; standard system fields (createdon, modifiedon, ownerid, etc.) were excluded per request.
> - Lookup targets were taken from the table descriptions (e.g., `Related table : <name>`).

