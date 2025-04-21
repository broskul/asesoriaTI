# Solicitar correo profesional
$correo = Read-Host "Ingresa tu cuenta Microsoft profesional (ej: nombre@empresa.com)"
$urlLogin = "https://login.microsoftonline.com/"
$perfilNombreDeseado = "Plusmedical"
$localStatePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State"
$perfilDefaultPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"

# ============ CAMBIAR NOMBRE DEL PERFIL DE EDGE ============

if (Test-Path $localStatePath) {
    try {
        # Cerrar Edge si está abierto
        Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force

        # Leer configuración JSON
        $json = Get-Content $localStatePath -Raw | ConvertFrom-Json

        # Asignar nuevo nombre al perfil por defecto
        $json.profile.name = $perfilNombreDeseado

        # Guardar cambios
        $json | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $localStatePath

        Write-Host "`n✅ Perfil principal renombrado a '$perfilNombreDeseado'."
    } catch {
        Write-Host "❌ Error al modificar el perfil de Edge: $_"
    }
} else {
    Write-Host "⚠️ No se encontró el archivo de configuración de Edge. ¿Edge está instalado?"
}

# ============ ABRIR EDGE CON EL PERFIL DEFAULT ============

Write-Host "`n🌐 Abriendo navegador para iniciar sesion..."
Start-Process "msedge.exe" "--profile-directory=Default $urlLogin"
Start-Sleep -Seconds 5

# ============ VERIFICAR E INSTALAR ONEDRIVE SI FALTA ============

$onedrivePath = "$env:SYSTEMROOT\System32\OneDrive.exe"

if (-not (Test-Path $onedrivePath)) {
    Write-Host "`n☁️ OneDrive no está instalado. Descargando e instalando..."
    $installer = "$env:TEMP\OneDriveSetup.exe"
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=844652" -OutFile $installer -UseBasicParsing
    Start-Process -FilePath $installer -ArgumentList "/silent" -Wait

    if (Test-Path $onedrivePath) {
        Write-Host "✅ OneDrive instalado correctamente."
    } else {
        Write-Host "❌ No se pudo instalar OneDrive."
    }
} else {
    Write-Host "`n☁️ OneDrive ya está instalado."
}

# ============ INICIAR ONEDRIVE ============

Write-Host "`n🚀 Iniciando OneDrive..."
Start-Process "onedrive.exe"
Start-Sleep -Seconds 5

# ============ INICIAR WORD ============

Write-Host "`n📄 Abriendo Word..."
Start-Process "winword.exe"
Start-Sleep -Seconds 5

# ============ MENSAJE FINAL ============

Write-Host "`n✅ Configuración completa. Usa el mismo pase temporal para iniciar sesión en todas las ventanas si se solicita."
Write-Host "   El perfil principal de Edge ahora se llama: $perfilNombreDeseado"
