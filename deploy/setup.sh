#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/dimablack/profiles-rest-api.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-api'
VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'

sudo rm -rf $PROJECT_BASE_PATH
sudo rm -rf $VIRTUALENV_BASE_PATH

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install Python, SQLite and pip
echo "Installing dependencies..."
sudo apt-get purge -y python3-dev python3-venv sqlite python-pip
apt-get update
apt-get install -y python3-dev python3-venv sqlite python-pip supervisor nginx git

mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

mkdir -p $VIRTUALENV_BASE_PATH
python3 -m venv $VIRTUALENV_BASE_PATH/profiles_api
mkdir -p $VIRTUALENV_BASE_PATH/static
mkdir -p $VIRTUALENV_BASE_PATH/app/static

#$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install Django==4.0.4
$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt
$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install uwsgi==2.0.18

# Run migrations
echo "$PROJECT_BASE_PATH"
cd $PROJECT_BASE_PATH/
echo "$VIRTUALENV_BASE_PATH/profiles_api/bin/python"
$VIRTUALENV_BASE_PATH/profiles_api/bin/python app/manage.py migrate
$VIRTUALENV_BASE_PATH/profiles_api/bin/python app/manage.py collectstatic --noinput

# Setup Supervisor to run our uwsgi process.
echo '34'
echo "$PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf"
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
echo '36'
supervisorctl reread
echo '38'
supervisorctl update
echo '40'
supervisorctl restart profiles_api
echo '42'

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
echo '46'
sudo rm /etc/nginx/sites-enabled/default -f
sudo rm /etc/nginx/sites-enabled/profiles_api.conf -f
echo '48'
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
echo '50'
systemctl restart nginx.service
echo '53'

echo "DONE! :)"
