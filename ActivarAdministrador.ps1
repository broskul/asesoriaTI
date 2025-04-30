# Asegurar que se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Activar cuenta Administrador y asignar contraseña
$adminUser = "Administrador"
$adminPass = ConvertTo-SecureString "Plu`$medical2023" -AsPlainText -Force

Enable-LocalUser -Name $adminUser
Set-LocalUser -Name $adminUser -Password $adminPass

Write-Output "`n✅ Cuenta 'Administrador' activada con clave Plu$medical2023"
