# Template: View – Maintenance Team Members Pane

Αυτό το template βασίζεται στη διαδικασία του **Solar Corrective Work Order** (view team members pane). Μπορείς να το χρησιμοποιήσεις για **οποιονδήποτε άλλο πίνακα** που έχει πεδία Maintenance Team, Scheduled Date και Employee, ώστε να ανοίγει το side pane "Maintenance Team Members" από τη **λίστα (view)** και να κάνει Assign μέσω Web API.

## Αρχεία

| Αρχείο | Περιγραφή |
|--------|-----------|
| `entity-view-team-members-pane.js.template` | Script για το command bar του **view**. Αντικαθιστάς τα placeholders και το ανεβάζεις ως web resource (Script). |
| `entity-view-team-members-pane.html.template` | HTML pane (ίδιο με το Form template). Αντικαθιστάς τα placeholders και το ανεβάζεις ως web resource (HTML). Μπορεί να είναι κοινό με το Form αν ο πίνακας χρησιμοποιεί το ίδιο pane. |

## Placeholders – τι να αντικαταστήσεις

Όλες οι τιμές `{{...}}` πρέπει να αντικατασταθούν με τις σωστές για τον **νέο πίνακα**. Παράδειγμα τιμών (Corrective Work Order):

### Μόνο στο JS template

| Placeholder | Περιγραφή | Παράδειγμα (Corrective WO) |
|-------------|-----------|----------------------------|
| `{{ENTITY_DISPLAY_NAME}}` | Display name πίνακα (για μηνύματα) | `Solar Corrective Work Order` |
| `{{ENTITY_NAME}}` | Logical name πίνακα (singular) | `solar_corrective_work_order` |
| `{{TEAM_MEMBERS_WEBRESOURCE_NAME}}` | Name του HTML web resource (όπως στο Dataverse) | `solar_correctiveworkorder_team_members_pane.html` |
| `{{FIELD_MAINTENANCE_TEAM}}` | Logical name lookup Maintenance Team | `solar_maintenanceteamid` |
| `{{FIELD_SCHEDULE_DATE}}` | Logical name ημερομηνίας (Scheduled Date) | `solar_cor_scheduleddate` |
| `{{PANE_ID}}` | Μοναδικό id για το side pane | `solarTeamMembersPane` |
| `{{PANE_TITLE}}` | Τίτλος pane | `Maintenance Team Members` |
| `{{OPEN_PANE_FUNCTION_NAME}}` | Global function name (χωρίς κενά, PascalCase) | `SolarCorrectiveWoViewOpenTeamMembersPane` |
| `{{PANEDATA_STORAGE_KEY}}` | Κλειδί sessionStorage για τα data | `solar_team_members_pane_data` |
| `{{FORM_CONTEXT_GLOBAL}}` | Global μεταβλητή για formContext (ίδια με Form template) | `__solarCorrectiveWoFormContext` |

### Σε JS και HTML (ίδιες τιμές και στα δύο)

- `{{TEAM_MEMBERS_WEBRESOURCE_NAME}}` – μόνο στο JS  
- `{{PANEDATA_STORAGE_KEY}}`, `{{FORM_CONTEXT_GLOBAL}}`, `{{PANE_TITLE}}` – και στα δύο  
- `{{PANEDATA_GLOBAL}}` – μόνο στο HTML (global για pane data, π.χ. `__solarCorrectiveWoPanedata`)

### Μόνο στο HTML template

| Placeholder | Περιγραφή | Παράδειγμα |
|-------------|-----------|------------|
| `{{ENTITY_TEAM_MEMBER}}` | Πίνακας Maintenance Team Member | `solar_maintenanceteammember` |
| `{{FIELD_TEAM_LOOKUP}}` | Lookup ομάδας στο Team Member | `solar_maintenance_team` |
| `{{FIELD_EMPLOYEE_LOOKUP}}` | Lookup υπαλλήλου στο Team Member | `solar_member` |
| `{{FIELD_EMPLOYEE_NAME}}` | Primary name πεδίο Team Member | `solar_maintenanceteammembername` |
| `{{ENTITY_WORK_ORDER}}` | Logical name πίνακα (ίδιο με ENTITY_NAME) | `solar_corrective_work_order` |
| `{{FIELD_WO_EMPLOYEE_LOOKUP}}` | Lookup Employee στο Work Order | `solar_employee` |
| `{{FIELD_WO_SCHEDULE_DATE}}` | Ιδ. με FIELD_SCHEDULE_DATE | `solar_cor_scheduleddate` |
| `{{WO_EMPLOYEE_NAV_PROPERTY}}` | Navigation property για Employee (Web API) | `solar_Employee` |
| `{{WO_EMPLOYEE_TARGET_SET}}` | Target entity set (π.χ. systemusers) | `systemusers` |
| `{{WO_EMPLOYEE_FIELD_VALUE}}` | GUID field name για filter (_field_value) | `_solar_employee_value` |
| `{{WO_TEAM_FIELD_VALUE}}` | GUID field name για team filter | `_solar_maintenanceteamid_value` |
| `{{ENTITY_WORK_ORDER_PK}}` | Primary key attribute (για $select) | `solar_corrective_work_orderid` |
| `{{BUTTON_ASSIGN_TITLE}}` | Tooltip κουμπιού Assign | `Set this employee as the Employee on the Work Order` |

## Βήματα για νέο πίνακα

1. **Αντικατέστησε** όλα τα `{{...}}` στο `.js.template` και στο `.html.template` με τις τιμές του νέου πίνακα.
2. **Αποθήκευσε** τα αρχεία ως `.js` και `.html` (χωρίς `.template`) στο folder του νέου πίνακα (π.χ. `dataverse/Scripts/View/YourEntity/`).
3. **Upload** ως Web Resources στο Dataverse:
   - Script (JScript): name π.χ. `solar_yourentity_view_team_members_pane`
   - HTML: name π.χ. `solar_yourentity_team_members_pane.html`
4. **Publish** all customizations.
5. **Command Bar του View**: Power Apps → Tables → [Ο πίνακας σου] → Views → το view που θες → Command bar → Add command:
   - **Action:** Run JavaScript  
   - **Library:** το web resource του script  
   - **Function name:** η τιμή που έβαλες στο `{{OPEN_PANE_FUNCTION_NAME}}`  
   - **Parameters** (με τη σειρά): `SelectedControlSelectedItemIds`, `SelectedControl`  
   - **Visibility:** Formula → `CountRows(Self.Selected.AllItems) = 1`
6. Από τη **λίστα**, έλεγξε μια γραμμή και πάτα το κουμπί· θα ανοίξει το pane και το Assign θα ενημερώνει το record μέσω Web API.

## Σημαντικό

- Πρέπει να **επιλέγεται ακριβώς μία γραμμή** στη λίστα.
- Το επιλεγμένο record πρέπει να έχει **Maintenance Team**.
- Το **ίδιο HTML pane** μπορεί να χρησιμοποιείται και από τη **φόρμα** (Form template) και από το **view**, αρκεί τα placeholders να ταιριάζουν και το Form script να γράφει στο ίδιο `{{FORM_CONTEXT_GLOBAL}}` και `{{PANEDATA_STORAGE_KEY}}`.
