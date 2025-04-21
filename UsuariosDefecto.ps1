# verificar si PowerShell está corriendo como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Reiniciando como administrador..."
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# detectar nombre real del grupo de administradores según idioma del sistema
$adminGroupName = (Get-LocalGroup | Where-Object { $_.SID -like "*-544" }).Name

# Solicitar nombre de empresa
$empresa = Read-Host "Ingresa el nombre de la empresa (ej. Plusmedical)"

# Solicitar contraseña segura para el usuario principal (empresa)
$passEmpresa = Read-Host -AsSecureString "Ingresa la contraseña para el usuario $empresa"

# Crear el usuario con el nombre de la empresa
if (-not (Get-LocalUser -Name $empresa -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $empresa -Password $passEmpresa -FullName $empresa -Description "Cuenta administrativa local para $empresa" -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group $adminGroupName -Member $empresa
    Write-Output "`nUsuario $empresa creado correctamente con permisos de administrador."
} else {
    Write-Output "`nEl usuario $empresa ya existe."
}

# Crear el usuario Administrador TI (solo si no existe)
$adminTIUser = "Administrador TI"
$adminTIPassword = ConvertTo-SecureString "Plu`$medical2023" -AsPlainText -Force

if (-not (Get-LocalUser -Name $adminTIUser -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $adminTIUser -Password $adminTIPassword -FullName "Administrador TI" -Description "Cuenta de administración técnica" -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group $adminGroupName -Member $adminTIUser
    Write-Output "`nUsuario $adminTIUser creado correctamente con permisos de administrador."
} else {
    Write-Output "`nEl usuario $adminTIUser ya existe."
}

# -----------------------
# Marcar OOBE como completo
# -----------------------

# Ruta: HKEY_LOCAL_MACHINE\SYSTEM\Setup
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "CmdLine" -Value ""
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "OOBEInProgress" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "SetupPhase" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "SetupType" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "SystemSetupInProgress" -Value 0

# Ruta: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State
$setupStatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State"
if (-not (Test-Path $setupStatePath)) {
    New-Item -Path $setupStatePath -Force | Out-Null
}
Set-ItemProperty -Path $setupStatePath -Name "ImageState" -Value "IMAGE_STATE_COMPLETE"

Write-Output "`nOOBE marcado como completado correctamente."
