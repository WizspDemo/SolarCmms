<#
Export Dataverse entity metadata including attributes (columns) and relationships.

Usage:
    ./export-entity-metadata.ps1 -EnvironmentUrl 'https://org08dc9606.crm4.dynamics.com' -InputCsv 'solardev_tables.csv' -AccessToken $token

This script reads entity logical names from a CSV file and exports:
- Attributes (columns/fields) for each entity
- Relationships (OneToMany, ManyToOne) for each entity

Requires a valid Dataverse access token (Bearer).
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl,

    [Parameter(Mandatory=$true)]
    [string]$InputCsv,

    [string]$AccessToken,

    [string]$OutputDir = "c:/Users/mapos/OneDrive - WIZSP S.R.L/GitHub/Wizspplayroom/SolarCmmsDemo/exports",

    [int]$DelayMs = 200
)

function Get-AccessTokenInteractive {
    Write-Host "No access token provided. Please paste a valid Dataverse access token (Bearer):"
    $token = Read-Host -AsSecureString "Access Token"
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))
}

if (-not (Test-Path $InputCsv)) {
    Write-Error "Input CSV file not found: $InputCsv"
    exit 1
}

if (-not $AccessToken) {
    $AccessToken = Get-AccessTokenInteractive
}

$headers = @{
    'Authorization' = "Bearer $AccessToken"
    'Accept' = 'application/json'
    'OData-MaxVersion' = '4.0'
    'OData-Version' = '4.0'
}

# Read entity logical names from CSV
$entities = Import-Csv -Path $InputCsv
Write-Host "Found $($entities.Count) entities to process"

# Initialize result arrays
$attributes = @()
$relationships = @()

$baseUrl = $EnvironmentUrl.TrimEnd('/')

foreach ($entity in $entities) {
    $logicalName = $entity.LogicalName
    if ([string]::IsNullOrWhiteSpace($logicalName)) {
        continue
    }

    Write-Host "Processing entity: $logicalName"

    # Get Attributes
    $attrUrl = "$baseUrl/api/data/v9.2/EntityDefinitions(LogicalName='$logicalName')/Attributes"
    try {
        $attrResp = Invoke-RestMethod -Method Get -Uri $attrUrl -Headers $headers -ErrorAction Stop
        if ($attrResp.value) {
            foreach ($attr in $attrResp.value) {
                $attributes += [PSCustomObject]@{
                    EntityLogicalName = $logicalName
                    EntitySchemaName  = $entity.SchemaName
                    AttributeLogicalName = $attr.LogicalName
                    AttributeSchemaName  = $attr.SchemaName
                    DisplayName      = $attr.DisplayName?.Name
                    Description      = $attr.Description?.Name
                    AttributeType    = $attr.AttributeType
                    IsPrimaryId      = $attr.IsPrimaryId
                    IsPrimaryName    = $attr.IsPrimaryName
                    IsValidForCreate = $attr.IsValidForCreate
                    IsValidForUpdate = $attr.IsValidForUpdate
                    IsValidForRead   = $attr.IsValidForRead
                    RequiredLevel    = $attr.RequiredLevel?.Value
                    MaxLength        = $attr.MaxLength
                    Precision        = $attr.Precision
                    PrecisionSource  = $attr.PrecisionSource
                    Scale            = $attr.Scale
                }
            }
        }
    } catch {
        Write-Warning "Failed to get attributes for $logicalName : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds $DelayMs

    # Get OneToMany Relationships
    $oneToManyUrl = "$baseUrl/api/data/v9.2/EntityDefinitions(LogicalName='$logicalName')/OneToManyRelationships"
    try {
        $relResp = Invoke-RestMethod -Method Get -Uri $oneToManyUrl -Headers $headers -ErrorAction Stop
        if ($relResp.value) {
            foreach ($rel in $relResp.value) {
                $relationships += [PSCustomObject]@{
                    EntityLogicalName      = $logicalName
                    EntitySchemaName       = $entity.SchemaName
                    RelationshipSchemaName = $rel.SchemaName
                    ReferencedEntity       = $rel.ReferencedEntity
                    ReferencingEntity      = $rel.ReferencingEntity
                    ReferencedAttribute    = $rel.ReferencedAttribute
                    ReferencingAttribute   = $rel.ReferencingAttribute
                    RelationshipType       = "OneToMany"
                    CascadeConfiguration   = ($rel.CascadeConfiguration | ConvertTo-Json -Compress)
                    IsCustomRelationship   = $rel.IsCustomRelationship
                }
            }
        }
    } catch {
        Write-Warning "Failed to get OneToMany relationships for $logicalName : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds $DelayMs

    # Get ManyToOne Relationships
    $manyToOneUrl = "$baseUrl/api/data/v9.2/EntityDefinitions(LogicalName='$logicalName')/ManyToOneRelationships"
    try {
        $relResp = Invoke-RestMethod -Method Get -Uri $manyToOneUrl -Headers $headers -ErrorAction Stop
        if ($relResp.value) {
            foreach ($rel in $relResp.value) {
                $relationships += [PSCustomObject]@{
                    EntityLogicalName      = $logicalName
                    EntitySchemaName       = $entity.SchemaName
                    RelationshipSchemaName = $rel.SchemaName
                    ReferencedEntity       = $rel.ReferencedEntity
                    ReferencingEntity      = $rel.ReferencingEntity
                    ReferencedAttribute    = $rel.ReferencedAttribute
                    ReferencingAttribute   = $rel.ReferencingAttribute
                    RelationshipType       = "ManyToOne"
                    CascadeConfiguration   = ($rel.CascadeConfiguration | ConvertTo-Json -Compress)
                    IsCustomRelationship   = $rel.IsCustomRelationship
                }
            }
        }
    } catch {
        Write-Warning "Failed to get ManyToOne relationships for $logicalName : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds $DelayMs

    # Get ManyToMany Relationships
    $manyToManyUrl = "$baseUrl/api/data/v9.2/EntityDefinitions(LogicalName='$logicalName')/ManyToManyRelationships"
    try {
        $relResp = Invoke-RestMethod -Method Get -Uri $manyToManyUrl -Headers $headers -ErrorAction Stop
        if ($relResp.value) {
            foreach ($rel in $relResp.value) {
                $relationships += [PSCustomObject]@{
                    EntityLogicalName      = $logicalName
                    EntitySchemaName       = $entity.SchemaName
                    RelationshipSchemaName = $rel.SchemaName
                    Entity1LogicalName     = $rel.Entity1LogicalName
                    Entity2LogicalName     = $rel.Entity2LogicalName
                    RelationshipType       = "ManyToMany"
                    IntersectEntitySchemaName = $rel.IntersectEntitySchemaName
                    IsCustomRelationship   = $rel.IsCustomRelationship
                }
            }
        }
    } catch {
        Write-Warning "Failed to get ManyToMany relationships for $logicalName : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds $DelayMs
}

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Export Attributes CSV
$attributesCsv = Join-Path $OutputDir "solardev_attributes.csv"
$attributes | Export-Csv -Path $attributesCsv -NoTypeInformation -Encoding UTF8
Write-Host "`nExported $($attributes.Count) attributes to $attributesCsv"

# Export Relationships CSV
$relationshipsCsv = Join-Path $OutputDir "solardev_relationships.csv"
$relationships | Export-Csv -Path $relationshipsCsv -NoTypeInformation -Encoding UTF8
Write-Host "Exported $($relationships.Count) relationships to $relationshipsCsv"

Write-Host "`nDone!"