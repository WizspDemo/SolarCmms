## Δομή φακέλου Sharepoint

Δενδρική επισκόπηση των φακέλων και αρχείων στο `Sharepoint` και σύντομη περιγραφή του ρόλου τους.

---

- **PreFinal schema/**
  - **list_form_scripts.json**: JSON ορισμοί για scripts/ρυθμίσεις των φορμών λιστών SharePoint (συμπεριφορές στηλών, validation, UI).
  - **merged_columns.json**: Συγχωνευμένη λίστα από custom στήλες/γνωρίσματα λιστών, χρησιμοποιείται σαν ενιαία πηγή στήλης για ανάλυση.
  - **relationships.json**: Περιγραφή των lookup/σχέσεων μεταξύ λιστών SharePoint (ποια λίστα «κοιτάει» ποια).
  - **schema.dbml**: DBML σχήμα βάσης δεδομένων που προκύπτει από τα SharePoint lists (τελικό/προ-τελικό μοντέλο).
  - **schema.tablegroups.dbml**: DBML ομαδοποιήσεις πινάκων (table groups) για καλύτερη απεικόνιση της λογικής δομής.
  - **table_analysis.md**: Αναλυτική τεκμηρίωση των πινάκων (lists), με στήλες, τύπους, σχέσεις και σκοπό κάθε λίστας.

- **PvTicketing/**
  - **custom_list_columns.backup.json**: Backup έκδοση των custom στηλών για τις λίστες του PV Ticketing site.
  - **custom_list_columns.json**: Κύριο JSON με όλους τους ορισμούς των custom στηλών για τις λίστες PV Ticketing.
  - **generate_dbml.py**: Python script που διαβάζει JSON (στήλες & σχέσεις) και παράγει DBML σχήμα για PV Ticketing.
  - **generic_lists_with_properties.json**: Όλες οι λίστες του PV Ticketing με βασικές ιδιότητες (πλήρης κατάλογος lists).
  - **process_columns_data.py**: Python script για επεξεργασία/καθάρισμα των δεδομένων στηλών από τα exports SharePoint.
  - **relationship_lookup_columns.json**: JSON με όλους τους ορισμούς lookup/σχέσεων για τις λίστες PV Ticketing.
  - **schema.dbml**: Το παραγόμενο DBML σχήμα βάσης δεδομένων για το PV Ticketing από τα παραπάνω JSON.
  - **sharepoint_lists_export.csv**: CSV export με τις λίστες SharePoint (ονόματα, βασικά metadata) από το PV Ticketing site.
  - **sharepoint_lists_export.json**: JSON έκδοση του export λιστών SharePoint για περαιτέρω επεξεργασία με scripts.
  - **sharepoint_lists_with_properties.json**: Λίστες SharePoint με εμπλουτισμένες ιδιότητες/metadata (τύποι, flags κ.λπ.).

- **Schema_old/**
  - **solar-lists.json**: Παλαιότερη έκδοση του JSON με τις λίστες του Solar συστήματος (legacy schema).
  - **solar-lists.md**: Τεκμηρίωση σε markdown του παλιού σχήματος λιστών Solar (περιγραφές λιστών/πεδίων).

- **SolarMaintenance/**
  - **custom_list_columns.json**: Custom στήλες για τις SharePoint λίστες του site SolarMaintenance.
  - **EXTRACTION_SUMMARY.md**: Αναλυτική αναφορά εξαγωγής metadata (στατιστικά, λίστες, πλήθος στηλών/relationships).
  - **generate_dbml.py**: Python script που μετατρέπει τα JSON της SolarMaintenance σε DBML σχήμα βάσης δεδομένων.
  - **generic_lists_with_properties.json**: Όλες οι λίστες του SolarMaintenance site με ιδιότητες/metadata.
  - **LOOKUP_RELATIONSHIPS_REPORT.md**: Αναφορά σε markdown με όλες τις lookup σχέσεις ανά λίστα/στήλη.
  - **relationship_lookup_columns.json**: JSON με τους ορισμούς lookup/σχέσεων μεταξύ λιστών SolarMaintenance.
  - **schema.dbml**: DBML σχήμα βάσης δεδομένων που αναπαριστά τις λίστες/σχέσεις του SolarMaintenance.

