# Park Specs – Horizontal Accordion

React web resource με οριζόντιο accordion που εμφανίζει τα 6 τμήματα δεδομένων Solar Park (Site Info, Inverter, PV Modules, Comms, HV, Security) μέσα σε ένα υπάρχον tab της φόρμας Solar Parks (`solar_location`).

## Τι κάνει

- 6 panels σε σειρά: Site Information, Inverter Specs, PV Modules Specs, Comms Specs, HV Specs, Security Specs
- Κλικ σε panel → ανοίγει, εμφανίζει τα πεδία (read-only από τη φόρμα)
- Διαβάζει δεδομένα από `Xrm.Page.getAttribute()` (parent frame)

## Προαπαιτήσεις

- Web resources: `solar_react`, `solar_reactdom`, `solar_fluentui`, `solar_babel`
- Entity: `solar_location` (Solar Parks)
- Στο web resource control: **μη** ενεργό το "Restrict cross-frame scripting"

## Upload

1. **Δημιουργία Web Resource**
   - Power Apps → Solutions → Your solution → New → Web Resource
   - Name: `solar_ParkSpecsAccordion`
   - Type: Webpage (HTML)
   - Choose File: `ParkSpecsAccordion.html`

2. **Ενσωμάτωση στη φόρμα Solar Parks**
   - Άνοιγμα φόρμας `solar_location` (Solar Parks) στο Form Designer
   - Επιλογή του tab όπου θέλετε να εμφανιστεί το accordion
   - Insert → Web Resource
   - Επιλογή `solar_ParkSpecsAccordion`
   - Layout: 1 column, full width (προτείνεται ύψος ~400px)
   - Προαιρετικά: ενεργοποιήστε "Pass row object-type code and unique identifier as parameters"
   - **Μη** ενεργοποιήστε "Restrict cross-frame scripting"

## Πεδία ανά panel

Τα logical names αντιστοιχούν στα υπάρχοντα ή προτεινόμενα attributes του `solar_location`. Αν κάποιο πεδίο δεν υπάρχει ακόμα, θα εμφανίζεται ως "—".

| Panel | Πεδία |
|-------|-------|
| Site Information | solar_name, solar_address, solar_postalcode, solar_account, solar_landsizekm, solar_opendate |
| Inverter Specs | solar_inverter_manufacturer, solar_inverter_type, solar_inverter_model, solar_inverter_quantity, solar_inverter_lv_voltage, solar_inverter_power, solar_assumed_warranty_period, solar_warranty_expiry |
| PV Modules | solar_modulemanufacturer, solar_modulemodel, solar_modulequantity, solar_modulepower, solar_modulevoc, solar_moduleisc, solar_modulelength, solar_modulewidth, solar_moduledepth |
| Comms | solar_satellite3g4g, solar_lannetwork, solar_scadaprovider, solar_dataloggers |
| HV | solar_dnosizekv, solar_dnocontact, solar_sitereferencenumber, solar_transformerquantity, solar_transformermake, solar_transformermodel |
| Security | solar_security, solar_securitycodes, solar_accessgatecodes, solar_exportmeterlocation, solar_exportmeteraccessdetails, solar_otherinformation, solar_landownerfarmerdetails |

## Αλλαγές schema

Για τα πεδία που λείπουν, δείτε `dataverse/schema/dataverse_sync_proposal.md` §2.1.
