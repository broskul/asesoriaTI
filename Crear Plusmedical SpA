# 1. Definir el nombre y la contraseña del nuevo usuario
$userName = "Plusmedical SpA"
$plainPassword = "Plusm3dic#l"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

# 2. Verificar si la cuenta ya existe
if (Get-LocalUser -Name $userName -ErrorAction SilentlyContinue) {
    Write-Output "El usuario '$userName' ya existe. No se creará nuevamente."
} else {
    # 3. Crear nueva cuenta local
    Write-Output "Creando cuenta local: $userName ..."
    New-LocalUser -Name $userName `
                  -Password $securePassword `
                  -FullName "Plusmedical SpA" `
                  -Description "Creada por Prof3sional - TI"

    # 4. Agregar la cuenta al grupo de administradores locales
    Add-LocalGroupMember -Group "Administradores" -Member $userName

    Write-Output "✅ Usuario '$userName' creado y agregado al grupo Administradores."
}

# 5. LIMPIAR APLICACIONES NO NECESARIAS
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

# 6. INSTALACIÓN DE ANYDESK SI NO ESTÁ PRESENTE
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
