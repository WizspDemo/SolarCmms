import json

# Define list mapping with internal names from generic_lists_with_properties.json
lists_mapping = {
    "ec558ced-42d9-4c65-8573-09b409bd90f9": {"name": "Countries", "internalName": "Countries"},
    "d5d750c1-d372-4701-ac3b-0c940ebb18b5": {"name": "Equipment Tracking", "internalName": "EquipmentTracking"},
    "6392d14f-dab5-40ce-89af-0eb5b08d0a0b": {"name": "Strings", "internalName": "Strings"},
    "f5612c78-e513-4df2-b024-13e906ea2b69": {"name": "Plant Preventative", "internalName": "PlantPreventative"},
    "6e084852-95e4-41bc-9799-21edbd21db7e": {"name": "Translation Status", "internalName": "TranslationStatus"},
    "f60bcf4d-1ddd-46ce-90ba-25c6e89ff609": {"name": "Services", "internalName": "Services"},
    "94e4c1c7-d831-40a0-a6c1-3e2a8c5e7a59": {"name": "BGE Owned Spares Tracking", "internalName": "BGEOwnedSparesTracking"},
    "2c80cf7a-e0f0-43ef-aeb9-42ab6e8a9d0f": {"name": "Plant Remedials", "internalName": "PlantRemedials"},
    "1c83ef46-f003-4151-a019-371790a307cc": {"name": "DNOs", "internalName": "DNOs"},
    "408ec8a0-2358-4d1f-b93b-3c2a3652790f": {"name": "Clients", "internalName": "Clients"},
    "a8bb1af5-f8f9-41e4-ba7b-451e22d26c72": {"name": "PVGroup", "internalName": "PVGroup"},
    "be3d0a14-8c14-4e60-9fb4-49eb8a3de63a": {"name": "Remedial Docs", "internalName": "RemedialDocs"},
    "95b0b63d-0799-4088-8147-5dd5f5f6e90a": {"name": "SCB", "internalName": "SCB"},
    "47bf52b6-db5f-42a0-a9c5-5f9ff9cfd9a2": {"name": "Warehouses", "internalName": "Warehouses"},
    "4f1aab3f-9ee0-4f8f-9bd2-6225edde19fc": {"name": "PlantPreventativeCopy", "internalName": "PlantPreventativeCopy"},
    "51e81779-bae8-4548-a67e-67d19e2b3a4c": {"name": "CategoriesPerFarm", "internalName": "CategoriesPerFarm"},
    "9e36cc81-6c14-4cd2-a6bb-7b0e5eac2b05": {"name": "Contracts", "internalName": "Contracts"},
    "59041ec8-6d23-4384-9e88-b5a718ee7069": {"name": "Contact Info Misc", "internalName": "ContactInfoMisc"},
    "c5d70d6f-4b85-42e3-8aba-8bbe1e2a6e79": {"name": "Health And Safety On-site", "internalName": "HealthAndSafetyOnSite"},
    "4e5c49b7-6ea8-47b4-a31c-94f6f9c7b2c8": {"name": "PV Plants Contact Info", "internalName": "PVPlantsContactInfo"},
    "fc16f745-58d5-4068-9467-6846e47c8caa": {"name": "BGE Owned Spares", "internalName": "BGEOwnedSpares"},
    "c7ddcef2-c74b-49c9-a36e-9fbc1e8fd3e9": {"name": "Plant Engineer", "internalName": "PlantEngineer"},
    "0ac61c4f-1773-4ea9-b71e-a27ff8f7b27e": {"name": "SLA Levels", "internalName": "SLALevels"},
    "1f8c9c44-8d95-4e8e-b24a-a80e10f99aae": {"name": "Documents To Fill", "internalName": "DocumentsToFill"},
    "82fe5e9f-56d8-48e2-b4f8-b48e1a2ad4bc": {"name": "Content and Structure Reports", "internalName": "ContentAndStructureReports"},
    "52fe5e26-0556-416b-b742-d6308c2c5072": {"name": "Periodic Scheduled Actions", "internalName": "PeriodicScheduledActions"},
    "98be3580-f842-4a55-b034-d9d0ac32b6aa": {"name": "PV Plants CCTV Gate Codes", "internalName": "PVPlantsCCTVGateCodes"},
    "0efcd3ee-b84e-41de-9221-da39203b3aae": {"name": "PV Plants DNO Stations", "internalName": "PVPlantsDNOStations"},
    "a7871c2a-bec4-42d5-be48-db0a891595e7": {"name": "PV Plants", "internalName": "PVPlants"},
    "873f7a23-b4d4-4167-8e45-e2d0f540743e": {"name": "PV Plants System Info", "internalName": "PVPlantsSystemInfo"},
    "b7299269-177e-4357-9537-e813621f981a": {"name": "Asset Categories", "internalName": "AssetCategories"},
    "b1b2220f-7fb7-4c1a-902e-ea3471b14436": {"name": "DailyDocs", "internalName": "DailyDocs"}
}

def extract_column_info(col):
    """Extract relevant column information"""
    info = {
        "name": col.get("name"),
        "type": "unknown",
        "required": col.get("required", False),
        "readOnly": col.get("readOnly", False)
    }
    
    # Determine type
    if "text" in col:
        info["type"] = "text"
        if col["text"].get("maxLength"):
            info["maxLength"] = col["text"]["maxLength"]
        if col["text"].get("allowMultipleLines"):
            info["allowMultipleLines"] = col["text"]["allowMultipleLines"]
    elif "number" in col:
        info["type"] = "number"
    elif "dateTime" in col:
        info["type"] = "dateTime"
    elif "choice" in col:
        info["type"] = "choice"
        info["choices"] = col["choice"].get("choices", [])
    elif "boolean" in col:
        info["type"] = "boolean"
    elif "lookup" in col:
        info["type"] = "lookup"
        if col["lookup"].get("listId"):
            info["lookupListId"] = col["lookup"]["listId"]
    elif "personOrGroup" in col:
        info["type"] = "personOrGroup"
    elif "hyperlinkOrPicture" in col:
        info["type"] = "hyperlinkOrPicture"
    elif "geolocation" in col:
        info["type"] = "geolocation"
    
    return info

# Since I don't have the actual JSON response data here, 
# I'll create a placeholder structure. In real implementation,
# you would parse the actual API responses.
print("Processing complete. Use the actual API response data to populate the columns.")
print(f"Total lists to process: {len(lists_mapping)}")
