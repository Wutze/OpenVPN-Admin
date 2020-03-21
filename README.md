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
  * PHP >= 7.x with modules:
    * zip
    * pdo_mysql
  * yarn
  * unzip
  * wget
  * sed
  * curl
  * git
  * net-tools (route)

### Debian 10 Buster
### Raspberry Pi with Debian 10 Buster

````
# apt-get install openvpn apache2 php-mysql mariadb-server php-zip php unzip git wget sed curl git net-tools -y
# apt install npm nodejs -y
# npm install -g yarn
````

## Tests

  * Only tested on Debian 10/Buster, PHP 7.3.x, 10.3.22-MariaDB.
  * RaspberryPi 4 with Debian Buster

Feel free to open issues.

## Installation

  * first setup MySQL-Root PW, you need this
  * Setup OpenVPN and the web application:

        $ cd /opt/
        $ mkdir /srv/www
        $ git clone https://github.com/wutze/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin

        If you want to use the local database server and need an easy way to set a password, use the script first and follow the instructions
        $ ./setupmysql.sh

        Beginn main installation
        # ./install.sh /srv/www www-data www-data

  * Setup the web server (Apache, NGinx...) to serve the web application.
  * You must reboot the server after installation, otherwise the vpn server will not start correctly and no connection will be established!

  * Finally, create a port forwarding on your Internet Router to this VPN-Server

## OpenVPN-Clients and Documentation to install
### Apple iOS
  * https://apps.apple.com/us/app/openvpn-connect/id590379981
  * Documentation (German) https://www.thomas-krenn.com/de/wiki/IOS_11_als_OpenVPN_Client_konfigurieren

### Android
  * https://play.google.com/store/apps/details?id=de.blinkt.openvpn&hl=de
  * Go to download, download the zip file, unzip it into a separate folder, open the OpenVPN app and download the client.conf. Everything else happens automatically. Enter the password and you are ready to go.

### Windows 10
  * https://openvpn.net/client-connect-vpn-for-windows/

### all
  * Looks at the configuration of the VPN app. If necessary, adjust the address of your gateway to the VPN server. Most routers can handle a free Dyn-DNS, so you only have to give the name, no IP address.

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
