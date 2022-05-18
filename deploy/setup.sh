#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/dimablack/profiles-rest-api.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'
VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'

sudo rm -rf $PROJECT_BASE_PATH

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install Python, SQLite and pip
echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite python-pip supervisor nginx git

mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH/profiles-rest-api

mkdir -p $VIRTUALENV_BASE_PATH
python3 -m venv $VIRTUALENV_BASE_PATH/profiles_api

$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install django
$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install -r $PROJECT_BASE_PATH/profiles-rest-api/requirements.txt

# Run migrations
echo "$PROJECT_BASE_PATH/profiles-rest-api/"
cd $PROJECT_BASE_PATH/profiles-rest-api/
echo "$VIRTUALENV_BASE_PATH/profiles_api/bin/python"
$VIRTUALENV_BASE_PATH/profiles_api/bin/python app/manage.py migrate

# Setup Supervisor to run our uwsgi process.
echo '34'
cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
echo '36'
supervisorctl reread
echo '38'
supervisorctl update
echo '40'
supervisorctl restart profiles_api
echo '42'

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
echo '46'
rm /etc/nginx/sites-enabled/default
echo '48'
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
echo '50'
systemctl restart nginx.service
echo '53'

echo "DONE! :)"
