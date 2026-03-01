## Εργασίες Συγχρονισμού Dataverse - SharePoint ανά Φάση

Βάση του εγγράφου `dataverse_sync_proposal.md`, οι εργασίες οργανώνονται σε δύο κύριες φάσεις.

---

## 📋 Λίστα Πινάκων ανά Φάση

### Φάση 1 – Πίνακες (21 συνολικά)

#### Υπάρχοντες πίνακες Dataverse (16):
1. **solar_location** (Locations) - με τροποποιήσεις/εμπλουτισμό πεδίων
2. **solar_solarcountry** (Countries)
3. **solar_corrective_category** (CorrectiveTaskCategories)
4. **solar_corrective_work_order** (CorrectiveEvents)
5. **solar_task** (CorrectiveTasks / Tasks)
6. **solar_solarpreventiveplan** (PreventivePlan)
7. **solar_solarpreventivetask** (PreventiveTasks)
8. **solar_solarpreventivetaskcategory** (PreventiveTaskCategories)
9. **solar_solarpreventiveplancategory** (PreventivePlanCategories)
10. **solar_maintenance_team** (MaintenanceTeams)
11. **solar_solarmodule** (Modules)
12. **solar_solarinverter** (Inverters)
13. **account** (Accounts - default Dataverse)
14. **new_account** (Clients)
15. **solar_solarassetcategory** (AssetsCategories - ήδη υπάρχει)
16. *(Άλλοι υπάρχοντες που μπορεί να χρησιμοποιούνται)*

#### Νέοι πίνακες Φάσης 1 (5):
1. **solar_dno** (DNO / DNOs - Grid Operators)
2. **solar_section** (Sections)
3. **solar_maintenance_team_per_location** (MaintenanceTeamPerLocation)
4. **solar_site_credentials** (PVPlantsSiteCredentials)
5. **solar_site_comments** (CommentsRemarks)

**Σύνολο Φάσης 1:** 21 πίνακες (16 υπάρχοντες + 5 νέοι)

---

### Φάση 2 – Πίνακες (38+ συνολικά)

#### Προμηθευτές & Κατηγορίες (5):
1. **solar_supplier** (Suppliers)
2. **solar_manufacturer_brand** (ManufacturerBrands)
3. **solar_part_category** (PartsCategories)
4. **solar_equipment_category** (EquipmentCategories)
5. **solar_asset_category** (AssetsCategories - αν δεν υπάρχει ήδη)

#### Αποθήκες, Εξοπλισμός & Ανταλλακτικά (4):
6. **solar_warehouse** (Warehouses)
7. **solar_equipment** (Equipment)
8. **solar_part** (Parts)
9. **solar_asset** (Assets)

#### Configuration & Logistics (6):
10. **solar_location_configuration_item_type** (LocationConfigurationItemTypes)
11. **solar_location_configuration** (LocationConfiguration)
12. **solar_warehouse_to_location** (WarehouseToLocation)
13. **solar_warehouse_equipment_serial** (WarehouseEquipmentSerial)
14. **solar_equipment_serial** (EquipmentSerial)
15. **solar_equipment_to_warehouse** (EquipmentToWarehouse)

#### Κινήσεις Stock & Transactions (3):
16. **solar_parts_transaction** (PartsTransaction)
17. **solar_stock_adjustment** (StockAdjustments)
18. **solar_equipment_transaction** (EquipmentTransaction)

#### Corrective & Maintenance (2):
19. **solar_sub_corrective_event** (SubCorrectiveEvent)
20. **solar_maintenance_team_member** (MaintenanceTeamMembers)
21. **solar_maintenance_team_category** (MaintenanceTeamCategories)

#### Services & OM (4):
22. **solar_service_company** (ServiceCompanys)
23. **solar_om_category** (OMCategories)
24. **solar_service** (Service / Services)
25. **solar_service_order** (ServiceOrder)

