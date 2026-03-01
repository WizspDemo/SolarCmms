# Πρόταση Συγχρονισμού Dataverse με SharePoint Schema

**Σκοπός:** Αλλαγή/δημιουργία πινάκων και σχέσεων στο Dataverse ώστε να ευθυγραμμιστεί με το SharePoint schema, με **Locations** (solar_location) ως **βασικό πίνακα Solar Plant** — όχι PVPlants.

**Πηγές:**
- SharePoint: `SolarCmmsDemo/Sharepoint/PreFinal schema/schema.dbml` (80 πίνακες)
- Dataverse: `SolarCmmsDemo/dataverse/schema/solardev_schema.dbml` (16 πίνακες)

**Γιατί ~21 και όχι 80;**  
Η πρόταση είναι **Φάση 1**: κεντρικό entity το Locations (solar_location), πίνακες που αφορούν απευθείας plant/site, corrective–preventive, DNO, sections, credentials, σχόλια. Τα υπόλοιπα (Equipment, Parts, αποθήκες, κινήσεις, έγγραφα, BGE/showcase lists κ.λπ.) μπορούν να προστεθούν σε **Φάση 2** ή να παραμείνουν μόνο στο SharePoint. Παρακάτω (§ 1.1) υπάρχει πλήρης αντιστοίχιση και των 80 πινάκων.

---

## 1. Κεντρική αρχή: Locations = Solar Plant

| SharePoint | Dataverse | Σημείωση |
|------------|-----------|----------|
| **Locations** | **solar_location** | Βασικό entity για Solar Plants (PV Sites). Όλες οι σχέσεις “ανά Plant” αναφέρονται εδώ. |
| PVPlants | — | **Δεν** χρησιμοποιείται ως κεντρικό entity. Τα δεδομένα που αφορούν plant/site αντιστοιχούν στο Locations/solar_location. |

Όπου στο SharePoint υπάρχει αναφορά σε **PVPlants** ή **PlantId**, στο Dataverse η αντίστοιχη σχέση γίνεται προς **solar_location** (solar_locationid).

### 1.1 Πλήρης αντιστοίχιση 80 πινάκων SharePoint → Dataverse

