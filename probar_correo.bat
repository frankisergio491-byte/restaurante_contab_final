@echo off
cd /d "%~dp0"
if exist email_config.bat call email_config.bat
python probar_correo.py
pause

