@echo off
set "DESTINO=C:\xampp\htdocs\restaurante_contab"

if not exist "C:\xampp\htdocs" (
  echo No se encontro C:\xampp\htdocs. Revisa que XAMPP este instalado.
  pause
  exit /b
)

if not exist "%DESTINO%" mkdir "%DESTINO%"

copy /Y "%~dp0frontend_local.html" "%DESTINO%\index.html" >nul
xcopy "%~dp0assets" "%DESTINO%\assets" /E /I /Y >nul

echo Frontend publicado en XAMPP.
echo Abre: http://localhost/restaurante_contab/
echo Recuerda iniciar tambien el backend con iniciar_backend.bat
if /I "%~1" NEQ "/quiet" pause
