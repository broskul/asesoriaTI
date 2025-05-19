# Ejecutar como administrador

# Crear la clave de OneDrive si no existe
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "OneDrive" -Force | Out-Null

# Deshabilitar el uso de cuentas personales en OneDrive
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DisablePersonalSync" -Type DWord -Value 1

# Confirmación
Write-Host "El uso de cuentas personales en OneDrive ha sido deshabilitado en este equipo." -ForegroundColor Green
