# ejecutar Liquibase contra SUPABASE

# .\scripts\liquibase-supabase.ps1 validate
# .\scripts\liquibase-supabase.ps1 updateSQL
# .\scripts\liquibase-supabase.ps1 update

Param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("validate","update","updateSQL","status","history")]
  [string]$Command,

  [string]$OutFile = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DefaultsFile = "/workspace/db/liquibase/properties/liquibase.supabase.properties"

Write-Host "Liquibase SUPABASE -> $Command" -ForegroundColor Cyan

if ($Command -eq "updateSQL" -and [string]::IsNullOrWhiteSpace($OutFile)) {
  $OutFile = ".\proparcon-api\db\liquibase\_supabase_update_preview.sql"
}

if ($Command -eq "updateSQL") {
  docker compose run --rm liquibase `
    --defaults-file=$DefaultsFile `
    $Command | Out-File -Encoding UTF8 $OutFile

  Write-Host "SQL preview guardado en: $OutFile" -ForegroundColor Green
  exit 0
}

docker compose run --rm liquibase `
  --defaults-file=$DefaultsFile `
  $Command