#### Τεχνικά Site-level (5):
26. **solar_site_cctv_gate_codes** (PVPlantsCCTVGateCodes)
27. **solar_site_dno_stations** (PVPlantsDNOStations)
28. **solar_equipment_tracking** (EquipmentTracking)
29. **solar_strings** (Strings)
30. **solar_device_channel** (DeviceChannels)

#### Documents & Templates (3):
31. **solar_section_template** (SectionTemplate)
32. **solar_document_set_category** (DocumentSetCategories)
33. **solar_document_set** (DocumentSets)

**Σύνολο Φάσης 2:** 38+ πίνακες

**Συνολικό σύνολο (Φάση 1 + Φάση 2):** ~59 πίνακες

#### Πίνακας σύνοψης:

| Κατηγορία | Φάση 1 | Φάση 2 | Σύνολο |
|-----------|--------|--------|--------|
| **Υπάρχοντες πίνακες** | 16 | 0 | 16 |
| **Νέοι πίνακες** | 5 | 38+ | 43+ |
| **Σύνολο ανά φάση** | **21** | **38+** | **~59** |

---

## Φάση 1 – Βασικό CMMS με κεντρικό entity το `solar_location`

- **1. Ανασκόπηση / ανάλυση υφιστάμενου Dataverse schema**
  - Έλεγχος των υφιστάμενων πινάκων Dataverse σύμφωνα με `solardev_schema.dbml` (π.χ. `solar_location`, `solar_solarpreventiveplan`, `solar_solarpreventivetask`, `solar_corrective_work_order`, `solar_solarinverter`, `solar_solarmodule`, `solar_task`, `account`, `new_account`).
  - Επιβεβαίωση ότι όλα τα relations “ανά plant/site” δείχνουν ήδη σε `solar_location` (όχι σε `PVPlants`), όπως περιγράφεται στην § 4.1.

- **2. Εμπλουτισμός πίνακα `solar_location` με νέα attributes (βλ. § 2.1)**
  - Προσθήκη / τροποποίηση των παρακάτω πεδίων (όπου λείπουν):
    - Γενικά στοιχεία τοποθεσίας: `solar_code`, `solar_description`, `solar_landsizehectares`, `solar_addressdescription`, `solar_active`.
    - Παραγωγή & χαρακτηριστικά: `solar_annualoutputgwh`, στοιχεία module (`solar_modulemanufacturer`, `solar_modulemodel`, `solar_modulequantity`, `solar_modulepower`, `solar_modulevoc`, `solar_moduleisc`, `solar_modulelength`, `solar_modulewidth`, `solar_moduledepth`, `solar_modulestructure`).
    - Γεωγραφία / χάρτες: `solar_googleearth`, `solar_embedmap`, `solar_what3words`.
    - DNO & HV: `solar_dnogridoperator` (lookup), `solar_dnosizekv`, `solar_dnocontact`, `solar_dnocontact2`, `solar_dnocontact3`, `solar_hvcontractor`, `solar_tbootsub`, στοιχεία μετασχηματιστών (`solar_transformerquantity`, `solar_transformermake`, `solar_transformermodel`, `solar_transformerratingkva`).
    - Δικτύωση / επικοινωνία: `solar_satellite3g4g`, `solar_lannetwork`, `solar_scadaprovider`, `solar_adasinstalled`, `solar_dataloggers`.
    - Ασφάλεια / πρόσβαση: `solar_security`, `solar_securitycodes`, `solar_siteaccessdetails`, `solar_accessgatecodes`, `solar_exportmeterlocation`, `solar_exportmeteraccessdetails`.
    - Διαχείριση site: `solar_zones` (self-lookup), `solar_contains_sections`, `solar_sitereferencenumber`, `solar_supervisor` (lookup σε `systemuser` ή `contact`), `solar_otherinformation`, `solar_notes`, `solar_grazed`, `solar_landownerfarmerdetails`.
  - Αντικατάσταση / εναρμόνιση υπαρχόντων πεδίων (π.χ. `solar_landsizekm` → χρήση/μετατροπή σε `solar_landsizehectares` όπου χρειάζεται).