| # | SharePoint Table | Κατάσταση | Dataverse / Σημείο |
|---|------------------|-----------|--------------------|
| 1 | Locations | **Φάση 1** | solar_location (τροποποιήσεις) |
| 2 | PVPlants | Δεν ως κεντρικό | Δεδομένα στο solar_location |
| 3 | DNO | **Φάση 1** | solar_dno (νέο) |
| 4 | DNOs | Διπλότυπο SP | Ίδιο νόημα με DNO → solar_dno |
| 5 | Countries | **Υπάρχει** | solar_solarcountry |
| 6 | CorrectiveTaskCategories | **Υπάρχει** | solar_corrective_category |
| 7 | CorrectiveEvents | **Υπάρχει** | solar_corrective_work_order |
| 8 | CorrectiveTasks | **Υπάρχει** | solar_task (+ categories) |
| 9 | PreventivePlan | **Υπάρχει** | solar_solarpreventiveplan |
| 10 | PreventiveTasks | **Υπάρχει** | solar_solarpreventivetask |
| 11 | PreventiveTaskCategories | **Υπάρχει** | solar_solarpreventivetaskcategory / solar_solarpreventiveplancategory |
| 12 | MaintenanceTeams | **Υπάρχει** | solar_maintenance_team |
| 13 | MaintenanceTeamPerLocation | **Φάση 1** | solar_maintenance_team_per_location (νέο) |
| 14 | Sections | **Φάση 1** | solar_section (νέο) |
| 15 | PVPlantsSiteCredentials | **Φάση 1** | solar_site_credentials (νέο) |
| 16 | CommentsRemarks | **Φάση 1** | solar_site_comments (νέο) |
| 17 | Accounts | **Υπάρχει** | account |
| 18 | Clients | **Υπάρχει** | new_account |
| 19 | EquipmentCategories | **Πρόταση §3** | solar_solarassetcategory ή solar_equipment_category |
| 20 | PartsCategories | Φάση 2 | solar_part_category (πρόταση §3) |
| 21 | ManufacturerBrands | Φάση 2 | solar_manufacturer_brand (πρόταση §3) |
| 22 | Suppliers | Φάση 2 | solar_supplier (πρόταση §3) |
| 23 | Warehouses | Φάση 2 | solar_warehouse (πρόταση §3) |
| 24 | Equipment | Φάση 2 | — |
| 25 | Parts | Φάση 2 | — |
| 26 | DeviceChannels | Φάση 2 | — |
| 27 | Assets | Φάση 2 | — |
| 28 | AssetsCategories | Φάση 2 | solar_solarassetcategory / equipment category |
| 29 | Tasks | **Υπάρχει** | solar_task |
| 30 | SectionTemplatemistakenlynamedSections | Φάση 2 | Σχετίζεται με Sections / solar_section |
| 31 | LocationConfiguration | Φάση 2 | Child solar_location ή ξεχωριστό |
| 32 | LocationConfigurationItemTypes | Φάση 2 | — |
| 33 | WarehouseToLocation | Φάση 2 | Με solar_location + solar_warehouse |
| 34 | WarehouseEquipmentSerial | Φάση 2 | — |
| 35 | EquipmentSerial | Φάση 2 | — |
| 36 | EquipmentToWarehouse | Φάση 2 | — |
| 37 | PartsTransaction | Φάση 2 | — |
| 38 | StockAdjustments | Φάση 2 | — |
| 39 | EquipmentTransaction | Φάση 2 | — |
| 40 | SubCorrectiveEvent | Φάση 2 | Υπο-γεγονότα corrective |
| 41 | MaintenanceTeamMembers | Φάση 2 | — |
| 42 | MaintenanceTeamCategories | Φάση 2 | — |
| 43 | ServiceCompanys | Φάση 2 | — |
| 44 | OMCategories | Φάση 2 | — |
| 45 | ServiceOrder | Φάση 2 | — |
| 46 | Service / Services | Φάση 2 | — |
| 47 | SectionTemplate | Φάση 2 | — |
| 48 | DocumentSetCategories | Φάση 2 | Έγγραφα |
| 49 | DocumentSets | Φάση 2 | Έγγραφα |
| 50 | PreventivePlanCategories | Φάση 2 | solar_solarpreventiveplancategory |
| 51 | SiteCollectionDocuments | Φάση 2 | Έγγραφα |
| 52 | PublishedFeed | Ειδικό | Ρυθμίσεις / feed |
| 53 | Settings | Ειδικό | Ρυθμίσεις |
| 54 | PVPlantsCCTVGateCodes | Φάση 2 | Child solar_location (πρόταση §5) |
| 55 | PVPlantsDNOStations | Φάση 2 | Child solar_location (πρόταση §5) |
| 56 | PVPlantsContactInfo | Φάση 2 | solar_location ή ξεχωριστό |
| 57 | PVPlantsSystemInfo | Φάση 2 | solar_location ή ξεχωριστό |
| 58 | EquipmentTracking | Φάση 2 | Location → solar_location (πρόταση §5) |
| 59 | PlantPreventative | Φάση 2 | Σχετίζεται με preventive plans |
| 60 | Strings | Φάση 2 | Τεχνικά (strings PV) |
| 61 | AssetCategories | Φάση 2 | Διπλότυπο SP; Asset categories |
| 62 | DocumentsToFill | Φάση 2 | Έγγραφα |
| 63 | DailyDocs | Φάση 2 | Έγγραφα |
| 64 | ContentandStructureReports | Φάση 2 | Reports |
| 65 | PeriodicScheduledActions | Φάση 2 | — |
| 66 | SLALevels | Φάση 2 | — |
| 67 | TranslationStatus | Φάση 2 | — |
| 68 | BGEOwnedSpares | BGE/showcase | Ειδικό project |
| 69 | BGEOwnedSparesTracking | BGE/showcase | Ειδικό project |
| 70 | PlantRemedials | BGE/showcase | Ειδικό project |
| 71 | RemedialDocs | BGE/showcase | Έγγραφα remedial |
| 72 | PVGroup | BGE/showcase | — |
| 73 | SCB | BGE/showcase | — |
| 74 | PlantPreventativeCopy | BGE/showcase | — |
| 75 | CategoriesPerFarm | BGE/showcase | — |
| 76 | Contracts | Φάση 2 | — |
| 77 | ContactInfoMisc | Φάση 2 | — |
| 78 | HealthAndSafetyOnsite | Φάση 2 | — |
| 79 | PlantEngineer | Φάση 2 | — |

