# OpenVPN Admin
![Twitter Follow](https://img.shields.io/twitter/follow/huwutze?color=blue&label=HuWutze&logo=Twitter&style=plastic)

## Alternate OpenVPN WebAdmin installation

An improved version of this original, which not only changed the design but also the structure of the code, up to modular extensions, can be found here:

https://github.com/Wutze/OpenVPN-WebAdmin

This alternative is, unlike the original, state of the art, uses yarn instead of bower, is much more flexible and secure than the original and has such problems as password assignment fixed from issue #145, allows password changes etc. Personalised login pages are possible, status overviews, help pages, own texts for user instructions, multilingualism and much more.

The live test is currently the personalised allocation of IP addresses. In preparation is the administration of TLS keys (User based Certs). Further features are in planning or already in progress.

Example:

![Previsualisation Administration OpenVPN-WebAdmin](https://github.com/Wutze/OpenVPN-WebAdmin/blob/master/doc/img/useradmin.png)

# Important note!

# The following description still works, but in the meantime it is not recommended because of some serious bugs in the system. Therefore the hint, please use the alternative.

# Installation at your own risk!


############################

## Summary
Administrate its OpenVPN with a web interface (logs visualisations, users managing...) and a SQL database.

![Previsualisation configuration](https://lutim.cpy.re/fUq2rxqz)
![Previsualisation administration](https://lutim.cpy.re/wwYMkHcM)


## Prerequisite

  * GNU/Linux with Bash and root access
  * Fresh install of OpenVPN
  * Web server (NGinx, Apache...)
  * MariaDB (see note MySQL)
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

## Note MySQL
If you already have a database server, you can also use this one and do not need to install one locally. You only need a database and a username and password

### Debian 10 Buster
### Raspberry Pi with Debian 10 Buster
### Ubuntu 20.04 Server

## Manual Install with MySQL-Server
````
# apt-get install openvpn apache2 php-mysql mariadb-server php-zip php unzip git wget sed curl git net-tools -y
# apt install npm nodejs -y
# npm install -g yarn
````

## Manual Install without MySQL-Server
````
# apt-get install openvpn default-mysql-client apache2 php-mysql php-zip php unzip git wget sed curl git net-tools -y
# apt install npm nodejs -y
# npm install -g yarn
````

## Automated installation using selection boxes
````
# apt-get install git -y
````

## Tested on:

  * Debian 10/Buster, PHP 7.3.x, 10.3.22-MariaDB.
  * RaspberryPi 4 with Debian Buster
  * Ubuntu 20.04 Server (Minimal Installation + OpenSSH-Server)

Feel free to open issues.

## Installation

  * Setup OpenVPN and the web application:

        $ cd /opt/
        $ git clone https://github.com/wutze/OpenVPN-Admin openvpn-admin
        $ cd openvpn-admin
        $ cp config.conf.sample config.conf

        Edit your config.conf e.g. with nano
        $ nano config.conf

        Beginn main installation
        # ./install.sh

  * Setup the web server (Apache, NGinx...) to serve the web application. Using the example below.
  
        $ nano /etc/apache2/sites-enabled/[ apache config ]
  
  * You must reboot the server after installation, otherwise the vpn server will not start correctly and no connection will be established!

  * Finally, create a port forwarding on your Internet Router to this VPN-Server. Check the documentation of the router manufacturer or search the Internet for instructions.

## OpenVPN-Clients and Documentation to install
### Apple iOS
  * https://apps.apple.com/us/app/openvpn-connect/id590379981
  * Documentation (German) https://www.thomas-krenn.com/de/wiki/IOS_11_als_OpenVPN_Client_konfigurieren

### Android
  * https://play.google.com/store/apps/details?id=de.blinkt.openvpn&hl=de
  * Go to download, download the zip file, unzip it into a separate folder, open the OpenVPN app and download the client.conf. Everything else happens automatically. Enter the password and you are ready to go.

### Windows 10
  * https://openvpn.net/client-connect-vpn-for-windows/

The full functionality of OpenVPN under Windows 10 can unfortunately only be achieved by running the program under admin rights. This applies in particular to the routing into the VPN network, which does not work without admin rights. Additionally, the client version 3 of OpenVPN is in my opinion not usable to its full extent. For this reason I recommend, especially for people who want to know what they are doing and also want to adjust the configuration, the old version 2. Here is the direct link. https://openvpn.net/downloads/openvpn-connect-v2-windows.msi

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

### Changes from the original (fixes from original issues)
  * Support use of Mysql on different server #49
  * Can it change bower to Yarn #155
  * All other entries are not very helpful for the functions. However, some have been changed in this way, as you can now modify the server.conf within the system.

## Use of

  * [Bootstrap](https://github.com/twbs/bootstrap)
  * [Bootstrap Table](http://bootstrap-table.wenzhixin.net.cn/)
  * [Bootstrap Datepicker](https://github.com/eternicode/bootstrap-datepicker)
  * [JQuery](https://jquery.com/)
  * [X-editable](https://github.com/vitalets/x-editable)