- **3. Ρυθμίσεις σχέσεων (relationships) του `solar_location` (βλ. § 2.1 & § 4.2)**
  - Δημιουργία / έλεγχος σχέσεων:
    - `solar_location.solar_country` → `solar_solarcountry`.
    - `solar_location.solar_zones` → `solar_location` (self-reference, πολλαπλές τιμές αν υποστηρίζεται).
    - `solar_location.solar_dnogridoperator` → νέο entity `solar_dno`.

- **4. Δημιουργία νέων πινάκων Φάσης 1 (βλ. § 3 & § 1.1)**
  - **`solar_dno`** (SharePoint: `DNO`/`DNOs`)
    - Πεδία για όνομα DNO, στοιχεία επικοινωνίας, σημειώσεις.
    - Σχέση: χρησιμοποιείται ως lookup από `solar_location.solar_dnogridoperator`.
  - **`solar_section`** (SharePoint: `Sections`)
    - Πεδία για κωδικό/όνομα section, τύπο, περιγραφή.
    - Σχέση: `solar_section.solar_location` → `solar_location`.
  - **`solar_maintenance_team_per_location`** (SharePoint: `MaintenanceTeamPerLocation`)
    - Πεδία: σχέση προς `solar_location`, σχέση προς `solar_maintenance_team`, ρόλος/τύπος ανάθεσης, ημερομηνίες ισχύος.
    - Σχέσεις:
      - `solar_maintenance_team_per_location.solar_location` → `solar_location`.
      - `solar_maintenance_team_per_location.solar_maintenance_team` → `solar_maintenance_team`.
  - **`solar_site_credentials`** (SharePoint: `PVPlantsSiteCredentials`)
    - Πεδία για IP, URLs, logins, passwords, σχόλια κ.λπ.
    - Σχέση: `solar_site_credentials.solar_location` → `solar_location` (αντικατάσταση σχέσης προς `PVPlants`).
  - **`solar_site_comments`** (SharePoint: `CommentsRemarks`)
    - Πεδία για σχόλιο, κατηγορία, χρήστη, ημερομηνία, status.
    - Σχέση: `solar_site_comments.solar_location` → `solar_location` (αντί για `SiteId` → `PVPlants`).

- **5. Σχέσεις Φάσης 1 με κεντρικό entity το `solar_location` (βλ. § 4.1–4.2)**
  - Επιβεβαίωση / ρύθμιση των υφιστάμενων σχέσεων:
    - `solar_solarpreventivetask.solar_park` → `solar_location.solar_locationid`.
    - `solar_solarpreventiveplan.solar_planlocation` → `solar_location.solar_locationid`.
    - `solar_corrective_work_order.solar_locationid` → `solar_location.solar_locationid`.
    - `solar_solarmodule.solar_park` → `solar_location.solar_locationid`.
    - `solar_solarinverter.solar_park` → `solar_location.solar_locationid`.
    - `solar_location.solar_parkmanager` → `account`.
    - `solar_location.solar_account` → `new_account`.
  - Δημιουργία νέων relationships:
    - `solar_section.solar_location` → `solar_location`.
    - `solar_site_credentials.solar_location` → `solar_location`.
    - `solar_site_comments.solar_location` → `solar_location`.
    - `solar_maintenance_team_per_location.solar_location` → `solar_location`.
    - (προαιρετικά) `solar_corrective_event.solar_location` → `solar_location` αν δημιουργηθεί διακριτό entity.

- **6. Αποφυγή χρήσης `PVPlants` ως κεντρικού entity (βλ. § 1, § 4.3, § 5)**
  - Χαρτογράφηση όλων των λογικών flows που χρησιμοποιούσαν `PVPlants`/`PlantId` και αντικατάστασή τους με `solar_location`.
  - Έλεγχος λιστών SharePoint:
    - `PVPlantsSiteCredentials`, `CommentsRemarks`, `DNO`, `MaintenanceTeamPerLocation`, `Sections`, κ.λπ.
    - Επιβεβαίωση ότι η αντίστοιχη λογική στο Dataverse στοχεύει `solar_location`.

