# ejecutar Liquibase contra LOCAL
#
# .\scripts\liquibase-local.ps1 validate
# .\scripts\liquibase-local.ps1 update
# .\scripts\liquibase-local.ps1 updateSQL

Param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("validate","update","updateSQL","status","history","changelogSync")]
  [string]$Command,

  # Solo aplica a updateSQL, por si quieres redirigir fácil a un fichero
  [string]$OutFile = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DefaultsFile = "/workspace/db/liquibase/properties/liquibase.local.properties"
$Classpath    = "/liquibase/classpath/postgresql-42.7.3.jar"

Write-Host "Liquibase LOCAL -> $Command" -ForegroundColor Cyan

if ($Command -eq "updateSQL" -and [string]::IsNullOrWhiteSpace($OutFile)) {
  $OutFile = ".\proparcon-api\db\liquibase\_local_update_preview.sql"
}

if ($Command -eq "updateSQL") {
  docker compose run --rm liquibase `
    --classpath=$Classpath `
    --defaults-file=$DefaultsFile `
    $Command | Out-File -Encoding UTF8 $OutFile

  Write-Host "SQL preview guardado en: $OutFile" -ForegroundColor Green
  exit 0
}

docker compose run --rm liquibase `
  --classpath=$Classpath `
  --defaults-file=$DefaultsFile `
  $Command
