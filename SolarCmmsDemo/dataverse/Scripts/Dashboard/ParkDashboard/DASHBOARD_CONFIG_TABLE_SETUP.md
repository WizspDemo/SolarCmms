# Πίνακας solar_dashboardconfig – Setup

Πίνακας Dataverse για αποθήκευση του PlantDashboard config (JSON) αντί για localStorage.

**Δημιουργήθηκε μέσω Dataverse Remote MCP** στο solution **solardev**.

## Σχήμα (ύπαρξη)

| Logical Name | Display Name | Type |
|--------------|--------------|------|
| solar_dashboardconfig | Dashboard Config | Table |
| solar_configkey | Config Key | Text (100) |
| solar_configjson | Config JSON | Memo |

## Δομή εγγραφής

| Column | Value |
|--------|-------|
| solar_configkey | `PlantDashboard` |
| solar_configjson | JSON string |

**Σημαντικό:** Το Config UI και το PlantDashboard πρέπει να τρέχουν **μέσα σε Power Apps / Model-driven app** (iframe) ώστε να έχουν πρόσβαση στο `Xrm.WebApi`.

## Παράδειγμα JSON (solar_configjson)

```json
{
  "visibleTabs": {
    "workorders": true,
    "livefeed": true,
    "map": true,
    "team": true,
    "sitedetails": true,
    "windy": false
  },
  "showMessageBar": true,
  "showWeatherWidget": true,
  "showInverterStatus": true,
  "statsCards": {
    "preventiveHealth": true,
    "preventiveWorkflow": true,
    "criticalDefects": true,
    "correctiveWorkflow": true
  }
}
```

**Σημείωση:** Το ConfigUI χρησιμοποιεί `tabs` αντί για `visibleTabs` στο save – το PlantDashboard δέχεται και τα δύο.

## Αποδοχή (Permissions)

Οι χρήστες που ανοίγουν το PlantDashboard ή το ConfigUI χρειάζονται τουλάχιστον **Read** στο `solar_dashboardconfig`. Για αποθήκευση από το ConfigUI χρειάζονται **Create** και **Write**.
