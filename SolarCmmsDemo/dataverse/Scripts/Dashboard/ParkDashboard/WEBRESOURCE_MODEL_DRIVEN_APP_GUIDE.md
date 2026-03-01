# Οδηγός τεχνικών απαιτήσεων: HTML Web Resource σε Model-driven app (Dataverse)

Αυτό το έγγραφο περιγράφει τις τεχνικές λεπτομέρειες και τις επιλογές που πρέπει να τηρούνται όταν φτιάχνουμε **HTML web resource** που τρέχει μέσα σε **φόρμα Model-driven app**, φορτώνει δεδομένα από **Dataverse** (solution π.χ. solardev) και εμφανίζει dashboard/λίστες βασισμένες στο **record ID** της τρέχουσας εγγραφής.

**Παράδειγμα αναφοράς:** `LiteDashboard.html` (Solar Lite Dashboard) – φόρτωση Corrective Work Orders φιλτραρισμένων ανά Location.

---

## 1. Σκοπός και πλαίσιο

- Το αρχείο είναι **HTML** (web resource) που εμφανίζεται σε **iframe** μέσα σε φόρμα (π.χ. Solar Location ή Solar Corrective Work Order).
- Πρέπει να **λαμβάνει το ID της εγγραφής** και (προαιρετικά) το **entity logical name** ώστε να κάνει σωστό φιλτράρισμα στα Dataverse tables.
- Τα δεδομένα να **έρχονται από πίνακες του solution** (όχι mock), μέσω **Xrm.WebApi** (client-side).

---

## 2. Λήψη Record ID και Entity name από τη φόρμα

### 2.1 Παράμετροι από URL (προτείνεται)

Όταν στο web resource control της φόρμας είναι ενεργή η επιλογή **"Pass row object-type code and unique identifier as parameters"**, το Power Apps περνάει στο iframe query params:

- `id` – GUID της εγγραφής (μπορεί με `%7B` … `%7D` = `{` `}`)
- `typename` – logical name του entity (π.χ. `solar_location`, `solar_corrective_work_order`)

**Υλοποίηση:**

```javascript
function getQueryParams() {
    var search = (window.location && window.location.search) || '';
    var params = {};
    search.replace(/^\?/, '').split('&').forEach(function (part) {
        var p = part.split('=');
        if (p[0]) params[decodeURIComponent(p[0])] = decodeURIComponent((p[1] || '').replace(/\+/g, ' '));
    });
    return params;
}
function getRecordIdFromContext() {
    var q = getQueryParams();
    if (q.id) return q.id.replace(/[{}]/g, '');
    try {
        if (window.parent && window.parent.Xrm && window.parent.Xrm.Page && window.parent.Xrm.Page.data && window.parent.Xrm.Page.data.entity)
            return window.parent.Xrm.Page.data.entity.getId();
    } catch (e) { }
    return null;
}
function getEntityNameFromContext() {
    var q = getQueryParams();
    if (q.typename) return q.typename;
    try {
        if (window.parent && window.parent.Xrm && window.parent.Xrm.Page && window.parent.Xrm.Page.data && window.parent.Xrm.Page.data.entity)
            return window.parent.Xrm.Page.data.entity.getEntityName();
    } catch (e) { }
    return null;
}
```

- Το **ID** για filters πρέπει **χωρίς αγκύλες** (π.χ. `699c32f7-728d-f011-b4cc-7c1e522a4087`).

### 2.2 Xrm.WebApi από parent frame

Για κλήσεις Dataverse (retrieveMultipleRecords κ.λπ.) χρησιμοποιούμε:

```javascript
function getXrmWebApi() {
    try {
        if (window.parent && window.parent.Xrm && window.parent.Xrm.WebApi) return window.parent.Xrm.WebApi;
    } catch (e) { }
    return null;
}
```

- **Απαραίτητο:** στο web resource control **να μην** είναι ενεργό το "Restrict cross-frame scripting", ώστε το `window.parent.Xrm` να είναι προσβάσιμο.

---

## 3. Φόρτωση δεδομένων: FetchXML vs OData $filter

### 3.1 Γιατί FetchXML για φίλτρο με GUID

- Με **OData `$filter`** και literal GUID:
  - Αν περάσεις μόνο το GUID (π.χ. `solar_locationid eq 699c32f7-...`) το Dataverse μπορεί να το ερμηνεύσει ως **Edm.String** και να δώσει: *"A binary operator with incompatible types was detected ... 'Edm.String' and 'Edm.Guid'"*.
  - Αν χρησιμοποιήσεις `guid'...'` στο query string, μπορεί να εμφανιστεί σφάλμα τύπου *"Unrecognized 'Edm.String' literal 'guid'..."* λόγω encoding/parsing.