**Σύνοψη:** ~21 entities καλύπτονται ρητά στη Φάση 1 (16 υπάρχοντα + 5 νέα). Τα υπόλοιπα είναι είτε **Φάση 2** (Equipment, Parts, αποθήκες, κινήσεις, έγγραφα, ρυθμίσεις ανά site), είτε **BGE/showcase-specific** (BGEOwnedSpares, PlantRemedials κ.λπ.) που μπορούν να μείνουν μόνο στο SharePoint ή να προστεθούν αργότερα.

---

## 2. Τροποποιήσεις σε υπάρχοντες πίνακες (Dataverse)

### 2.1 solar_location (αντίστοιχο του Locations)

**Προσθήκη attributes** ώστε να καλύπτει τα πεδία του SharePoint **Locations** που λείπουν ή διαφέρουν:

| Νέο/τροποποιημένο attribute (Dataverse) | SharePoint Column (Locations) | Τύπος | Σημείωση |
|----------------------------------------|-------------------------------|--------|----------|
| solar_code | Code | SingleLine (255), Unique | κωδικός τοποθεσίας |
| solar_annualoutputgwh | Annual Output GWh | Decimal | ετήσια παραγωγή GWh |
| solar_zones | Zones | Lookup → solar_location (self) | πολλαπλή τιμή, self-ref |
| solar_contains_sections | Contains Sections | Boolean | έχει τμήματα |
| solar_description | Description | Multiline | περιγραφή |
| solar_landsizehectares | Land Size Hectares | Decimal | έκταση σε hectares |
| solar_addressdescription | Address Description | Multiline | περιγραφή διεύθυνσης |
| solar_googleearth | GoogleEarth | URL | link χάρτη |
| solar_embedmap | Embed Map | Multiline | embed iframe χάρτη |
| solar_what3words | What3Words | SingleLine | What3Words |
| solar_grazed | Grazed | Boolean | βοσκότοπος |
| solar_landownerfarmerdetails | Land Owner/Farmer Details | Multiline | λεπτομέρειες ιδιοκτήτη |
| solar_inverter* (υπάρχουν μερικά) | — | — | ελέγχω τι υπάρχει vs Locations |
| solar_modulemanufacturer, solar_modulemodel, solar_modulequantity, solar_modulepower | Module* | SingleLine/Decimal | από Locations |
| solar_modulevoc, solar_moduleisc, solar_modulelength, solar_modulewidth, solar_moduledepth, solar_modulestructure | Module* | κατά column | από Locations |
| solar_satellite3g4g | Satellite/3G/4G | SingleLine | |
| solar_lannetwork | LAN Network | SingleLine | |
| solar_scadaprovider | SCADA Provider | SingleLine | |
| solar_adasinstalled | ADAS Installed | Boolean | |
| solar_dataloggers | Data Loggers | SingleLine | |
| solar_dnogridoperator | DNO Grid Operator | Lookup → νέο solar_dno ή εξωτερικό | |
| solar_dnosizekv, solar_dnocontact, solar_dnocontact2, solar_dnocontact3 | DNO* | SingleLine/Multiline | |
| solar_sitereferencenumber | Site Reference Number | SingleLine | |
| solar_hvcontractor | HV Contractor | SingleLine | |
| solar_tbootsub | T-Boot/sub | SingleLine | |
| solar_transformerquantity, solar_transformermake, solar_transformermodel, solar_transformerratingkva | Transformer* | κατά column | |
| solar_security | Security | SingleLine | |
| solar_securitycodes, solar_siteaccessdetails, solar_accessgatecodes | Security/Access | Multiline | |
| solar_exportmeterlocation | Export Meter Location | SingleLine | |
| solar_exportmeteraccessdetails | Export Meter Access Details | Multiline | |
| solar_supervisor | Supervisor | Lookup → systemuser/contact | Person or Group |
| solar_otherinformation | Other Information | Multiline | |
| solar_notes | Notes | Multiline | |
| solar_active | Active | Boolean | |

**Υπάρχοντα στο solar_location που αντιστοιχούν:**  
solar_name, solar_address, solar_city, solar_postalcode, solar_state, solar_country, solar_opendate, solar_closedate, solar_stage, solar_capacity_mw, solar_stockmanagement, solar_account, solar_parkmanager, solar_assumed_warranty_period, solar_warranty_expiry, solar_estimated_expiry, solar_inverter_*, solar_containssections, solar_landsizekm (→ προτεινόμενο solar_landsizehectares αν χρειάζεται).

