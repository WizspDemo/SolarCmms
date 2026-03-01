$tokenPath = 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmms\token.txt'
if (-not (Test-Path $tokenPath)) { Write-Error "Token file not found: $tokenPath"; exit 1 }
$token = (Get-Content -Raw $tokenPath).Trim()

$inputCsv = 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo\exports\solardev_tables.csv'

& 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo\scripts\export-entity-metadata.ps1' `
    -EnvironmentUrl 'https://org08dc9606.crm4.dynamics.com' `
    -InputCsv $inputCsv `
    -AccessToken $token