# Asegurar que se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 1. DETECTAR NOMBRE DE CUENTA DE ADMINISTRADOR INTEGRADO (Administrator o Administrador)
$adminAccount = Get-WmiObject Win32_UserAccount | Where-Object { $_.SID -like "*-500" } | Select-Object -ExpandProperty Name

Write-Output "Activando cuenta de Administrador: $adminAccount"
net user "$adminAccount" /active:yes

# 2. ASIGNAR CONTRASEÑA SEGURA A LA CUENTA DE ADMINISTRADOR
$adminPassword = "Plusmedic#l2023"
Write-Output "Asignando contraseña al usuario '$adminAccount'..."
net user "$adminAccount" $adminPassword

Write-Output "`n✅ Cuenta 'Administrador' activada