- Με **FetchXML**, το GUID περνάει ρητά ως `value="{guid}"` (με αγκύλες). Το Dataverse αναγνωρίζει σωστά τον τύπο και δεν υπάρχει type mismatch.

**Συμπέρασμα:** Για φιλτράρισμα σε lookup/GUID columns, προτείνεται **FetchXML** αντί για OData `$filter`.

### 3.2 FetchXML – σωστό link-type

Τα έγκυρα `link-type` για `<link-entity>` στο Dataverse FetchXML είναι:

- `inner`, `outer`, `natural`, `in`, `matchfirstrowusingcrossapply`, `exists`

**Δεν υπάρχει `link-type="left"`.** Θα δώσει 400 Bad Request:

*"Invalid link-type specified, valid values are: 'natural', 'inner', 'in', 'matchfirstrowusingcrossapply','exists' and 'outer'. link-type = left"*

- Για “left outer join” χρησιμοποιείται **`link-type="outer"`**.

Παράδειγμα:

```xml
<link-entity name="solar_location" from="solar_locationid" to="solar_locationid" link-type="outer" alias="loc">
  <attribute name="solar_name"/>
</link-entity>
```

### 3.3 Μορφή GUID στο FetchXML

- Στο `<condition>` το GUID δίνεται **με αγκύλες** στο `value`:

```xml
<condition attribute="solar_locationid" operator="eq" value="{699c32f7-728d-f011-b4cc-7c1e522a4087}"/>
```

- Στο JavaScript: `value="{' + id + '}"` όπου `id` είναι το GUID χωρίς `{ }`.

### 3.4 Κλήση retrieveMultipleRecords με FetchXML

- Το **options** parameter είναι string: `?fetchXml=` + **encodeURIComponent(fetchXml)**.
- Entity logical name: **singular** (π.χ. `solar_corrective_work_order`).

```javascript
var options = '?fetchXml=' + encodeURIComponent(fetchXml);
webApi.retrieveMultipleRecords('solar_corrective_work_order', options)
  .then(function (result) {
    var entities = (result && result.entities) ? result.entities : (Array.isArray(result) ? result : []);
    // ...
  })
  .catch(function (err) {
    console.error('Fetch error:', err);
    // ...
  });
```

### 3.5 Αποτέλεσμα FetchXML με link-entity (aliases)

- Τα attributes από link-entity επιστρέφουν με **alias** (π.χ. `loc.solar_name`, `team.solar_name`).
- Στο mapping αντικείμενο (π.χ. task για grid) να ελέγχονται και τα alias:

```javascript
var locName = (wo.solar_locationid && wo.solar_locationid.solar_name) ? wo.solar_locationid.solar_name
  : (wo['solar_locationid@OData.Community.Display.V1.FormattedValue'] || wo['loc.solar_name'] || '-');
var teamName = (wo.solar_maintenanceteamid && wo.solar_maintenanceteamid.solar_name) ? wo.solar_maintenanceteamid.solar_name
  : (wo['solar_maintenanceteamid@OData.Community.Display.V1.FormattedValue'] || wo['team.solar_name'] || '-');
```

---

## 4. Δυναμική απεικόνιση τιμών στο HTML/React

- Όλες οι τιμές που προέρχονται από Dataverse (π.χ. μετρητές, ποσοστά, σύνολα) πρέπει να **δένουν** με το state που γεμίζει από τα αποτελέσματα του `Xrm.WebApi` (π.χ. `stats`, `tasks` κ.λπ.).
- Στο `LiteDashboard.html` χρησιμοποιούμε React, οπότε οι δυναμικές τιμές εμφανίζονται **μέσα στο JSX**:

```jsx
<span id="preventive-workflow-assigned">{stats.preventive.assigned}</span>
<span id="preventive-workflow-pending">{stats.preventive.pendingCount}</span>
<span id="preventive-health-pending">{stats.preventive.pending}</span>
<span id="critical-defects-open">{stats.corrective.critical}</span>
<span id="critical-defects-total">{stats.corrective.total}</span>
```

- Τα IDs (`id="..."`) είναι **προαιρετικά** για React (δεν απαιτούνται για το binding), αλλά είναι χρήσιμα αν θέλουμε:
  - να γίνει test/εντοπισμός στοιχείων από dev tools ή automated tests,
  - να γίνει styling/εντοπισμός με CSS ή scripts εκτός React.
