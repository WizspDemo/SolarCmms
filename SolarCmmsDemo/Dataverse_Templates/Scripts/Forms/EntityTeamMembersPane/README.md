# Template: Maintenance Team Members Pane (Side Pane)

Αυτό το template βασίζεται στη ροή του **Corrective Work Order** και μπορεί να χρησιμοποιηθεί σε **οποιονδήποτε πίνακα** που έχει:
- Lookup **Maintenance Team** (solar_maintenanceteam)
- Πεδίο **Scheduled Date** (ημερομηνία)
- Lookup **Employee** (π.χ. systemuser) για ανάθεση υπαλλήλου

## Τι κάνει

1. Κουμπί στο Command Bar ανοίγει side pane.
2. Το pane φορτώνει μέλη της επιλεγμένης Maintenance Team και αριθμό jobs ανά υπάλληλο (για την επιλεγμένη ημερομηνία).
3. Ο χρήστης μπορεί να κάνει "Assign" για να ορίσει τον υπάλληλο στο τρέχον record.

## Χρήση template για νέο πίνακα

1. **Αντιγραφή αρχείων**
   - Αντιγράψτε το φάκελο `EntityTeamMembersPane` (ή μόνο τα `.template` αρχεία) σε  
     `dataverse/Scripts/Forms/<YourEntityName>/`
   - Μετονομάστε τα αρχεία αφαιρώντας το `.template` και βάζοντας το prefix του entity σας, π.χ.:
     - `entity-team-members-pane.html.template` → `yourentity-team-members-pane.html`
     - `entity-team-members-pane.js.template` → `yourentity-team-members-pane.js`

2. **Αντικατάσταση placeholders**
   - Σε **όλα** τα αρχεία (HTML + JS) αντικαταστήστε τα `{{PLACEHOLDER}}` με τις τιμές του πίνακα σας (βλ. πίνακα παρακάτω).

3. **Upload στο Dataverse**
   - Upload το HTML ως Web Resource (type: Webpage (HTML)).
   - Upload το JS ως Web Resource (type: Script (JScript)).
   - Στο κουμπί του Command Bar: Action = Run JavaScript, Library = το JS web resource, Function name = η τιμή του `{{OPEN_PANE_FUNCTION_NAME}}`, Parameter = PrimaryControl.

---

## Placeholders – Αναφορά

| Placeholder | Περιγραφή | Παράδειγμα (Corrective Work Order) |
|------------|-----------|-------------------------------------|
| **{{ENTITY_DISPLAY_NAME}}** | Ονομασία entity για logs/messages | `CorrectiveWorkOrder` |
| **{{OPEN_PANE_FUNCTION_NAME}}** | Global function για το ribbon | `SolarCorrectiveWoOpenTeamMembersPane` |
| **{{PANE_TITLE}}** | Τίτλος pane και σελίδας | `Maintenance Team Members` |
| **{{PANE_ID}}** | Μοναδικό id side pane | `solarTeamMembersPane` |
| **{{TEAM_MEMBERS_WEBRESOURCE_NAME}}** | Logical name του HTML web resource στο Dataverse | `solar_correctiveworkorder_team_members_pane.html` |
| **{{FIELD_MAINTENANCE_TEAM}}** | Logical name πεδίου Maintenance Team **στο form** | `solar_maintenanceteamid` |
| **{{FIELD_SCHEDULE_DATE}}** | Logical name πεδίου Scheduled Date **στο form** | `solar_cor_scheduleddate` |
| **{{FORM_CONTEXT_GLOBAL}}** | Global μεταβλητή για form context (π.χ. `window.__xxx`) | `__solarCorrectiveWoFormContext` |
| **{{PANEDATA_GLOBAL}}** | Global μεταβλητή για data pane | `__solarTeamMembersPaneData` |
| **{{PANEDATA_STORAGE_KEY}}** | Κλειδί sessionStorage για data | `solar_team_members_pane_data` |
| **{{BUTTON_ASSIGN_TITLE}}** | Tooltip του κουμπιού Assign | `Set this employee as the Employee on the Work Order` |
| **{{ENTITY_TEAM_MEMBER}}** | Logical name πίνακα Maintenance Team Member | `solar_maintenanceteammember` |
| **{{FIELD_TEAM_LOOKUP}}** | Logical name lookup Team **στον πίνακα Team Member** | `solar_maintenance_team` |
| **{{FIELD_EMPLOYEE_LOOKUP}}** | Logical name lookup Employee **στον πίνακα Team Member** | `solar_member` |
| **{{FIELD_EMPLOYEE_NAME}}** | Logical name πεδίου name (primary name) **στον πίνακα Team Member** | `solar_maintenanceteammembername` |
| **{{ENTITY_WORK_ORDER}}** | Logical name πίνακα Work Order (parent entity) | `solar_corrective_work_order` |
| **{{ENTITY_WORK_ORDER_PK}}** | Primary key attribute του Work Order πίνακα | `solar_corrective_work_orderid` |
| **{{FIELD_WO_EMPLOYEE_LOOKUP}}** | Logical name πεδίου Employee **στον πίνακα Work Order** | `solar_employee` |
| **{{FIELD_WO_SCHEDULE_DATE}}** | Logical name πεδίου Scheduled Date **στον πίνακα Work Order** | `solar_cor_scheduleddate` |
| **{{WO_EMPLOYEE_NAV_PROPERTY}}** | Navigation property για Employee (Web API bind) | `solar_Employee` |
| **{{WO_EMPLOYEE_TARGET_SET}}** | Target entity set για το lookup Employee (Web API) | `systemusers` |
| **{{WO_EMPLOYEE_FIELD_VALUE}}** | Filter field για employee (GUID value), π.χ. `_solar_employee_value` | `_solar_employee_value` |
| **{{WO_TEAM_FIELD_VALUE}}** | Filter field για team στο WO, π.χ. `_solar_maintenanceteamid_value` | `_solar_maintenanceteamid_value` |

---

## Σημειώσεις

- Τα **ENTITY_*** και **FIELD_*** πρέπει να ταιριάζουν με τα metadata του Dataverse (logical names).
- Το **WO_EMPLOYEE_TARGET_SET** εξαρτάται από το ποιο entity δείχνει το Employee lookup (π.χ. `systemusers` αν δείχνει σε System User).
- Για νέο entity, μπορείτε να κρατήσετε τα ίδια `solar_maintenanceteammember` / `solar_maintenance_team` / `solar_member` αν ο πίνακας σας χρησιμοποιεί την ίδια Maintenance Team και τα ίδια team members· αλλάζουν κυρίως τα πεδία του **Work Order** (ENTITY_WORK_ORDER, FIELD_WO_*, WO_*).
