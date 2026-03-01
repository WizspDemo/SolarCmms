# New Warehouse To Location

Φόρμα **Model-driven app** (Dataverse). Τίτλος φόρμας στο UI: **New Warehouse To Location** (`#formHeaderTitle_0`, `data-id="header_title"`).

## Scripts

| Αρχείο | Περιγραφή |
|--------|-----------|
| `warehouse-lookup-to-name-sync.js` | Όταν επιλέγεται τιμή στο **Warehouse** (Lookup), η τιμή μπαίνει αυτόματα στο πεδίο **Name** (Warehouse to location name). |

## Ανέβασμα ως Web Resource στο Solardev (MCP)

Όταν το MCP **user-dataverse-res** (Dataverse Web Resources) είναι ενεργό στο Cursor, χρησιμοποιήστε το εργαλείο **upload_web_resource** με:

| Παράμετρος | Τιμή |
|------------|------|
| `file_path` | Απόλυτο path προς `warehouse-lookup-to-name-sync.js` (ή χρήση `content` + `name`) |
| `name` | `solar_warehouse_to_location_name_sync` |
| `solution` | `Solardev` |
| `display_name` | `Warehouse To Location - Warehouse to Name Sync` |
| `web_resource_type` | `3` (Script JScript) |

**Παράδειγμα (με file_path):**
```
upload_web_resource(
  file_path: "<απόλυτο path>/dataverse/Scripts/Forms/New Warehouse To Location/warehouse-lookup-to-name-sync.js",
  name: "solar_warehouse_to_location_name_sync",
  solution: "Solardev",
  display_name: "Warehouse To Location - Warehouse to Name Sync",
  web_resource_type: 3
)
```

Μετά το upload, προσθέστε το web resource στη φόρμα (Form designer → Events ή Custom control) ώστε να φορτώνει στη φόρμα "New Warehouse To Location".

## Custom control – τι να βάλετε στο "function"

Όταν προσθέτετε το web resource ως **custom control** ή **form library** και ζητάει **function** (συνάρτηση), πληκτρολογήστε ακριβώς:

- **`warehouseToNameSyncStart`**

Αν το πεδίο ζητάει handler για **Form OnLoad**, δοκιμάστε:

- **`OnLoad`**

(Και τα δύο ονόματα καλούν την ίδια λογική.)

## Χρήση (από κονσόλα)

- **Κονσόλα:** Ανοίξτε τη φόρμα, F12 → Console, επικολλήστε το περιεχόμενο του script και Enter.
- **SPA:** Μετά το φόρτωμα της φόρμας: `warehouseToNameSyncStart();`

Το script ελέγχει ότι βρίσκεται στη σωστή φόρμα (από τον τίτλο) πριν ενεργοποιηθεί.