- Το σημαντικό για τις δυναμικές τιμές είναι ότι:
  - τα αντικείμενα `stats`, `tasks` κ.λπ. **υπολογίζονται ξανά** κάθε φορά που έρχεται νέο `result.entities` από Dataverse,
  - το JSX χρησιμοποιεί **κατευθείαν τις ιδιότητες** αυτών των αντικειμένων (`{stats.preventive.assigned}`, `{stats.corrective.total}` κ.λπ.),
  - έτσι το dashboard ενημερώνεται **αυτόματα** όταν αλλάζουν τα δεδομένα.

---

## 5. Ρύθμιση φόρμας (Model-driven app)

- Προσθήκη του **web resource** (π.χ. `solar_LiteDashboard.html`) στη φόρμα του entity που θέλεις (π.χ. Solar Location).
- **Ιδιότητες web resource control:**
  - Ενεργό: **Pass row object-type code and unique identifier as parameters** (ώστε `id`, `typename` στο URL).
  - **Μην** ενεργοποιείς "Restrict cross-frame scripting" (ώστε να λειτουργεί το `window.parent.Xrm.WebApi`).

---

## 6. Solution και Web Resource στο Dataverse

- **Solution:** π.χ. `solardev`.
- **Web resource name:** π.χ. `solar_LiteDashboard.html` (με prefix του publisher).
- **Type:** HTML (1).
- Μετά από κάθε αλλαγή στο περιεχόμενο: **Update** το web resource (upload νέο content) και **Publish All Customizations**.

---

## 7. Σύνοψη checklist για νέο/όμοιο αρχείο

1. Λήψη **record ID** και **entity name** από URL params ή `parent.Xrm.Page.data.entity`.
2. Έλεγχος ότι **Xrm.WebApi** είναι διαθέσιμο από `window.parent.Xrm.WebApi`.
3. Για **φίλτρο με GUID**: χρήση **FetchXML** με `value="{guid}"`.
4. Σε **FetchXML** `<link-entity>`: **link-type="outer"** (ή inner), όχι "left".
5. **encodeURIComponent(fetchXml)** στο options string.
6. Mapping αποτελεσμάτων να λαμβάνει υπόψη **alias** από link-entity (π.χ. `loc.solar_name`).
7. Φόρμα: **Pass row object-type code and unique identifier as parameters** ενεργό, **Restrict cross-frame scripting** απενεργό.
8. Μετά από αλλαγές: **update web resource** και **Publish All**.

---

## 8. Σχετικά αρχεία

- **Παράδειγμα υλοποίησης:** `webresourses/LiteDashboard.html`
- **Solution:** solardev  
- **Web resource name στο Dataverse:** `solar_LiteDashboard.html`

---

## 9. PlantDashboard – εμφάνιση/κρύψιμο Pivot tabs και widgets

Στο `PlantDashboard.html` μπορείτε να ελέγχετε:

**Tabs (Work Orders, Live Feed, Map, Team, Site Details, Live Cloud Map):**
- `DEFAULT_TAB_VISIBILITY` στο αρχείο (π.χ. `windy: false`)
- URL: `?tabs=workorders,livefeed,map` | `?hide=windy,team`

**Widgets:**
- **MessageBar:** `showMessageBar=false` ή `?showMessageBar=0`
- **Stats cards (ανά card):** `statsCards: { preventiveHealth, preventiveWorkflow, criticalDefects, correctiveWorkflow }` – `false` για κρύψιμο
- **Weather widget:** `showWeatherWidget=false` ή `?showWeatherWidget=0`
- **Inverter Status:** `showInverterStatus=false` ή `?showInverterStatus=0`
- **URL params για stats:** `?statsCards=preventiveHealth,criticalDefects` | `?hideStatsCards=preventiveWorkflow`

- **Ξεχωριστό config:** Ανεβάστε το `PlantDashboardConfig.js` ως Script web resource και φορτώστε το πριν το main script (βλ. σχόλιο στο PlantDashboard.html).

**Config UI:** Ανεβάστε το `PlantDashboardConfigUI.html` ως HTML web resource (π.χ. `solar_PlantDashboardConfigUI.html`). Ανοίγετε αυτή τη σελίδα για να ρυθμίσετε γραμμικά το config και να ανοίξετε το dashboard με τα σωστά URL params. Υποστηρίζεται αποθήκευση στο **localStorage** ή στο **Dataverse** (πίνακας `solar_dashboardconfig` – βλ. `DASHBOARD_CONFIG_TABLE_SETUP.md`).

---

*Τελευταία ενημέρωση: Φεβρουάριος 2025 – βασισμένο στην εμπειρία από το Solar Lite Dashboard και τις διορθώσεις (OData vs FetchXML, link-type, GUID format).*
