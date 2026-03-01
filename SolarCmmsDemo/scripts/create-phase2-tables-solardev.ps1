# Create Phase 2 tables (entities) and their relationships in Solardev solution via Dataverse Web API.
# Uses phase2-create-tables-solardev-config.json. Requires: token file, Solardev solution, solar_location (and optionally solar_section) to exist.

param(
    [string]$TokenPath = 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmms\token.txt',
    [string]$EnvironmentUrl = 'https://org08dc9606.crm4.dynamics.com',
    [string]$SolutionUniqueName = 'Solardev',
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'phase2-create-tables-solardev-config.json'),
    [switch]$SkipEntities,
    [switch]$SkipRelationships,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $TokenPath)) { Write-Error "Token file not found: $TokenPath"; exit 1 }
$token = (Get-Content -Raw $TokenPath).Trim()
if (-not (Test-Path $ConfigPath)) { Write-Error "Config not found: $ConfigPath"; exit 1 }
$config = Get-Content -Raw $ConfigPath | ConvertFrom-Json

$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json; charset=utf-8'
    'Accept'       = 'application/json'
    'OData-MaxVersion' = '4.0'
    'OData-Version'    = '4.0'
    'MSCRM.SolutionUniqueName' = $SolutionUniqueName
}

function Get-EntitySchemaName {
    param([string]$LogicalName)
    $parts = $LogicalName -split '_'
    $prefix = $parts[0]
    $rest = $parts[1..($parts.Length-1)] | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_.ToLower()) }
    ($prefix + '_' + ($rest -join '_'))
}

function New-Label {
    param([string]$Label, [int]$LanguageCode = 1033)
    @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.Label'
        'LocalizedLabels' = @(
            @{
                '@odata.type' = 'Microsoft.Dynamics.CRM.LocalizedLabel'
                'Label' = $Label
                'LanguageCode' = $LanguageCode
            }
        )
    }
}

# ----- Create entities -----
if (-not $SkipEntities) {
    $baseUri = "$EnvironmentUrl/api/data/v9.2"
    $created = 0
    foreach ($entity in $config.entities) {
        $logicalName = $entity.logicalName
        $schemaName = Get-EntitySchemaName -LogicalName $logicalName
        $primaryNameSchema = $schemaName + 'Name'  # e.g. solar_Equipment_CategoryName

        $body = @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.EntityMetadata'
            'SchemaName' = $schemaName
            'DisplayName' = New-Label -Label $entity.displayName
            'DisplayCollectionName' = New-Label -Label $entity.displayCollectionName
            'Description' = New-Label -Label $entity.description
            'OwnershipType' = 'OrganizationOwned'
            'IsActivity' = $false
            'HasNotes' = $false
            'HasActivities' = $false
            'Attributes' = @(
                @{
                    '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'
                    'AttributeType' = 'String'
                    'AttributeTypeName' = @{ 'Value' = 'StringType' }
                    'SchemaName' = $primaryNameSchema
                    'DisplayName' = New-Label -Label 'Name'
                    'Description' = New-Label -Label ('Primary name for ' + $entity.displayName)
                    'IsPrimaryName' = $true
                    'RequiredLevel' = @{
                        'Value' = 'ApplicationRequired'
                        'CanBeChanged' = $true
                        'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings'
                    }
                    'FormatName' = @{ 'Value' = 'Text' }
                    'MaxLength' = 255
                }
            )
        } | ConvertTo-Json -Depth 15

        if ($WhatIf) {
            Write-Host "[WhatIf] Would create entity: $logicalName ($schemaName)" -ForegroundColor Cyan
            $created++
            continue
        }

        try {
            $null = Invoke-RestMethod -Uri "$baseUri/EntityDefinitions" -Method Post -Headers $headers -Body $body
            Write-Host "Created entity: $logicalName" -ForegroundColor Green
            $created++
        } catch {
            if ($_.Exception.Response.StatusCode -eq 400 -or $_.Exception.Message -match 'already exists') {
                Write-Host "Entity already exists or conflict: $logicalName - skipping." -ForegroundColor Yellow
            } else {
                Write-Error "Failed to create entity $logicalName : $_"
                if ($_.Exception.Response) {
                    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $reader.BaseStream.Position = 0
                    Write-Host $reader.ReadToEnd()
                }
                throw
            }
        }
    }
    Write-Host "Entities created/checked: $created" -ForegroundColor Green
}

