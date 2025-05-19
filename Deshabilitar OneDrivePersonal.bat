# Ejecutar como administrador

# 1. Crear clave de política si no existe
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "OneDrive" -Force | Out-Null

# 2. Aplicar política para bloquear cuentas personales
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DisablePersonalSync" -Type DWord -Value 1

# 3. Verificar si se aplicó correctamente
$politicaAplicada = $false
try {
    $valor = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DisablePersonalSync" -ErrorAction Stop
    if ($valor.DisablePersonalSync -eq 1) {
        $politicaAplicada = $true
    }
} catch {
    $politicaAplicada = $false
}

# 4. Reiniciar OneDrive
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"

# 5. Mostrar mensaje al usuario
Add-Type -AssemblyName System.Windows.Forms

if ($politicaAplicada) {
    [System.Windows.Forms.MessageBox]::Show("✅ OneDrive Personal ha sido deshabilitado correctamente. La aplicación se reinició.","Proceso completado")
    $resultado = "Exitoso"
} else {
    [System.Windows.Forms.MessageBox]::Show("⚠️ No se pudo confirmar que la política fue aplicada. Verifica permisos de administrador.","Proceso con problemas")
    $resultado = "Sin Éxito"
}

# 6. Enviar notificación a Wix para registrar en SharePoint
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
} catch {
    Write-Host "❌ No se pudo enviar la notificación a Wix: $($_.Exception.Message)" -ForegroundColor Red
}
