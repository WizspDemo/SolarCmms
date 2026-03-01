# Create Maintenance Team Category Table in Dataverse
# Logical Name: solar_maintenance_team_category

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl,  # e.g., https://yourorg.crm4.dynamics.com
    
    [Parameter(Mandatory=$false)]
    [string]$AccessToken
)

$ErrorActionPreference = "Stop"

# Αν δεν υπάρχει AccessToken, ζητάμε authentication
if (-not $AccessToken) {
    Write-Host "Χρειάζεστε Access Token. Χρησιμοποιήστε ένα από τα παρακάτω:" -ForegroundColor Yellow
    Write-Host "1. Azure CLI: az account get-access-token --resource=$EnvironmentUrl --query accessToken -o tsv" -ForegroundColor Cyan
    Write-Host "2. Power Platform CLI: pac auth create --url $EnvironmentUrl" -ForegroundColor Cyan
    Write-Host ""
    $AccessToken = Read-Host "Εισάγετε το Access Token"
}

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
}

$apiUrl = "$EnvironmentUrl/api/data/v9.2"

Write-Host "Δημιουργία Table: solar_maintenance_team_category..." -ForegroundColor Green

# Entity Definition
$entityDefinition = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.EntityMetadata"
    "SchemaName" = "solar_maintenance_team_category"
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
                "Label" = "Categories for Maintenance Teams"
                "LanguageCode" = 1033
            }
        )
    }
    "OwnershipType" = "UserOwned"
    "IsActivity" = $false
    "HasActivities" = $false
    "HasNotes" = $true
    "Attributes" = @(
        # Primary Name Attribute
        @{
            "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
            "SchemaName" = "solar_name"
            "RequiredLevel" = @{
                "Value" = "ApplicationRequired"
                "CanBeChanged" = $true
            }
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
            "MaxLength" = 255
            "FormatName" = @{
                "Value" = "Text"
            }
            "AttributeTypeName" = @{
                "Value" = "StringType"
            }
        }
    )
    "HasFeedback" = $false
}

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/EntityDefinitions" `
        -Method Post `
        -Headers $headers `
        -Body ($entityDefinition | ConvertTo-Json -Depth 10)
    
    Write-Host "✓ Table δημιουργήθηκε επιτυχώς!" -ForegroundColor Green
    Write-Host "Entity ID: $($response.MetadataId)" -ForegroundColor Cyan
    
    # Περιμένουμε λίγο για να ολοκληρωθεί η δημιουργία
    Start-Sleep -Seconds 3
    
    Write-Host "`nΔημιουργία επιπλέον πεδίων..." -ForegroundColor Green
    
    # Προσθήκη solar_code
    $codeAttribute = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
        "SchemaName" = "solar_code"
        "DisplayName" = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            "LocalizedLabels" = @(
                @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    "Label" = "Code"
                    "LanguageCode" = 1033
                }
            )
        }
        "MaxLength" = 100
        "FormatName" = @{
            "Value" = "Text"
        }
        "AttributeTypeName" = @{
            "Value" = "StringType"
        }
    }
    
    Invoke-RestMethod -Uri "$apiUrl/EntityDefinitions(LogicalName='solar_maintenance_team_category')/Attributes" `
        -Method Post `
        -Headers $headers `
        -Body ($codeAttribute | ConvertTo-Json -Depth 10) | Out-Null
    
    Write-Host "✓ Πεδίο 'Code' προστέθηκε" -ForegroundColor Green
    
    # Προσθήκη solar_description
    $descriptionAttribute = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.MemoAttributeMetadata"
        "SchemaName" = "solar_description"
        "DisplayName" = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            "LocalizedLabels" = @(
                @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    "Label" = "Description"
                    "LanguageCode" = 1033
                }
            )
        }
        "MaxLength" = 100000
        "Format" = "Text"
        "AttributeTypeName" = @{
            "Value" = "MemoType"
        }
    }
    
    Invoke-RestMethod -Uri "$apiUrl/EntityDefinitions(LogicalName='solar_maintenance_team_category')/Attributes" `
        -Method Post `
        -Headers $headers `
        -Body ($descriptionAttribute | ConvertTo-Json -Depth 10) | Out-Null
    
    Write-Host "✓ Πεδίο 'Description' προστέθηκε" -ForegroundColor Green
    
    # Προσθήκη solar_parentid (Self-referencing lookup)
    $parentAttribute = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.LookupAttributeMetadata"
        "SchemaName" = "solar_parentid"
        "DisplayName" = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            "LocalizedLabels" = @(
                @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    "Label" = "Parent Category"
                    "LanguageCode" = 1033
                }
            )
        }
        "AttributeTypeName" = @{
            "Value" = "LookupType"
        }
        "Targets" = @("solar_maintenance_team_category")
    }
    
    Invoke-RestMethod -Uri "$apiUrl/EntityDefinitions(LogicalName='solar_maintenance_team_category')/Attributes" `
        -Method Post `
        -Headers $headers `
        -Body ($parentAttribute | ConvertTo-Json -Depth 10) | Out-Null
    
    Write-Host "✓ Πεδίο 'Parent Category' προστέθηκε" -ForegroundColor Green
    
    Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "✓ Όλα ολοκληρώθηκαν επιτυχώς!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Table Name: solar_maintenance_team_category" -ForegroundColor White
    Write-Host "Primary Key: solar_maintenance_team_categoryid" -ForegroundColor White
    
} catch {
    Write-Host "✗ Σφάλμα: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host "Details: $responseBody" -ForegroundColor Red
    }
    exit 1
}
