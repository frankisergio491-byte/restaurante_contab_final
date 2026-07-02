@echo off
cd /d "%~dp0"

echo Iniciando Restaurante Contab desde terminal...
echo.

if not exist "C:\xampp\htdocs" (
  echo No se encontro C:\xampp\htdocs. Instala o revisa XAMPP.
  pause
  exit /b
)

echo 1. Publicando frontend en XAMPP...
call "%~dp0publicar_xampp.bat" /quiet

echo 2. Iniciando Apache...
start "Apache XAMPP" /D "C:\xampp" "C:\xampp\apache_start.bat"

echo 3. Iniciando MySQL...
start "MySQL XAMPP" /D "C:\xampp" "C:\xampp\mysql_start.bat"

echo 4. Iniciando backend Django...
start "Backend Django Restaurante Contab" /D "%~dp0" "%~dp0iniciar_backend.bat"

echo 5. Abriendo pagina en localhost...
timeout /t 8 /nobreak >nul
start "" "http://localhost/restaurante_contab/"

echo.
echo Pagina: http://localhost/restaurante_contab/
echo Backend: http://localhost:8000/api
echo Base de datos: http://localhost/phpmyadmin
echo.
echo No cierres las ventanas de Apache, MySQL ni Backend mientras uses el sistema.
pause
