# ---------------------------------------
# Script Maestro de Puesta en Marcha v1.0
# Carlos Rodríguez / Prof3sional
# ---------------------------------------

# Verificar si se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Reiniciando como administrador..."
    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Detectar nombre del grupo de administradores
$adminGroupName = (Get-LocalGroup | Where-Object { $_.SID -like "*-544" }).Name

# Solicitar datos
$empresa = Read-Host "Nombre de la empresa (ej. Plusmedical)"
$passEmpresaTexto = Read-Host "Contraseña para el usuario $empresa"
$passEmpresa = ConvertTo-SecureString $passEmpresaTexto -AsPlainText -Force

$nombreEquipo = Read-Host "Nombre que tendrá el equipo (hostname)"

# Renombrar el equipo
Rename-Computer -NewName $nombreEquipo -Force

# Crear usuario principal
if (-not (Get-LocalUser -Name $empresa -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $empresa -Password $passEmpresa -FullName $empresa -Description "Usuario principal de $empresa" -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group $adminGroupName -Member $empresa
    Write-Output "Usuario $empresa creado como administrador."
} else {
    Write-Output "El usuario $empresa ya existe."
}

# Crear usuario Administrador TI
$adminTIUser = "Administrador TI"
$adminTIPassword = ConvertTo-SecureString "Plu`$medical2023" -AsPlainText -Force

if (-not (Get-LocalUser -Name $adminTIUser -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $adminTIUser -Password $adminTIPassword -FullName "Administrador TI" -Description "Cuenta técnica" -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group $adminGroupName -Member $adminTIUser
    Write-Output "Usuario $adminTIUser creado como administrador."
} else {
    Write-Output "El usuario $adminTIUser ya existe."
}

# Establecer usuario principal como predeterminado en inicio de sesión
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $empresa
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value "."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"

# Asegurar visibilidad en pantalla de login
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" -Name "UserList" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $empresa -Value 1 -PropertyType DWord -Force | Out-Null

# Descargar e instalar AnyDesk
$anydeskUrl = "https://download.anydesk.com/AnyDesk.exe"
$installerPath = "$env:TEMP\AnyDesk.exe"
Invoke-WebRequest -Uri $anydeskUrl -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait
Write-Output "AnyDesk instalado correctamente."

# Reinicio final
Write-Output "`n✅ Puesta en marcha completada. Reiniciando en 10 segundos..."
Start-Sleep -Seconds 10
Restart-Computer -Force
