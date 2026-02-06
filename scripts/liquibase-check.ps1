# verificación rápida de “drift” (solo schema y estado)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "== LOCAL ==" -ForegroundColor Yellow
.\scripts\liquibase-local.ps1 validate
.\scripts\liquibase-local.ps1 status

Write-Host "== SUPABASE ==" -ForegroundColor Yellow
.\scripts\liquibase-supabase.ps1 validate
.\scripts\liquibase-supabase.ps1 status
