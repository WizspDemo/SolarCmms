# Create solar_performance table and columns in Solardev solution via Dataverse Web API.
# Requires: token file (or -UseDeviceCode), Solardev solution.

param(
    [string]$TokenPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'token.txt'),  # SolarCmms\token.txt
    [string]$EnvironmentUrl = 'https://org08dc9606.crm4.dynamics.com',
    [string]$SolutionUniqueName = 'Solardev',
    [switch]$WhatIf,
    [switch]$UseDeviceCode  # Get token via MSAL device code when token.txt missing
)

$ErrorActionPreference = 'Stop'

# Get token: from file, or via device code
$token = $null
if (Test-Path $TokenPath) {
    $token = (Get-Content -Raw $TokenPath).Trim()
} elseif ($UseDeviceCode) {
    try {
        if (-not (Get-Module -ListAvailable MSAL.PS)) { Install-Module -Name MSAL.PS -Scope CurrentUser -Force }
        $auth = Get-MsalToken -ClientId '872cd9fa-d31f-45e0-9eab-6e460a02d1f1' -TenantId 'common' -Scopes "$EnvironmentUrl/.default" -DeviceCode
        $token = $auth.AccessToken
    } catch {
        Write-Error "Device code auth failed. Install MSAL.PS: Install-Module MSAL.PS. Error: $_"
        exit 1
    }
} else {
    Write-Error "Token file not found: $TokenPath. Use -UseDeviceCode to authenticate interactively, or create token.txt."
    exit 1
}

$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json; charset=utf-8'
    'Accept'       = 'application/json'
    'OData-MaxVersion' = '4.0'
    'OData-Version'    = '4.0'
    'MSCRM.SolutionUniqueName' = $SolutionUniqueName
}

function New-Label {
    param([string]$Label, [int]$LanguageCode = 1033)
    @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.Label'
        'LocalizedLabels' = @(
            @{ '@odata.type' = 'Microsoft.Dynamics.CRM.LocalizedLabel'; 'Label' = $Label; 'LanguageCode' = $LanguageCode }
        )
    }
}

$baseUri = "$EnvironmentUrl/api/data/v9.2"

# ----- 1. Create solar_performance entity -----
$entityBody = @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.EntityMetadata'
    'SchemaName' = 'solar_Performance'
    'DisplayName' = New-Label -Label 'Performance'
    'DisplayCollectionName' = New-Label -Label 'Performances'
    'Description' = New-Label -Label 'KPI performance data (PR, AV, LD, En, Irrad) per month/year'
    'OwnershipType' = 'OrganizationOwned'
    'IsActivity' = $false
    'HasNotes' = $false
    'HasActivities' = $false
    'Attributes' = @(
        @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.StringAttributeMetadata'
            'AttributeType' = 'String'
            'AttributeTypeName' = @{ 'Value' = 'StringType' }
            'SchemaName' = 'solar_PerformanceName'
            'DisplayName' = New-Label -Label 'Name'
            'Description' = New-Label -Label 'Primary name'
            'IsPrimaryName' = $true
            'RequiredLevel' = @{ 'Value' = 'ApplicationRequired'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
            'FormatName' = @{ 'Value' = 'Text' }
            'MaxLength' = 255
        }
    )
} | ConvertTo-Json -Depth 15

if ($WhatIf) {
    Write-Host "[WhatIf] Would create entity: solar_performance" -ForegroundColor Cyan
} else {
    try {
        $null = Invoke-RestMethod -Uri "$baseUri/EntityDefinitions" -Method Post -Headers $headers -Body $entityBody
        Write-Host "Created entity: solar_performance" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -match 'already exists') {
            Write-Host "Entity solar_performance already exists - skipping." -ForegroundColor Yellow
        } else { throw }
    }
}

# ----- 2. Create columns -----
$columns = @(
    @{
        SchemaName = 'solar_Month'
        Type = 'Picklist'
        DisplayName = 'Month'
        Options = @(
            @{ Value = 1; Label = 'Jan' }, @{ Value = 2; Label = 'Feb' }, @{ Value = 3; Label = 'Mar' },
            @{ Value = 4; Label = 'Apr' }, @{ Value = 5; Label = 'May' }, @{ Value = 6; Label = 'Jun' },
            @{ Value = 7; Label = 'Jul' }, @{ Value = 8; Label = 'Aug' }, @{ Value = 9; Label = 'Sep' },
            @{ Value = 10; Label = 'Oct' }, @{ Value = 11; Label = 'Nov' }, @{ Value = 12; Label = 'Dec' }
        )
    },
    @{ SchemaName = 'solar_Year'; Type = 'Integer'; DisplayName = 'Year'; MinValue = 2000; MaxValue = 2100 },
    @{ SchemaName = 'solar_PR'; Type = 'Decimal'; DisplayName = 'PR'; Description = 'Performance Ratio (%)'; Precision = 2 },
    @{ SchemaName = 'solar_AV'; Type = 'Decimal'; DisplayName = 'AV'; Description = 'Availability (%)'; Precision = 2 },
    @{ SchemaName = 'solar_LD'; Type = 'Money'; DisplayName = 'LD'; Description = 'Loss/Damage (£)'; Precision = 2 },
    @{ SchemaName = 'solar_En'; Type = 'Decimal'; DisplayName = 'En'; Description = 'Energy (kWh)'; Precision = 2 },
    @{ SchemaName = 'solar_Irrad'; Type = 'Decimal'; DisplayName = 'Irrad'; Description = 'Irradiance (kWh/m²)'; Precision = 2 }
)