**Σχέσεις που πρέπει να υπάρχουν (ή να προστεθούν):**
- solar_location.solar_country → solar_solarcountry (αν υπάρχει πίνακας χωρών· αλλιώς Country ως lookup ή OptionSet).
- solar_location.solar_zones → solar_location (self-reference, πολλαπλές τιμές).
- solar_location.solar_dnogridoperator → νέο entity solar_dno (ή εξωτερικό DNO αν υπάρχει).

---

### 2.2 Άλλοι υπάρχοντες πίνακες – συνοπτικές προτάσεις

| Dataverse Table | Τι να ελέγξεις/προσθέσεις | SharePoint αντίστοιχο |
|------------------|---------------------------|------------------------|
| solar_corrective_category | Δεν αλλάζει λογική· ιεραρχία Parent αν χρειάζεται | CorrectiveTaskCategories |
| solar_corrective_work_order | Location = solar_locationid (έχει ήδη). Να μην αναφέρεται σε PVPlants | CorrectiveEvents |
| solar_maintenance_team | Όπως είναι· σχέσεις προς location μέσω corrective/preventive | MaintenanceTeams |
| solar_solarassetcategory | — | AssetsCategories / EquipmentCategories |
| solar_solarcountry | Χρήση ως lookup για solar_location.solar_country | Countries |
| solar_solarinverter | solar_park → solar_location (ήδη). Μην αλλάζεις σε PVPlants | — |
| solar_solarmodule | solar_park → solar_location (ήδη) | — |
| solar_solarpreventiveplan | solar_planlocation → solar_location (ήδη) | PreventivePlan |
| solar_solarpreventiveplancategory | — | PreventiveTaskCategories |
| solar_solarpreventivetask | solar_park → solar_location (ήδη) | PreventiveTasks |
| solar_solarpreventivetaskcategory | — | PreventiveTaskCategories |
| solar_task | solar_workorderid → corrective work order (ήδη) | Tasks |
| account / new_account | Χρήση για Manager, Account, Supervisor στη θέση “PVPlants Client” | Accounts, Clients |

Καμία αλλαγή σε “primary entity” από PVPlants προς Locations δεν απαιτείται στα ήδη υπάρχοντα relations, γιατί ήδη τα solar_* αναφέρονται σε solar_location (solar_park / solar_planlocation / solar_locationid).

---

## 3. Νέοι πίνακες προς δημιουργία στο Dataverse

Όταν το εργαλείο/διαδικασία σου δέχεται “δημιουργία νέου πίνακα”, προτείνονται με βάση το SharePoint schema (με Locations ως κεντρικό Solar Plant):

| Προτεινόμενο Entity (Dataverse) | SharePoint Table | Σχέση με solar_location | Σκοπός |
|----------------------------------|-------------------|---------------------------|--------|
| solar_dno | DNO | Lookup από solar_location (solar_dnogridoperator) | DNO/Grid operators, επικοινωνία |
| solar_section | Sections | Lookup Location → solar_location | Τμήματα ανά site (strings, inverters κ.λπ.) |
| solar_warehouse | Warehouses | Lookup Location → solar_location (όπου χρειάζεται) | Αποθήκες ανά location |
| solar_equipment_category | EquipmentCategories | — | Κατηγορίες εξοπλισμού |
| solar_part_category | PartsCategories | — | Κατηγορίες ανταλλακτικών |
| solar_supplier | Suppliers | — | Προμηθευτές |
| solar_manufacturer_brand | ManufacturerBrands | — | Κατασκευαστές/μάρκες |
| solar_corrective_event | CorrectiveEvents | Location → solar_location ** (κύρια σχέση “plant”) | Διορθωτικά γεγονότα ανά site |
| solar_preventive_plan | (ήδη solar_solarpreventiveplan) | solar_planlocation → solar_location | Δεν νέο· δες τροποποιήσεις |
| solar_maintenance_team_per_location | MaintenanceTeamPerLocation | Location → solar_location, MaintenanceTeam → solar_maintenance_team | Ανάθεση ομάδων ανά site |
| solar_site_credentials | PVPlantsSiteCredentials | SolarSite/Location → **solar_location** (όχι PVPlants) | Credentials ανά site (IP, κωδικοί) |
| solar_site_comments | CommentsRemarks | SiteId / Location → **solar_location** | Σχόλια ανά site |