# ----- Create relationships (OneToMany) -----
if (-not $SkipRelationships) {
    $baseUri = "$EnvironmentUrl/api/data/v9.2"
    $relCreated = 0
    $relConfig = @()

    foreach ($rel in $config.relationships) {
        $relConfig += @{
            ReferencingEntity = $rel.referencingEntity
            ReferencedEntity   = $rel.referencedEntity
            ReferencedAttribute = $rel.referencedAttribute
            LookupSchemaName  = $rel.lookupSchemaName
            LookupDisplayName = $rel.lookupDisplayName
        }
    }

    foreach ($self in $config.selfRelationships) {
        $relConfig += @{
            ReferencingEntity = $self.entity
            ReferencedEntity  = $self.entity
            ReferencedAttribute = $self.referencedAttribute
            LookupSchemaName  = $self.lookupSchemaName
            LookupDisplayName = $self.lookupDisplayName
        }
    }

    foreach ($rel in $relConfig) {
        $refEntity = $rel.ReferencedEntity
        $refAttr  = $rel.ReferencedAttribute
        $relEntity = $rel.ReferencingEntity
        $lookupSchema = $rel.LookupSchemaName
        $lookupLabel = $rel.LookupDisplayName
        # Unique relationship name: solar_ReferencingEntity_LookupSchema (max 100 chars)
        $relationshipSchemaName = "solar_${relEntity}_${lookupSchema}" -replace 'solar_solar_','solar_'
        if ($relationshipSchemaName.Length -gt 100) { $relationshipSchemaName = "solar_" + $lookupSchema }

        $body = @{
            'SchemaName' = $relationshipSchemaName
            '@odata.type' = 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata'
            'AssociatedMenuConfiguration' = @{
                'Behavior' = 'UseCollectionName'
                'Group'    = 'Details'
                'Label'    = New-Label -Label $lookupLabel
                'Order'    = 10000
            }
            'CascadeConfiguration' = @{
                'Assign'   = 'NoCascade'
                'Delete'   = 'RemoveLink'
                'Merge'    = 'NoCascade'
                'Reparent' = 'NoCascade'
                'Share'    = 'NoCascade'
                'Unshare'  = 'NoCascade'
            }
            'ReferencedAttribute' = $refAttr
            'ReferencedEntity'   = $refEntity
            'ReferencingEntity'  = $relEntity
            'Lookup' = @{
                'AttributeType' = 'Lookup'
                'AttributeTypeName' = @{ 'Value' = 'LookupType' }
                'Description' = New-Label -Label ("Lookup to " + $lookupLabel)
                'DisplayName' = New-Label -Label $lookupLabel
                'RequiredLevel' = @{
                    'Value' = 'None'
                    'CanBeChanged' = $true
                    'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings'
                }
                'SchemaName' = $lookupSchema
                '@odata.type' = 'Microsoft.Dynamics.CRM.LookupAttributeMetadata'
            }
        } | ConvertTo-Json -Depth 15

        if ($WhatIf) {
            Write-Host "[WhatIf] Would create relationship: $relEntity -> $refEntity ($lookupSchema)" -ForegroundColor Cyan
            $relCreated++
            continue
        }

        try {
            $null = Invoke-RestMethod -Uri "$baseUri/RelationshipDefinitions" -Method Post -Headers $headers -Body $body
            Write-Host "Created relationship: $relEntity -> $refEntity ($lookupSchema)" -ForegroundColor Green
            $relCreated++
        } catch {
            if ($_.Exception.Message -match 'already exists|duplicate') {
                Write-Host "Relationship already exists: $relEntity -> $refEntity - skipping." -ForegroundColor Yellow
            } else {
                Write-Warning "Failed relationship $relEntity -> $refEntity : $_"
                if ($_.Exception.Response) {
                    try {
                        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                        $reader.BaseStream.Position = 0
                        Write-Host $reader.ReadToEnd()
                    } catch {}
                }
            }
        }
    }
    Write-Host "Relationships created/attempted: $relCreated" -ForegroundColor Green
}

Write-Host "Done. Publish customizations in Power Platform admin or solution to apply changes." -ForegroundColor Cyan
