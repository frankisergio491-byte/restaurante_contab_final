@echo off
cd /d "%~dp0"
if exist email_config.bat call email_config.bat
python -m pip install -r requirements.txt
python setup_mysql.py
python manage.py migrate
python manage.py runserver
