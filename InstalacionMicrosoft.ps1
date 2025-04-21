# Solicitar datos al usuario
$correo = Read-Host "Ingresa tu cuenta Microsoft profesional (ej: nombre@empresa.com)"
$nombrePerfil = ($correo.Split("@")[0]) + "_MS"
$perfilPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\$nombrePerfil"
$urlLogin = "https://login.microsoftonline.com/"

# Crear perfil Edge si no existe
if (-not (Test-Path $perfilPath)) {
    Write-Host "🧱 Creando perfil Edge: $nombrePerfil"
    New-Item -ItemType Directory -Path $perfilPath | Out-Null
} else {
    Write-Host "📁 El perfil $nombrePerfil ya existe."
}

# Abrir Edge con el perfil al login de Microsoft
Write-Host "`n🌐 Abriendo navegador para iniciar sesión..."
Start-Process "msedge.exe" "--user-data-dir=""$perfilPath"" $urlLogin"
Start-Sleep -Seconds 5

# Iniciar OneDrive
Write-Host "`n☁️ Iniciando OneDrive..."
Start-Process "onedrive.exe"
Start-Sleep -Seconds 5

# Iniciar Office (Word como ejemplo)
Write-Host "`n📄 Abriendo Word..."
Start-Process "winword.exe"
Start-Sleep -Seconds 5

# Mensaje final
Write-Host "`n✅ Listo. Usa el mismo pase temporal para iniciar sesión en todas las ventanas si lo solicita."
Write-Host "Este perfil quedará guardado como:" $nombrePerfil"
