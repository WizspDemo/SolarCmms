<#
Resolve Solardev entity MetadataId GUIDs to logical names using Dataverse Web API.

Usage examples:
.	# Provide env URL and token and metadata IDs inline
.	.	$envUrl = "https://org08dc9606.crm.dynamics.com"
.		.	$ids = @(
.			"dba65751-fb7d-f011-b4cb-000d3a275226",
.			"78750cb9-638d-f011-b4cb-6045bd92fd6a"
.		)
.		.	./resolve-solardev-entities.ps1 -EnvironmentUrl $envUrl -MetadataIds $ids -AccessToken "<PASTE_TOKEN>"

	# Or read ids from file (one GUID per line):
	./resolve-solardev-entities.ps1 -EnvironmentUrl $envUrl -MetadataIdFile "ids.txt"

This script requires a valid Dataverse access token (Bearer). You can obtain one via Azure CLI, Power Platform CLI, or other OAuth flows.
The script will write CSV to `SolarCmmsDemo/exports/solardev_tables.csv` by default.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl,

    [string[]]$MetadataIds,

    [string]$MetadataIdFile,

    [string]$AccessToken,

    [string]$OutputCsv = "c:/Users/mapos/OneDrive - WIZSP S.R.L/GitHub/Wizspplayroom/SolarCmmsDemo/exports/solardev_tables.csv",

    [int]$DelayMs = 200
)

function Get-AccessTokenInteractive {
    Write-Host "No access token provided. Please paste a valid Dataverse access token (Bearer):"
    $token = Read-Host -AsSecureString "Access Token"
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))
}

if (-not $MetadataIds -and -not $MetadataIdFile) {
    Write-Error "Provide either -MetadataIds or -MetadataIdFile (one GUID per line)."
    exit 1
}

if ($MetadataIdFile) {
    if (-not (Test-Path $MetadataIdFile)) {
        Write-Error "MetadataIdFile not found: $MetadataIdFile"
        exit 1
    }
    $MetadataIds = Get-Content $MetadataIdFile | Where-Object { $_ -match '[0-9a-fA-F\-]{36}' }
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

$result = @()

foreach ($id in $MetadataIds) {
    $trimmed = $id.Trim()
    if (-not ($trimmed -match '^[0-9a-fA-F\-]{36}$')) { continue }
    $baseUrl = $EnvironmentUrl.TrimEnd('/')
    $url = "$baseUrl/api/data/v9.2/EntityDefinitions?`$filter=MetadataId eq $trimmed"
    try {
        $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop
        if ($resp.value -and $resp.value.Count -gt 0) {
            $entity = $resp.value[0]
            $obj = [PSCustomObject]@{
                MetadataId = $trimmed
                LogicalName = $entity.LogicalName
                SchemaName  = $entity.SchemaName
            }
        } else {
            $obj = [PSCustomObject]@{
                MetadataId = $trimmed
                LogicalName = $null
                SchemaName  = $null
                Error       = "No entity found with MetadataId"
            }
        }
    } catch {
        $errorMsg = $_.Exception.Message
        # Try to get more details from the error response if available
        if ($_.ErrorDetails.Message) {
            $errorMsg = "$($_.Exception.Message) - $($_.ErrorDetails.Message)"
        }
        $obj = [PSCustomObject]@{
            MetadataId = $trimmed
            LogicalName = $null
            SchemaName  = $null
            Error       = $errorMsg
        }
    }
    $result += $obj
    Start-Sleep -Milliseconds $DelayMs
}

# Ensure output directory exists
$dir = Split-Path -Path $OutputCsv -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

$result | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Wrote $($result.Count) rows to $OutputCsv"