** Σε όλο το έγγραφο, “Location” και “solar_location” σημαίνουν το ίδιο πραγματικό entity (Solar Plant / PV Site). Το PVPlants δεν χρησιμοποιείται ως βασικό.

Για τα υπόλοιπα SharePoint lists (π.χ. Equipment, Parts, Documents, Tasks, κ.λπ.) μπορούν να προστεθούν σε επόμενα φάσματα αν χρειάζεται η πλήρης λίστα.

---

## 4. Σχέσεις (Relationships) – με κεντρικό το solar_location

Όλες οι παρακάτω σχέσεις θεωρούν **solar_location** ως το βασικό “Solar Plant” entity. Δεν υπάρχει χρήση PVPlants ως κεντρικού.

### 4.1 Υπάρχουσες (να παραμείνουν)

- solar_solarpreventivetask.solar_park → solar_location.solar_locationid  
- solar_solarpreventiveplan.solar_planlocation → solar_location.solar_locationid  
- solar_corrective_work_order.solar_locationid → solar_location.solar_locationid  
- solar_solarmodule.solar_park → solar_location.solar_locationid  
- solar_solarinverter.solar_park → solar_location.solar_locationid  
- solar_location.solar_parkmanager → account  
- solar_location.solar_account → new_account  

### 4.2 Νέες σχέσεις προς solar_location (όταν προστεθούν οι πίνακες)

| Referencing Entity | Referencing Attribute | Referenced | Σημείωση |
|--------------------|----------------------|------------|----------|
| solar_location | solar_zones | solar_location (self) | Self-reference, πολλαπλές τιμές αν το Dataverse το επιτρέπει |
| solar_location | solar_dnogridoperator | solar_dno | Αφού δημιουργηθεί solar_dno |
| solar_location | solar_country | solar_solarcountry | Αν χρησιμοποιείται πίνακας χωρών |
| solar_section | solar_location | solar_location | Νέος πίνακας Sections |
| solar_site_credentials | solar_location | solar_location | Αντί για PVPlants.SolarSite |
| solar_site_comments | solar_location | solar_location | Αντί για SiteId → PVPlants |
| solar_maintenance_team_per_location | solar_location | solar_location | Νέος πίνακας MaintenanceTeamPerLocation |
| solar_corrective_event | solar_location | solar_location | Νέος πίνακας CorrectiveEvents |

### 4.3 Αποφυγή σχέσεων με PVPlants ως κεντρικό

- **PVPlantsSiteCredentials.SolarSite → PVPlants**: αντικαθίσταται από **solar_site_credentials.solar_location → solar_location**.
- **PVPlantsDNOStations, PVPlantsCCTVGateCodes, PVPlantsContactInfo, κ.λπ.**: όπου υπάρχει PlantId ή “Plant”, η σχέση να γίνεται με **solar_location** (π.χ. solar_locationid ή lookup προς solar_location).

---

## 5. Πίνακας αντιστοίχισης “Solar Plant” – Locations vs PVPlants

| Λειτουργία / Σενάριο | Πριν (αν χρησιμοποιούνταν PVPlants) | Τώρα (με Locations ως βασικό) |
|----------------------|--------------------------------------|-------------------------------|
| Βασικό entity για “Site/Plant” | PVPlants | **Locations** → solar_location |
| Site credentials (IP, κωδικοί) | PVPlantsSiteCredentials → PVPlants | Νέο solar_site_credentials → **solar_location** |
| Σχόλια / remarks ανά site | CommentsRemarks + SiteId | solar_site_comments → **solar_location** |
| DNO stations ανά site | PVPlantsDNOStations + PlantId | Λεπτόμερα ανά solar_location ή νέο child entity → **solar_location** |
| CCTV/Gate codes ανά site | PVPlantsCCTVGateCodes + PlantId | Idem, child của **solar_location** |
| Corrective events ανά site | CorrectiveEvents.Location → Locations | solar_corrective_work_order.solar_locationid → **solar_location** (ήδη) |
| Preventive plans ανά site | PreventivePlan.Location → Locations | solar_solarpreventiveplan.solar_planlocation → **solar_location** (ήδη) |
| Equipment tracking “ανά plant” | EquipmentTracking.PlantId | Νέο ή τροποποίηση ώστε να δείχνει σε **solar_location** |

---

## 6. Φάση 2 – Νέοι πίνακες και σχέσεις

