#! /bin/bash

echo ""
echo "WSGISocketPrefix /var/run/wsgi"
echo ""
echo "<VirtualHost *:80>"
echo ""
echo "        ServerAdmin ${SERVER_ADMIN_EMAIL}"
echo ""
echo "        ServerName graphite"
echo "        DocumentRoot \"/opt/graphite/webapp\""
echo ""
echo "        ErrorLog /opt/graphite/storage/log/webapp/error.log"
echo "        CustomLog /opt/graphite/storage/log/webapp/access.log common"
echo ""
echo "        WSGIDaemonProcess graphite processes=5 threads=5 display-name='%{GROUP}' inactivity-timeout=120"
echo "        WSGIProcessGroup graphite"
echo "        WSGIApplicationGroup %{GLOBAL}"
echo "        WSGIImportScript /opt/graphite/conf/graphite.wsgi process-group=graphite application-group=%{GLOBAL}"
echo "        WSGIScriptAlias / /opt/graphite/conf/graphite.wsgi"
echo ""
echo "        Alias /content/ /opt/graphite/webapp/content/"
echo "        <Location \"/content/\">"
echo "                SetHandler None"
echo "                Order deny,allow"
echo "                Allow from all"
echo "        </Location>"
echo "        <Directory /opt/graphite/conf/>"
echo "                Options All"
echo "                AllowOverride All"
echo "                Require all granted"
echo "        </Directory>"
echo "        <Directory /opt/graphite/webapp>"
echo "                Options All"
echo "                AllowOverride All"
echo "                Require all granted"
echo "        </Directory>"
echo ""
echo "</VirtualHost>"
echo ""