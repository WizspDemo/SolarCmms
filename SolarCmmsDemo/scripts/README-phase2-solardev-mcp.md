# Phase 2 tables στο Solardev – με Dataverse Remote MCP

## Ρόλος του **dataverse-remote** MCP

Το MCP **user-dataverse-remote** χρησιμοποιείται για:

1. **Ρύθμιση solution context** – όλες οι επόμενες metadata λειτουργίες να συνδέονται με το solution Solardev.
2. **Export schema** – εξαγωγή τρέχοντος schema (tables, columns, relationships) σε JSON.
3. **Mermaid diagram** – δημιουργία διαγράμματος σχέσεων από το exported schema.

Δεν υπάρχει MCP tool για **δημιουργία πινάκων/relationships**· αυτά γίνονται με το PowerShell script ή απευθείας μέσω Web API.

---

## Workflow με MCP

### 1. Ορισμός solution context (από Cursor / MCP)

```
set_solution_context(solutionUniqueName: "Solardev")
```

- Ο context αποθηκεύεται (π.χ. σε `.dataverse-mcp`).
- Επόμενα metadata operations (όταν/αν προστεθούν) θα προστίθενται στο Solardev.

### 2. Export τρέχοντος schema (πριν ή μετά τη δημιουργία πινάκων)

```
export_solution_schema(
  customizationPrefixes: ["solar"],
  outputPath: "dataverse/schema/solardev-export-schema.json",
  prettify: true
)
```

- Αποτέλεσμα: `dataverse/schema/solardev-export-schema.json` (tables, columns, relationships με prefix `solar`).

### 3. Δημιουργία πινάκων Phase 2 και σχέσεων (PowerShell)

```powershell
cd SolarCmmsDemo\scripts
.\create-phase2-tables-solardev.ps1
```

- Δημιουργεί τα 21 entities και τις σχέσεις τους στο Dataverse (με header `MSCRM.SolutionUniqueName: Solardev`).
- Απαιτείται token και υπάρχοντα `solar_location` (και προαιρετικά `solar_section`).

### 4. Mermaid diagram από το exported schema

Αφού τρέξει το export (βήμα 2):

```
generate_mermaid_diagram(
  schemaPath: "dataverse/schema/solardev-export-schema.json",
  outputPath: "dataverse/schema/solardev-schema-diagram.mmd",
  includeColumns: false,
  includeRelationships: true
)
```

- Αποτέλεσμα: `solardev-schema-diagram.mmd` (π.χ. σε Mermaid Live ή VS Code).

---

## Τρέχοντα αρχεία μετά το πρώτο export/diagram

- `dataverse/schema/solardev-export-schema.json` – πλήρες schema (31 tables, 32 relationships).
- `dataverse/schema/solardev-schema-diagram.mmd` – διάγραμμα σχέσεων.

Μετά την εκτέλεση του `create-phase2-tables-solardev.ps1`, ξανατρέξε το **export_solution_schema** και μετά το **generate_mermaid_diagram** για να ενημερωθεί το schema και το diagram με τους νέους πίνακες Phase 2.