- **7. Έλεγχος / δοκιμές Φάσης 1**
  - Test cases για:
    - Δημιουργία / ενημέρωση `solar_location` με νέα πεδία.
    - Δημιουργία `solar_section`, `solar_site_credentials`, `solar_site_comments` συνδεδεμένων με `solar_location`.
    - Δημιουργία / ενημέρωση `solar_maintenance_team_per_location`.
  - Έλεγχος reports, views και integrations που βασίζονται σε plant/site ώστε να χρησιμοποιούν `solar_location` (βλ. § 7 – Γενικά).

---

## Φάση 2 – Equipment, Parts, Warehouses, Services, Settings

- **1. Δημιουργία νέων πινάκων Φάσης 2 (βλ. § 6.1)**
  - Πίνακες για προμηθευτές και κατηγορίες:
    - `solar_supplier` (Suppliers).
    - `solar_manufacturer_brand` (ManufacturerBrands).
    - `solar_part_category` (PartsCategories, με parent → self).
    - `solar_equipment_category` (EquipmentCategories, με parent → self).
    - `solar_asset_category` (AssetsCategories, με parent → self).
  - Πίνακες για αποθέματα, εξοπλισμό και assets:
    - `solar_warehouse` (Warehouses, με σχέση προς `solar_location`).
    - `solar_equipment` (Equipment, με lookups προς `solar_equipment_category`, `solar_manufacturer_brand`, `solar_supplier`).
    - `solar_part` (Parts, με lookups προς `solar_part_category`, `solar_manufacturer_brand`, `solar_supplier`).
    - `solar_asset` (Assets, με lookups προς `solar_location`, `solar_section`, `solar_asset_category`, `solar_manufacturer_brand`).
  - Πίνακες για configuration ανά location:
    - `solar_location_configuration_item_type` (LocationConfigurationItemTypes).
    - `solar_location_configuration` (LocationConfiguration, με lookups προς `solar_location` και `solar_location_configuration_item_type`).
  - Πίνακες για logistics / αποθήκες:
    - `solar_warehouse_to_location` (WarehouseToLocation).
    - `solar_warehouse_equipment_serial` (WarehouseEquipmentSerial).
    - `solar_equipment_serial` (EquipmentSerial).
    - `solar_equipment_to_warehouse` (EquipmentToWarehouse).
  - Πίνακες για κινήσεις / stock:
    - `solar_parts_transaction` (PartsTransaction).
    - `solar_stock_adjustment` (StockAdjustments).
    - `solar_equipment_transaction` (EquipmentTransaction).
  - Πίνακες για OM / service:
    - `solar_maintenance_team_member` (MaintenanceTeamMembers).
    - `solar_service_company` (ServiceCompanys).
    - `solar_om_category` (OMCategories, με parent → self).
    - `solar_service_order` (ServiceOrder).
    - `solar_service` (Service / Services).
    - `solar_maintenance_team_category` (MaintenanceTeamCategories).
  - Πίνακες για τεχνικά στοιχεία site:
    - `solar_site_cctv_gate_codes` (PVPlantsCCTVGateCodes, με PlantId → `solar_location`).
    - `solar_site_dno_stations` (PVPlantsDNOStations, με PlantId → `solar_location`).
    - `solar_equipment_tracking` (EquipmentTracking, με PlantId → `solar_location`).
    - `solar_strings` (Strings, προαιρετική σχέση προς `solar_location`).
    - `solar_device_channel` (DeviceChannels).
  - Πίνακες για documents:
    - `solar_section_template` (SectionTemplate).
    - `solar_document_set_category` (DocumentSetCategories).
    - `solar_document_set` (DocumentSets).

