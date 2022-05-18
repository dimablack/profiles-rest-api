docker-compose run app sh -c "python manage.py test"       
docker-compose run app sh -c "django-admin.py startproject app ."
docker-compose run app sh -c "manage.py startapp app"
django-admin.py startproject profiles_project .
python manage.py startapp profiles_api
python manage.py startapp app

python manage.py runserver 0.0.0.0:8000

python manage.py makemigrations

source ~/env/bin/activate
deactivate

python -m pip install --user --upgrade pip
python -m pip install --user virtualenv
python -m venv ~/env
source ~/env/bin/activate
pip install -r /requirements.txt

curl -sL https://raw.githubusercontent.com/dimablack/profiles-rest-api/master/deploy/setup.sh | sudo bash -