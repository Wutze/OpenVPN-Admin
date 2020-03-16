# OpenVPN Admin

## Summary
Administrate its OpenVPN with a web interface (logs visualisations, users managing...) and a SQL database.

![Previsualisation configuration](https://lutim.cpy.re/fUq2rxqz)
![Previsualisation administration](https://lutim.cpy.re/wwYMkHcM)


## Prerequisite

  * GNU/Linux with Bash and root access
  * Fresh install of OpenVPN
  * Web server (NGinx, Apache...)
  * MariaDB
  * PHP >= 5.5 with modules:
    * zip
    * pdo_mysql
  * bower
  * unzip
  * wget
  * sed
  * curl

### Debian 10 Buster

````
# apt-get install openvpn apache2 php-mysql mariadb-server php-zip php unzip git wget sed curl git -y
# apt install npm nodejs -y
# npm install -g bower
````

## Tests

Only tested on Debian 10/Buster, PHP 7.3.x, 10.3.22-MariaDB.
Feel free to open issues.

## Installation

  * Setup OpenVPN and the web application:

        $ cd /opt/
        $ mkdir /srv/www
        $ git clone https://github.com/wutze/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin
        # ./install.sh /srv/www www-data www-data

  * Setup the web server (Apache, NGinx...) to serve the web application.

## Apache Example
````
<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /srv/www/openvpn-admin

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

AccessFileName .htaccess
<FilesMatch "^\.ht">
        Require all denied
</FilesMatch>

<Directory /srv/www/openvpn-admin/>
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
</Directory>

</VirtualHost>

````

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