Μετά την Φάση 1, προστίθενται οι πίνακες που αφορούν **αποθήκες, εξοπλισμό, ανταλλακτικά, υπηρεσίες και ρυθμίσεις ανά site**. Όλες οι σχέσεις “Location” ή “PlantId” γίνονται προς **solar_location** (solar_locationid).

### 6.1 Νέοι πίνακες Φάσης 2 (Dataverse)

| Προτεινόμενο Entity (Dataverse) | SharePoint Table | Σχέση με solar_location / άλλα | Σκοπός |
|----------------------------------|-------------------|----------------------------------|--------|
| solar_supplier | Suppliers | — | Προμηθευτές |
| solar_part_category | PartsCategories | Parent → self | Κατηγορίες ανταλλακτικών |
| solar_manufacturer_brand | ManufacturerBrands | — | Κατασκευαστές/μάρκες |
| solar_equipment_category | EquipmentCategories | Parent → self | Κατηγορίες εξοπλισμού |
| solar_warehouse | Warehouses | solar_location (Location) | Αποθήκες ανά location |
| solar_equipment | Equipment | Category → solar_equipment_category, ManufacturerOrBrand → solar_manufacturer_brand, Supplier → solar_supplier | Εξοπλισμός |
| solar_part | Parts | Category → solar_part_category, ManufacturerOrBrand, Supplier | Ανταλλακτικά |
| solar_asset_category | AssetsCategories | Parent → self | Κατηγορίες assets |
| solar_asset | Assets | Location → solar_location, Section → solar_section, Category → solar_asset_category, ManufacturerOrBrand | Assets ανά site/section |
| solar_location_configuration_item_type | LocationConfigurationItemTypes | — | Τύποι στοιχείων ρυθμίσεων |
| solar_location_configuration | LocationConfiguration | Location → solar_location, ItemType → solar_location_configuration_item_type | Ρυθμίσεις ανά location |
| solar_warehouse_to_location | WarehouseToLocation | Warehouse → solar_warehouse, Location → solar_location | Σύνδεση αποθήκης–location |
| solar_warehouse_equipment_serial | WarehouseEquipmentSerial | Equipment → solar_equipment, Warehouse → solar_warehouse | Serial εξοπλισμού σε αποθήκη |
| solar_sub_corrective_event | SubCorrectiveEvent | CorrectiveEvent → solar_corrective_work_order, Category → solar_corrective_category | Υπο-γεγονότα corrective |
| solar_maintenance_team_member | MaintenanceTeamMembers | MaintenanceTeam → solar_maintenance_team | Μέλη ομάδας |
| solar_service_company | ServiceCompanys | — | Εταιρείες υπηρεσιών |
| solar_om_category | OMCategories | CategoryParent → self | Κατηγορίες OM |
| solar_equipment_serial | EquipmentSerial | Equipment → solar_equipment, Location → solar_location, Section → solar_section | Serial εξοπλισμού ανά location/section |
| solar_equipment_to_warehouse | EquipmentToWarehouse | Equipment → solar_equipment, Warehouse → solar_warehouse | Ποσότητα εξοπλισμού ανά αποθήκη |
| solar_service_order | ServiceOrder | ServiceCompany → solar_service_company, Location → solar_location | Παραγγελίες υπηρεσιών ανά site |
| solar_service | Service | Category → solar_om_category, DefaultServiceCompany → solar_service_company | Υπηρεσίες/εργασίες |
| solar_section_template | SectionTemplate | — | Πρότυπο τμημάτων |
| solar_document_set_category | DocumentSetCategories | — | Κατηγορίες εγγράφων |
| solar_document_set | DocumentSets | Category → solar_document_set_category | Σετ εγγράφων |
| solar_parts_transaction | PartsTransaction | Part → solar_part, FromWarehouse/ToWarehouse → solar_warehouse | Κινήσεις ανταλλακτικών |
| solar_stock_adjustment | StockAdjustments | Part, Equipment, Warehouse → αντίστοιχα entities | Προσαρμογές αποθέματος |
| solar_equipment_transaction | EquipmentTransaction | Location → solar_location, Category → solar_equipment_category | Κινήσεις εξοπλισμού |
| solar_site_cctv_gate_codes | PVPlantsCCTVGateCodes | PlantId → **solar_location** | Κωδικοί πύλης/CCTV ανά site |
| solar_site_dno_stations | PVPlantsDNOStations | PlantId → **solar_location** | DNO stations ανά site |
| solar_equipment_tracking | EquipmentTracking | PlantId → **solar_location** (αντί για PVPlants) | Tracking εξοπλισμού ανά site |
| solar_strings | Strings | (optional Location → solar_location αν χρειάζεται) | Strings PV |
| solar_device_channel | DeviceChannels | — | Κανάλια συσκευών |
| solar_maintenance_team_category | MaintenanceTeamCategories | Parent → self | Κατηγορίες ομάδων συντήρησης |

