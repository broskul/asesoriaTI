# 1. ACTIVAR CUENTA ADMINISTRADOR LOCAL
Write-Output "Activando cuenta de Administrador..."
net user Administrator /active:yes

# 2. ASIGNAR CONTRASEÑA SEGURA
$adminPassword = "Plusmedic#l2023"
net user Administrator $adminPassword

# 3. NOMBRE DEL USUARIO CORRECTO
$currentUser = (whoami)
$currentUserName = (Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[-1]

# Si el usuario es local y distinto a "Plusmedical SpA", lo renombramos
if ($currentUserName -ne "Plusmedical SpA") {
    if ($currentUser -like "*@*") {
        Write-Output "La cuenta actual es una cuenta Microsoft o online. No puede ser renombrada directamente."
        Write-Output "Por favor, cree una cuenta local con el nombre 'Plusmedical SpA' y migre los datos si es necesario."
    } else {
        Write-Output "Renombrando cuenta local: $currentUserName -> Plusmedical SpA"
        net user "$currentUserName" /fullname:"Plusmedical SpA"
        Rename-LocalUser -Name "$currentUserName" -NewName "Plusmedical SpA"
    }
} else {
    Write-Output "El usuario ya tiene el nombre 'Plusmedical SpA'."
}

# 4. LIMPIAR APLICACIONES NO NECESARIAS
Write-Output "Eliminando aplicaciones innecesarias..."

$apps = @(
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.WindowsFeedbackHub", 
    "Microsoft.GetHelp", 
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.SkypeApp",
    "Microsoft.News"
)

foreach ($app in $apps) {
    Write-Output "Eliminando: $app"
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 5. INSTALACIÓN DE ANYDESK SI NO ESTÁ PRESENTE
$anydeskPath = "${env:ProgramFiles(x86)}\AnyDesk\AnyDesk.exe"
if (Test-Path $anydeskPath) {
    Write-Output "AnyDesk ya está instalado. Ruta: $anydeskPath"
} else {
    Write-Output "Descargando e instalando AnyDesk..."
    $anydeskUrl = "https://download.anydesk.com/AnyDesk.exe"
    $installerPath = "$env:TEMP\AnyDesk.exe"
    Invoke-WebRequest -Uri $anydeskUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait
    Write-Output "AnyDesk instalado correctamente."
}

Write-Output "✅ Configuración del equipo TI completada con éxito."
