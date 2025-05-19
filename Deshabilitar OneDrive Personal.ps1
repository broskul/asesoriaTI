# Mostrar encabezado
Write-Host "--------------------------------------------" -ForegroundColor DarkCyan
Write-Host "     DESHABILITAR ONEDRIVE PERSONAL" -ForegroundColor Cyan
Write-Host "--------------------------------------------" -ForegroundColor DarkCyan

# Auto-elevación si no está en modo administrador
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {

    Write-Host "Este script requiere privilegios de administrador. Solicitando elevación..." -ForegroundColor Yellow

    $arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments

    exit
}

# 1. Crear clave de política si no existe
Write-Host "Creando clave de registro..." -NoNewline
try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "OneDrive" -Force | Out-Null
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " ERROR" -ForegroundColor Red
    $resultado = "Sin Éxito"
    goto EnviarNotificacion
}

# 2. Aplicar la política
Write-Host "Aplicando política DisablePersonalSync..." -NoNewline
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DisablePersonalSync" -Type DWord -Value 1
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " ERROR" -ForegroundColor Red
    $resultado = "Sin Éxito"
    goto EnviarNotificacion
}

# 3. Verificar política
Write-Host "Verificando si la política fue aplicada..." -NoNewline
try {
    $valor = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DisablePersonalSync"
    if ($valor.DisablePersonalSync -eq 1) {
        Write-Host " OK" -ForegroundColor Green
        $resultado = "Exitoso"
    } else {
        Write-Host " FALLÓ" -ForegroundColor Yellow
        $resultado = "Con Problemas"
    }
} catch {
    Write-Host " ERROR" -ForegroundColor Red
    $resultado = "Sin Éxito"
}

# 4. Reiniciar OneDrive
Write-Host "Reiniciando OneDrive..."
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "OneDrive reiniciado." -ForegroundColor Green

# 5. Mostrar resultado visual
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("Resultado: $resultado`nEquipo: $env:COMPUTERNAME","Deshabilitar OneDrive Personal")

# 6. Enviar notificación a Wix
:EnviarNotificacion
Write-Host "Enviando notificación a Wix..." -NoNewline

$payload = @{
  nombreScript = "Deshabilitar OneDrive Personal"
  equipo = $env:COMPUTERNAME
  usuario = $env:USERNAME
  fecha = (Get-Date).ToString("s")
  resultado = $resultado
} | ConvertTo-Json -Depth 3

try {
    Invoke-RestMethod -Method POST `
      -Uri "https://www.plusmedicalchile.cl/_functions/ejecutarScript" `
      -Body $payload `
      -ContentType "application/json"
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Pausa final para que no se cierre la consola
Write-Host "`nPresiona ENTER para cerrar..." -ForegroundColor Gray
[void][System.Console]::ReadLine()