### 6.2 Σχέσεις Φάσης 2 (με solar_location και μεταξύ νέων πινάκων)

- solar_warehouse.solar_location → solar_location  
- solar_asset.solar_location → solar_location, solar_asset.solar_section → solar_section  
- solar_location_configuration.solar_location → solar_location  
- solar_warehouse_to_location.solar_location → solar_location, solar_warehouse_to_location.solar_warehouse → solar_warehouse  
- solar_equipment_serial.solar_location → solar_location, solar_equipment_serial.solar_section → solar_section, solar_equipment_serial.solar_equipment → solar_equipment  
- solar_service_order.solar_location → solar_location  
- solar_sub_corrective_event.solar_corrective_work_order → solar_corrective_work_order  
- solar_equipment_transaction.solar_location → solar_location  
- solar_site_cctv_gate_codes.solar_location → solar_location  
- solar_site_dno_stations.solar_location → solar_location  
- solar_equipment_tracking.solar_location → solar_location  
- solar_equipment → solar_equipment_category, solar_manufacturer_brand, solar_supplier  
- solar_part → solar_part_category, solar_manufacturer_brand, solar_supplier  
- solar_parts_transaction → solar_part, solar_warehouse (From/To)  
- solar_stock_adjustment → solar_part, solar_equipment, solar_warehouse  
- solar_warehouse_equipment_serial → solar_equipment, solar_warehouse  
- solar_equipment_to_warehouse → solar_equipment, solar_warehouse  

### 6.3 Σύνοψη Φάσης 2

- **Νέοι πίνακες (Φάση 2):** 31 (supplier, part_category, manufacturer_brand, equipment_category, warehouse, equipment, part, asset_category, asset, location_configuration_item_type, location_configuration, warehouse_to_location, warehouse_equipment_serial, sub_corrective_event, maintenance_team_member, service_company, om_category, equipment_serial, equipment_to_warehouse, service_order, service, section_template, document_set_category, document_set, parts_transaction, stock_adjustment, equipment_transaction, site_cctv_gate_codes, site_dno_stations, equipment_tracking, strings, device_channel, maintenance_team_category).  
- **Σχέσεις:** Όλες οι αναφορές Location/PlantId → **solar_location**. Τα lookups μεταξύ Equipment, Parts, Warehouses, Categories κ.λπ. ακολουθούν το SharePoint schema με Dataverse entity names.

---

## 7. Επόμενα βήματα (checklist)

**Φάση 1**
- [ ] Εφαρμογή των νέων/τροποποιημένων attributes στο **solar_location** σύμφωνα με § 2.1.
- [ ] Δημιουργία νέων πινάκων (§ 3) και σχέσεων (§ 4.2) με σειρά προτεραιότητας (π.χ. πρώτα solar_dno, solar_section, solar_site_credentials, solar_site_comments).

**Φάση 2**
- [ ] Δημιουργία πινάκων Φάσης 2 (§ 6.1) και σχέσεων (§ 6.2) με σειρά προτεραιότητας (π.χ. πρώτα solar_supplier, solar_manufacturer_brand, solar_equipment_category, solar_part_category, solar_warehouse, solar_equipment, solar_part, solar_asset).

**Γενικά**
- [ ] Αντικατάσταση κάθε αναφοράς σε “PVPlants” ή “PlantId” με lookup/σχέση προς **solar_location** στη λογική και στα δεδομένα.
- [ ] Έλεγχος ότι όλα τα custom views, reports και integrations χρησιμοποιούν **solar_location** ως κεντρικό entity για Solar Plants.
- [ ] Τηρείν οποιουσδήποτε naming/prefix κανόνες του Dataverse (π.χ. solar_*) και τα constraints (Lookup vs OptionSet, πολλαπλές τιμές κ.λπ.).

---

*Έγγραφο προτεραιότητας: Locations = Solar Plant. PVPlants δεν χρησιμοποιείται ως βασικό entity. Φάση 1 + Φάση 2 = πλήρης κάλυψη πινάκων CMMS (εκτός BGE/showcase).*
