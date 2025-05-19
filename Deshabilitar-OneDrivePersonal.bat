@echo off
setlocal

:: Descargar script PowerShell
echo Descargando script para deshabilitar OneDrive Personal...
curl -L "https://raw.githubusercontent.com/broskul/asesoriaTI/main/Quitar%20OneDrive%20Personal.ps1" -o "%TEMP%\QuitarOneDrivePersonal.ps1"

:: Ejecutar el script con privilegios de administrador
echo Aplicando la configuración...
powershell -Command ^
 "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%TEMP%\QuitarOneDrivePersonal.ps1\"' -Verb RunAs -Wait"

:: Verificar si la política está activa
echo Verificando configuración aplicada...
powershell -Command ^
 "$value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' -Name 'DisablePersonalSync' -ErrorAction SilentlyContinue; ^
  if ($value.DisablePersonalSync -eq 1) { ^
     Write-Host '✅ Política aplicada correctamente. Reiniciando OneDrive...' -ForegroundColor Green; ^
     Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue; ^
     Start-Sleep -Seconds 2; ^
     Start-Process '$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe'; ^
     [System.Windows.Forms.MessageBox]::Show('La política fue aplicada correctamente. OneDrive Personal ha sido deshabilitado y el servicio reiniciado.','Finalizado') ^
  } else { ^
     [System.Windows.Forms.MessageBox]::Show('⚠️ La política no se aplicó correctamente. Verificar permisos o ejecutar nuevamente como administrador.','Error') ^
  }" -STA

endlocal
pause
