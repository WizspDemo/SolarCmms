# Ενίσχυση του dataverse-webresources MCP με δυνατότητα σύνδεσης script στη φόρμα

**Ναι**, μπορούμε να ενυπάρξει η δυνατότητα αυτή — απαιτείται επέκταση του MCP server με νέα tools.

---

## Τι χρειάζεται

### 1. Νέο tool: `attach_script_to_form`

Ένα tool που θα:

1. Κάνει **retrieve** του form record από το `systemform` (Dataverse Web API)
2. Μεταχειρίζεται το **FormXml** και προσθέτει:
   - **formLibraries** — το web resource ως library
   - **events** — Form OnLoad και OnChange handlers

### 2. Δομή FormXML (σύμφωνα με το Microsoft schema)

**Library:**

```xml
<formLibraries>
  <Library name="solar_warehouselookuptonamesync" libraryUniqueId="{webresource-guid}" />
</formLibraries>
```

**Form OnLoad:**

```xml
<events>
  <event name="onload" application="true">
    <Handlers>
      <Handler 
        functionName="WarehouseToLocationForm.FormOnLoad" 
        libraryName="solar_warehouselookuptonamesync" 
        handlerUniqueId="{new-guid}" 
        passExecutionContext="true" 
        enabled="true" />
    </Handlers>
  </event>
</events>
```

**OnChange για συγκεκριμένο πεδίο:**

Μέσα στο control με `datafieldname="Solar_warehouse"` (ή parent cell) υπάρχει το `<events>` με το event που έχει `attribute="Solar_warehouse"`:

```xml
<events>
  <event name="onchange" application="true" attribute="Solar_warehouse">
    <Handlers>
      <Handler 
        functionName="WarehouseToLocationForm.WarehouseOnChange" 
        libraryName="solar_warehouselookuptonamesync" 
        ... />
    </Handlers>
  </event>
</events>
```

### 3. Dataverse Web API

- **Retrieve form:** `GET .../api/data/v9.2/systemforms(formid)?$select=formxml,objecttypecode,name`
- **Update form:** `PATCH .../api/data/v9.2/systemforms(formid)` με νέο `formxml`

### 4. Προτεινόμενο interface για το tool

```json
{
  "name": "attach_script_to_form",
  "description": "Adds a JavaScript web resource as form library and configures event handlers (Form OnLoad, field OnChange).",
  "arguments": {
    "formId": "string (required) - systemform formid GUID",
    "webResourceName": "string (required) - e.g. solar_warehouselookuptonamesync",
    "formOnLoadFunction": "string - e.g. WarehouseToLocationForm.FormOnLoad",
    "fieldEventHandlers": [
      {
        "fieldName": "Solar_warehouse",
        "event": "onchange",
        "functionName": "WarehouseToLocationForm.WarehouseOnChange"
      }
    ]
  }
}
```

---

## Που να γίνει η προσθήκη

Το `dataverse-webresources` MCP πιθανότατα τρέχει ως:

- npm package / MCP server, ή
- Custom script που δηλώνεται στο Cursor MCP config

Για να το επεκτείνεις:

1. Εντοπίζεις το source (π.χ. `npx`, `npm`, ή path στο mcp.json)
2. Προσθέτεις το νέο tool implementation
3. Χρησιμοποιείς την ίδια authentication / connection που χρησιμοποιούν τα υπάρχοντα tools (upload, update, publish)

---

## Προκλήσεις

- **FormXml structure:** Το FormXml είναι περίπλοκο XML· χρειάζεται προσεκτική parse/modify (π.χ. `xml2js`, `fast-xml-parser` στο Node).
- **GUIDs:** Τα `handlerUniqueId` και `libraryUniqueId` πρέπει να είναι έγκυρα GUIDs.
- **Control hierarchy:** Το OnChange για πεδίο απαιτεί να βρεθεί το σωστό `<control>` / `<cell>` με `datafieldname`.
- **Solution context:** Οι αλλαγές στο form πρέπει να γίνονται μέσα στο scope της solution (π.χ. Solardev).

Ένας πρακτικός τρόπος είναι να ξεκινήσεις με retrieve ενός form, να εξάγεις το `formxml`, και να δοκιμάσεις την προσθήκη library + events με ένα standalone script πριν το ενσωματώσεις στο MCP.
