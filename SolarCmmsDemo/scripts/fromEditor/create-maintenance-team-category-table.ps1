# Creates solar_maintenance_team_category table via Dataverse Web API
# SchemaName: solar_Maintenance_Team_Category -> LogicalName: solar_maintenance_team_category

$tokenPath = 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmms\token.txt'
if (-not (Test-Path $tokenPath)) { Write-Error "Token file not found: $tokenPath"; exit 1 }
$token = (Get-Content -Raw $tokenPath).Trim()

$environmentUrl = 'https://org08dc9606.crm4.dynamics.com'
$uri = "$environmentUrl/api/data/v9.2/EntityDefinitions"

$body = @{
  "@odata.type" = "Microsoft.Dynamics.CRM.EntityMetadata"
  "SchemaName" = "solar_Maintenance_Team_Category"
  "DisplayName" = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.Label"
    "LocalizedLabels" = @(
      @{
        "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
        "Label" = "Maintenance Team Category"
        "LanguageCode" = 1033
      }
    )
  }
  "DisplayCollectionName" = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.Label"
    "LocalizedLabels" = @(
      @{
        "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
        "Label" = "Maintenance Team Categories"
        "LanguageCode" = 1033
      }
    )
  }
  "Description" = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.Label"
    "LocalizedLabels" = @(
      @{
        "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
        "Label" = "Maintenance team categories. SharePoint MaintenanceTeamCategories."
        "LanguageCode" = 1033
      }
    )
  }
  "OwnershipType" = "OrganizationOwned"
  "IsActivity" = $false
  "HasNotes" = $false
  "HasActivities" = $false
  "Attributes" = @(
    @{
      "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
      "AttributeType" = "String"
      "AttributeTypeName" = @{ "Value" = "StringType" }
      "SchemaName" = "solar_Maintenance_Team_CategoryName"
      "DisplayName" = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        "LocalizedLabels" = @(
          @{
            "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
            "Label" = "Name"
            "LanguageCode" = 1033
          }
        )
      }
      "Description" = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        "LocalizedLabels" = @(
          @{
            "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
            "Label" = "Category name"
            "LanguageCode" = 1033
          }
        )
      }
      "IsPrimaryName" = $true
      "RequiredLevel" = @{
        "Value" = "ApplicationRequired"
        "CanBeChanged" = $true
        "ManagedPropertyLogicalName" = "canmodifyrequirementlevelsettings"
      }
      "FormatName" = @{ "Value" = "Text" }
      "MaxLength" = 100
    }
  )
} | ConvertTo-Json -Depth 15

$headers = @{
  'Authorization' = "Bearer $token"
  'Content-Type' = 'application/json; charset=utf-8'
  'Accept' = 'application/json'
  'OData-MaxVersion' = '4.0'
  'OData-Version' = '4.0'
  'MSCRM.SolutionUniqueName' = 'Solardev'
}

try {
  $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
  Write-Host "Table solar_maintenance_team_category created successfully." -ForegroundColor Green
  $response | ConvertTo-Json -Depth 5
} catch {
  Write-Error "Failed to create table: $_"
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    Write-Host $reader.ReadToEnd()
  }
  exit 1
}
