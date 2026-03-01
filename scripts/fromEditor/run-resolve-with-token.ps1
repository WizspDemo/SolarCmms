$tokenPath = 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmms\token.txt'
if (-not (Test-Path $tokenPath)) { Write-Error "Token file not found: $tokenPath"; exit 1 }
$token = (Get-Content -Raw $tokenPath).Trim()
& 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo\scripts\resolve-solardev-entities.ps1' -EnvironmentUrl 'https://org08dc9606.crm4.dynamics.com' -MetadataIdFile 'C:\Users\mapos\OneDrive - WIZSP S.R.L\GitHub\Wizspplayroom\SolarCmmsDemo\exports\solardev_ids.txt' -AccessToken $token