foreach ($col in $columns) {
    $body = $null
    if ($col.Type -eq 'Picklist') {
        $opts = $col.Options | ForEach-Object {
            @{
                'Value' = [int]$_.Value
                'Label' = New-Label -Label $_.Label
            }
        }
        $body = @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.PicklistAttributeMetadata'
            'AttributeType' = 'Picklist'
            'AttributeTypeName' = @{ 'Value' = 'PicklistType' }
            'SchemaName' = $col.SchemaName
            'DisplayName' = New-Label -Label $col.DisplayName
            'RequiredLevel' = @{ 'Value' = 'ApplicationRequired'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
            'OptionSet' = @{
                '@odata.type' = 'Microsoft.Dynamics.CRM.OptionSetMetadata'
                'Options' = $opts
                'IsGlobal' = $false
            }
        } | ConvertTo-Json -Depth 15
    } elseif ($col.Type -eq 'Integer') {
        $body = @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.IntegerAttributeMetadata'
            'AttributeType' = 'Integer'
            'AttributeTypeName' = @{ 'Value' = 'IntegerType' }
            'SchemaName' = $col.SchemaName
            'DisplayName' = New-Label -Label $col.DisplayName
            'RequiredLevel' = @{ 'Value' = 'ApplicationRequired'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
            'MinValue' = $col.MinValue
            'MaxValue' = $col.MaxValue
        } | ConvertTo-Json -Depth 15
    } elseif ($col.Type -eq 'Decimal') {
        $body = @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.DecimalAttributeMetadata'
            'AttributeType' = 'Decimal'
            'AttributeTypeName' = @{ 'Value' = 'DecimalType' }
            'SchemaName' = $col.SchemaName
            'DisplayName' = New-Label -Label $col.DisplayName
            'Description' = if ($col.Description) { New-Label -Label $col.Description } else { New-Label -Label '' }
            'RequiredLevel' = @{ 'Value' = 'None'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
            'Precision' = $col.Precision
        } | ConvertTo-Json -Depth 15
    } elseif ($col.Type -eq 'Money') {
        $body = @{
            '@odata.type' = 'Microsoft.Dynamics.CRM.MoneyAttributeMetadata'
            'AttributeType' = 'Money'
            'AttributeTypeName' = @{ 'Value' = 'MoneyType' }
            'SchemaName' = $col.SchemaName
            'DisplayName' = New-Label -Label $col.DisplayName
            'Description' = if ($col.Description) { New-Label -Label $col.Description } else { New-Label -Label '' }
            'RequiredLevel' = @{ 'Value' = 'None'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
            'Precision' = $col.Precision
        } | ConvertTo-Json -Depth 15
    }

    if ($body) {
        if ($WhatIf) {
            Write-Host "[WhatIf] Would create column: $($col.SchemaName)" -ForegroundColor Cyan
        } else {
            try {
                $null = Invoke-RestMethod -Uri "$baseUri/EntityDefinitions(LogicalName='solar_performance')/Attributes" -Method Post -Headers $headers -Body $body
                Write-Host "Created column: $($col.SchemaName)" -ForegroundColor Green
            } catch {
                if ($_.Exception.Message -match 'already exists') {
                    Write-Host "Column $($col.SchemaName) already exists - skipping." -ForegroundColor Yellow
                } else { Write-Warning "Failed $($col.SchemaName): $_" }
            }
        }
    }
}

# ----- 3. Create Solar Park lookup (solar_performance -> new_account) -----
$lookupBody = @{
    '@odata.type' = 'Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata'
    'SchemaName' = 'solar_performance_solar_Park'
    'ReferencedEntity' = 'new_account'
    'ReferencedAttribute' = 'new_accountid'
    'ReferencingEntity' = 'solar_performance'
    'Lookup' = @{
        '@odata.type' = 'Microsoft.Dynamics.CRM.LookupAttributeMetadata'
        'AttributeType' = 'Lookup'
        'AttributeTypeName' = @{ 'Value' = 'LookupType' }
        'SchemaName' = 'solar_Park'
        'DisplayName' = New-Label -Label 'Solar Park'
        'Description' = New-Label -Label 'Solar Park (Park Account)'
        'RequiredLevel' = @{ 'Value' = 'ApplicationRequired'; 'CanBeChanged' = $true; 'ManagedPropertyLogicalName' = 'canmodifyrequirementlevelsettings' }
    }
} | ConvertTo-Json -Depth 15

if ($WhatIf) {
    Write-Host "[WhatIf] Would create lookup: solar_Park -> new_account" -ForegroundColor Cyan
} else {
    try {
        $null = Invoke-RestMethod -Uri "$baseUri/RelationshipDefinitions" -Method Post -Headers $headers -Body $lookupBody
        Write-Host "Created lookup: solar_Park -> new_account" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -match 'already exists') {
            Write-Host "Lookup solar_Park already exists - skipping." -ForegroundColor Yellow
        } else { Write-Warning "Failed solar_Park lookup: $_" }
    }
}

Write-Host "Done. Publish customizations to apply changes." -ForegroundColor Cyan