- **2. Ορισμός σχέσεων Φάσης 2 (βλ. § 6.2)**
  - Όλες οι σχέσεις `Location`/`PlantId` δείχνουν σε `solar_location`:
    - `solar_warehouse.solar_location` → `solar_location`.
    - `solar_asset.solar_location` → `solar_location`, `solar_asset.solar_section` → `solar_section`.
    - `solar_location_configuration.solar_location` → `solar_location`.
    - `solar_warehouse_to_location.solar_location` → `solar_location`.
    - `solar_equipment_serial.solar_location` → `solar_location`, `solar_equipment_serial.solar_section` → `solar_section`.
    - `solar_service_order.solar_location` → `solar_location`.
    - `solar_equipment_transaction.solar_location` → `solar_location`.
    - `solar_site_cctv_gate_codes.solar_location` → `solar_location`.
    - `solar_site_dno_stations.solar_location` → `solar_location`.
    - `solar_equipment_tracking.solar_location` → `solar_location`.
  - Σχέσεις μεταξύ νέων πινάκων:
    - `solar_equipment` → `solar_equipment_category`, `solar_manufacturer_brand`, `solar_supplier`.
    - `solar_part` → `solar_part_category`, `solar_manufacturer_brand`, `solar_supplier`.
    - `solar_parts_transaction` → `solar_part`, `solar_warehouse` (From/To).
    - `solar_stock_adjustment` → `solar_part`, `solar_equipment`, `solar_warehouse`.
    - `solar_warehouse_equipment_serial` → `solar_equipment`, `solar_warehouse`.
    - `solar_equipment_to_warehouse` → `solar_equipment`, `solar_warehouse`.
    - `solar_sub_corrective_event` → `solar_corrective_work_order`, `solar_corrective_category`.
    - `solar_maintenance_team_member` → `solar_maintenance_team`.
    - `solar_service_order` → `solar_service_company`, `solar_location`.
    - `solar_service` → `solar_om_category`, `solar_service_company`.
    - `solar_section_template`, `solar_document_set_category`, `solar_document_set` όπως δηλώνονται στην § 6.1–6.2.

- **3. Μεταφορά / συγχρονισμός δεδομένων Φάσης 2**
  - Σχεδιασμός mapping από SharePoint lists (`Equipment`, `Parts`, `Warehouses`, `Assets`, `PartsTransaction`, `StockAdjustments`, `EquipmentTransaction`, κ.λπ.) προς τα νέα Dataverse entities.
  - Σενάρια migration:
    - Import αρχικών δεδομένων (one-off).
    - Συνεχής συγχρονισμός (αν απαιτείται).

- **4. Έλεγχος views, reports, integrations Φάσης 2**
  - Δημιουργία / ενημέρωση views για:
    - Stock ανά location/warehouse.
    - Equipment / assets ανά section & category.
    - Service orders & υπηρεσίες ανά site.
  - Έλεγχος ότι όλα τα νέα entities εναρμονίζονται με business flows και ότι τα reports χρησιμοποιούν `solar_location` ως κεντρικό Solar Plant entity.

---

## Γενικές εργασίες / governance (βλ. § 7)

- **1. Αντικατάσταση αναφορών σε `PVPlants` / `PlantId`**
  - Στους πίνακες, σχέσεις, business rules, workflows, plugins, Power Automate flows, reports κ.λπ.
  - Βεβαίωση ότι παντού το κεντρικό entity για Solar Plants είναι το `solar_location`.

- **2. Έλεγχος naming conventions & constraints**
  - Χρήση prefix `solar_` στα custom entities και fields.
  - Επιλογή σωστών τύπων (Lookup vs OptionSet, Boolean, Decimal, Multiline κ.λπ.).
  - Έλεγχος uniqueness (π.χ. `solar_code`).

- **3. Τεκμηρίωση & διακυβέρνηση**
  - Ενημέρωση της τεκμηρίωσης schema (DBML αρχεία Φάσης 1 και Φάσης 2).
  - Δημιουργία σύντομων οδηγών για:
    - Πώς δημιουργούμε νέο Solar Plant (`solar_location`).
    - Πώς συνδέουμε Sections, Credentials, Comments, Equipment, Parts, Warehouses και Services με ένα συγκεκριμένο `solar_location`.

