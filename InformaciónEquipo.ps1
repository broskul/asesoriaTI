# Obtener información de equipo
Add-Type -AssemblyName System.Windows.Forms

# Obtener nombre del equipo
$nombreDispositivo = $env:COMPUTERNAME

# Obtener procesador
$procesador = (Get-CimInstance Win32_Processor).Name

# Obtener info de módulos RAM
$modulos = Get-CimInstance Win32_PhysicalMemory

# Detectar si todos los módulos son del tipo soldado (FormFactor 12 o MemoryType LPDDR)
$ramSoldada = $modulos | Where-Object {
    $_.FormFactor -in  @(12, 0) -or $_.MemoryType -in @(24, 25, 26)
}

if ($ramSoldada.Count -eq $modulos.Count) {
    $ram = @(
        @{
            RAM1 = @{
                GBs              = [math]::Round(($modulos | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
                Bus              = $modulos[0].ConfiguredClockSpeed
                Slot             = "Integrada / LPDDR (RAM soldada)"
                Expandible       = $false
                Observacion      = "La memoria está soldada y no puede ampliarse"
            }
        }
    )
} else {
    $i = 1
    $ram = @()
    foreach ($modulo in $modulos) {
        $ram += @{
            ("RAM$i") = @{
                GBs        = [math]::Round($modulo.Capacity / 1GB, 2)
                Bus        = $modulo.ConfiguredClockSpeed
                Slot       = $modulo.BankLabel
                Expandible = $true
            }
        }
        $i++
    }
}

# Obtener discos (almacenamiento)
$discos = Get-PhysicalDisk | ForEach-Object {
    [PSCustomObject]@{
        Tipo = $_.MediaType
        GBs  = [math]::Round($_.Size / 1GB, 2)
    }
}

# Estado batería (si existe)
$bateria = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
$estadoBateria = if ($bateria) { 
    "$($bateria.EstimatedChargeRemaining)%"
} else { 
    "No disponible"
}

# Versión de Windows
$windows = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$versionWindows = "$($windows.ProductName) $($windows.ReleaseId) (Build $($windows.CurrentBuildNumber))"

# Marca, Modelo, PartNumber y Serial
$sistema = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS

$marca = $sistema.Manufacturer
$modelo = $sistema.Model
$partNumber = $bios.PartNumber
$serial = $bios.SerialNumber

# Armar objeto final
$inventario = [PSCustomObject]@{
    NombreDelDispositivo = $nombreDispositivo
    Procesador           = $procesador
    RAM                  = $ram
    Almacenamiento       = $discos
    EstadoBateria        = $estadoBateria
    VersionDeWindows     = $versionWindows
    MarcaDelEquipo       = $marca
    ModeloDelEquipo      = $modelo
    PartNumberDelEquipo  = $partNumber
    NumeroDeSerie        = $serial
}

# Convertir a JSON
$json = $inventario | ConvertTo-Json -Depth 4

# Copiar al portapapeles
[System.Windows.Forms.Clipboard]::SetText($json)

# Guardar en el escritorio
$escritorio = [Environment]::GetFolderPath('Desktop')
$rutaArchivo = Join-Path $escritorio "MisDatos.txt"
$json | Out-File -FilePath $rutaArchivo -Encoding UTF8

Write-Output "JSON copiado al portapapeles y guardado como 'MisDatos.txt' en el escritorio."
