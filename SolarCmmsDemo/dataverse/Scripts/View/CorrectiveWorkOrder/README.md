# Solar Corrective Work Order – Team Members Pane (from View)

Ανοίγει το pane **Maintenance Team Members** από τη λίστα (view) του πίνακα Solar Corrective Work Order. Ο χρήστης επιλέγει μια γραμμή και πατάει το κουμπί.

## Αρχεία

| Αρχείο | Περιγραφή |
|--------|-----------|
| `corrective-workorder-view-team-members-pane.js` | Script που τρέχει από το command bar του view. Παίρνει την επιλεγμένη γραμμή, φέρνει team/date via Web API, ανοίγει το ίδιο HTML pane. |
| `corrective-workorder-team-members-pane.html` | Κοινό HTML pane – φορτώνει μέλη ομάδας και αριθμό εργασιών. Χρησιμοποιείται και από το view και από τη φόρμα. |

## Προαπαιτήσεις

- Τα web resources (JS και HTML) πρέπει να είναι ανεβασμένα και published στο Solardev.

## 1. Ανέβασμα ως Web Resources (Solardev)

Με το MCP **user-dataverse-webresources** ή από το Power Apps:

### JavaScript (view script)

| Παράμετρος | Τιμή |
|------------|------|
| Name | `solar_correctiveworkorder_view_team_members_pane` |
| Display Name | `Corrective WO View – Team Members Pane` |
| Type | Script (JScript) |
| Solution | Solardev |

**Path:** `dataverse/Scripts/View/CorrectiveWorkOrder/corrective-workorder-view-team-members-pane.js`

### HTML (κοινό pane)

| Παράμετρος | Τιμή |
|------------|------|
| Name | `solar_correctiveworkorder_team_members_pane.html` |
| Display Name | `Maintenance Team Members Pane` |
| Type | HTML (Web Page) |
| Solution | Solardev |

**Path:** `dataverse/Scripts/View/CorrectiveWorkOrder/corrective-workorder-team-members-pane.html`

Μετά το upload: **Publish all customizations**.

## 2. Προσθήκη κουμπιού στο Command Bar του View

1. Άνοιξε το **Power Apps** (make.powerapps.com) και διάλεξε το environment (π.χ. Solardev).
2. Πήγαινε σε **Apps** → άνοιξε το Model-driven app που χρησιμοποιεί τον πίνακα **Solar Corrective Work Order**.
3. **Edit** την εφαρμογή.
4. Αριστερά, **Tables** → **Solar Corrective Work Order** (ή όπως λέγεται ο πίνακας).
5. **Forms** → διάλεξε **Main form** (ή το form που εμφανίζει το grid στη λίστα). Σε κάποια setups το grid είναι στο Main.
   - **Εναλλακτικά:** Κάτω από Tables, ψάξε για **Views** → διάλεξε το view που θες (π.χ. Active Corrective Work Orders).
   - Αν το app σου δείχνει **Command bar** απευθείας για views/grid, πήγαινε εκεί.
6. Όταν είσαι στο σωστό Command Bar (της λίστας, όχι της φόρμας εγγραφής):
   - **Add command** → **New button**.
7. Ρυθμίσεις του κουμπιού:
   - **Label:** `Team Members` ή `Add Employee` (ό,τι θέλεις)
   - **Action:** `Run JavaScript`
   - **Library:** `solar_correctiveworkorder_view_team_members_pane`
   - **Function name:** `SolarCorrectiveWoViewOpenTeamMembersPane`
   - **Parameters** (πρόσθεσε και τα δύο, με τη σειρά):
     1. `SelectedControlSelectedItemIds`
     2. `SelectedControl`  
     Το script δοκιμάζει και τους δύο τρόπους αυτόματα.
8. **Σημαντικό – Visibility:** Το κουμπί χρειάζεται να εμφανίζεται **όταν επιλέγεται μία γραμμή**:
   - Αριστερά, στην ενότητα **Visibility** → διάλεξε **"Show on condition from formula"**.
   - Στον τύπο Power Fx βάλε: `CountRows(Self.Selected.AllItems) = 1`
   - Έτσι το κουμπί θα εμφανίζεται μόνο όταν έχει επιλεγεί ακριβώς μία γραμμή (και θα κρύβεται όταν δεν υπάρχει επιλογή ή υπάρχουν πολλές).
9. **Save** και **Publish**.

## 3. Πότε εμφανίζεται το κουμπί

Το κουμπί εμφανίζεται στο command bar **της λίστας** (όταν βλέπεις πολλές εγγραφές σε πίνακα), όχι όταν είσαι μέσα σε μια συγκεκριμένη φόρμα εγγραφής.

## 4. Χρήση

1. Πήγαινε στη λίστα Solar Corrective Work Order.
2. **Επέλεξε μια γραμμή** (ένα record).
3. Πάτησε το κουμπί **Team Members** (ή όπως το ονόμασες).
4. Ανοίγει το side pane με τα μέλη της ομάδας και τον αριθμό εργασιών.
5. Το κουμπί **Assign** ενημερώνει το πεδίο Employee στο record μέσω Web API (δεν ανοίγει η φόρμα).

## Σημαντικό

- **Πρέπει να επιλεγεί ακριβώς μια γραμμή.** Αν δεν υπάρχει επιλογή, εμφανίζεται μήνυμα.
- Το επιλεγμένο record **πρέπει να έχει Maintenance Team**. Αν όχι, εμφανίζεται σφάλμα.
- Το **Assign** δουλεύει μόνο για **αποθηκευμένα** records (έχουν recordId). Για νέα records, άνοιξε τη φόρμα και χρησιμοποίησε το κουμπί από εκεί.
