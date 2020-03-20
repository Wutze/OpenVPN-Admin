#!/bin/bash
#
# this File is part of OpenVPN-Admin
#
# GNU AFFERO GENERAL PUBLIC LICENSE V3
# Original Script from: https://github.com/Chocobozzz/OpenVPN-Admin
# Parts of the programming from pi-hole were used as templates.
#
# changes (c) by Wutze 2020 Version 0.6
#
# Twitter -> @HuWutze

# debug
#set -x

## Fix Debian 10 Fehler
export PATH=$PATH:/usr/sbin:/sbin

## set static vars
config="config.conf"
coltable=/opt/install/COL_TABLE

## init screen
# Find the rows and columns will default to 80x24 if it can not be detected
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo "${screen_size}" | awk '{print $1}')
columns=$(echo "${screen_size}" | awk '{print $2}')

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

# If the color table file exists,
if [[ -f "${coltable}" ]]; then
	# source it
	source ${coltable}
# Otherwise,
else
	# Set these values so the installer can still run in color
	COL_NC='\e[0m' # No Color
	COL_LIGHT_GREEN='\e[1;32m'
	COL_LIGHT_RED='\e[1;31m'
	COL_BLUE='\e[94m'
	TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
	CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
	INFO="[i]"
	# shellcheck disable=SC2034
	DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
	OVER="\\r\\033[K"
fi

## Intro with colored Logo
intro(){
	echo -e "${COL_LIGHT_RED}
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
${COL_BLUE}        ◢■◤
      ◢■◤
    ◢■◤  ${COL_LIGHT_RED}M I C R O - M A D E / H O M E - ${COL_NC}V P N A D M I N${COL_LIGHT_RED} - S E R V E R${COL_BLUE}
  ◢■◤                                                【ツ】 © 2018-20
◢■■■■■■■■■■■■■■■■■■■■◤                             ${COL_LIGHT_RED}L   I   N   U   X
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■${COL_NC}
"
}

# read config.conf
# you must copy config.conf.example to config.conf and edit this file
if [[ -f "${config}" ]]; then
	# source it
	source ${config}
# Otherwise,
else
  echo "Missing configuration"
  echo "you must copy config.conf.example to config.conf and edit this file"
  exit
fi

print_help () {
  echo -e "./install.sh www_basedir user group"
  echo -e "\tbase_dir: The place where the web application will be put in"
  echo -e "\tuser:     User of the web application"
  echo -e "\tgroup:    Group of the web application"
}

#
#  name: control_box
#  @param $? + Description
#  @return Message OK or Exit Script
#  
control_box(){
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      print_out 1 "Input Ok: ${2}"
  else
      print_out 0 "input break: ${2}"
      exit
  fi
}

#  
#  name: print_out
#  @param [1|0|i|d|r] [Text]]
#  @return formated Text with red cross, green tick, "i"nfo, "d"one Message or need input with "r"
#  
print_out(){
	case "${1}" in
		1)
		echo -e " ${TICK} ${2}"
		;;
		0)
		echo -e " ${CROSS} ${2}"
		;;
		i)
		echo -e " ${INFO} ${2}"
		;;
		d)
		echo -e " ${DONE} ${2}"
		;;
		r)	read -rsp " ${2}"
			echo "\n"
		;;
	esac
}

#  Intercept and display errors
#  name: control_script
#  @param $?
#  @return continue script or or exit when error with exit 100
#  
control_script(){
  if [ ! $? -eq 0 ]
  then
  print_out 0 "Error ${1}"
  exit 100
  fi
}

# you can only install with root privileges
# check this
check_user(){
	# Must be root to install
	local str="Root user check"
	if [[ "${EUID}" -eq 0 ]]; then
		# they are root and all is good
		print_out 1 "${str}"
	else
		print_out 0 "${str}"
		print_out i "${COL_LIGHT_RED}Script called with non-root privileges${COL_NC}"
		print_out i "The Installation requires root privileges to install and run"
		print_out 1 "Installation aborted"
		exit 1
	fi
}

clear
intro
print_out i 'Press enter to continue the VPN-Admin Setup or strg+c to break...'
print_out r ''
# Ensure to be root
check_user

# Ensure there are enought arguments
if [ "$#" -ne 3 ]; then
  print_help
  exit
fi

# Ensure there are the prerequisites
for i in openvpn mysql php yarn node unzip wget sed; do
  which $i > /dev/null
  if [ "$?" -ne 0 ]; then
    echo "Miss $i"
    exit
  fi
done

www=$1
user=$2
group=$3

openvpn_admin="$www/openvpn-admin"

# Check the validity of the arguments
if [ ! -d "$www" ] ||  ! grep -q "$user" "/etc/passwd" || ! grep -q "$group" "/etc/group" ; then
  print_out 0 "${str}"
  print_out i "failed Directory, www-user or www-group on your system"
  exit
fi

base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Message Boxen/Input
print_out i "give me Input"

ip_server=$(whiptail --inputbox "Server Hostname/IP\nUse the name as the server is to be reached from the Internet!" 8 78 --title "Hostname/IP" 3>&1 1>&2 2>&3)
control_box $? "Server IP"
openvpn_proto=$(whiptail --inputbox "OpenVPN protocol (tcp or udp)\nIf you are using a VM with this installation, then select udp:" 8 78 udp --title "Protokoll" 3>&1 1>&2 2>&3)
control_box $? "VPN Protokoll"
server_port=$(whiptail --inputbox "OpenVPN Server Port\nDefault Port tcp or udp 1194:" 8 78 1194 --title "Server Port" 3>&1 1>&2 2>&3)
control_box $? "OpenVPN Port"

db_host=$(whiptail --inputbox "MySQL Host\n(localhost, IP or FQDN)\n\nIf you are using an external database server,\nconfigure it previously so that you can enter a user name and password." 8 78 localhost --title "DB Host" 3>&1 1>&2 2>&3)
control_box $? "DB-Host"
## If you are using an external database server
## configure it previously so that you can enter a user name and password.
if [ "$db_host" == localhost ]; then
  mysql_root_pass=$(whiptail --inputbox "MySQL Root Password\n(The password must not be empty. Please configure this before!)" 8 78 --title "DB Root PW" 3>&1 1>&2 2>&3)
  control_box $? "Root PW"
fi

mysql_user=$(whiptail --inputbox "MySQL Username for OpenVPN Database" 8 78 --title "User DB Name" 3>&1 1>&2 2>&3)
control_box $? "MySQL Username"
mysql_user_pass=$(whiptail --inputbox "MySQL Userpassword for OpenVPN Database" 8 78 --title "User DB PW" 3>&1 1>&2 2>&3)
control_box $? "MySQL User PW"

admin_user=$(whiptail --inputbox "Admin Username for Webfrontend OpenVPN-Admin" 8 78 --title "Web-Admin Name" 3>&1 1>&2 2>&3)
control_box $? "Web Admin User"
admin_user_pass=$(whiptail --inputbox "Admin Userpassword for Webfrontend OpenVPN-Admin" 8 78 --title "Web-Admin PW" 3>&1 1>&2 2>&3)
control_box $? "Web Admin PW"

#  
#  name: set_mysql
#  @param dbname dbuser dbpass
#  @return insert new database, user and setup password
#  
set_mysql(){

  EXPECTED_ARGS=3
  MYSQL=`which mysql`
  Q1="CREATE DATABASE IF NOT EXISTS $1;"
  Q2="GRANT ALL ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$3';"
  Q3="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}"
   
  if [ $# -ne $EXPECTED_ARGS ]
  then
    echo "Usage: $0 dbname dbuser dbpass"
    exit
  fi
   
  $MYSQL -h $db_host -uroot --password=$mysql_root_pass -e "$SQL"
  control_script "Create local Database"
}

if [ "$db_host" == localhost ]; then
  set_mysql openvpnadmin $mysql_user $mysql_user_pass
fi

mysql -h $db_host -u $mysql_user --password=$mysql_user_pass openvpnadmin < sql/vpnadmin.dump
control_script "Insert Database Dump"
mysql -h $db_host -u $mysql_user --password=$mysql_user_pass --database=openvpnadmin -e "INSERT INTO admin (admin_id, admin_pass) VALUES ('${admin_user}', encrypt('${admin_user_pass}'));"
control_script "Insert Webadmin User"

print_out 1 "setting up MySQL OK"

print_out i "################## Creating the certificates ##################"

# Get the rsa keys
cd /opt/
wget "https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz"
tar -xaf "EasyRSA-unix-v3.0.6.tgz"
mv "EasyRSA-v3.0.6" /etc/openvpn/easy-rsa
#rm "EasyRSA-unix-v3.0.6.tgz"

cd /etc/openvpn/easy-rsa
## This vars read from config.conf, see above in this script
if [[ ! -z $key_size ]]; then
  export EASYRSA_KEY_SIZE=$key_size
fi
if [[ ! -z $ca_expire ]]; then
  export EASYRSA_CA_EXPIRE=$ca_expire
fi
if [[ ! -z $cert_expire ]]; then
  export EASYRSA_CERT_EXPIRE=$cert_expire
fi
if [[ ! -z $cert_country ]]; then
  export EASYRSA_REQ_COUNTRY=$cert_country
fi
if [[ ! -z $cert_province ]]; then
  export EASYRSA_REQ_PROVINCE=$cert_province
fi
if [[ ! -z $cert_city ]]; then
  export EASYRSA_REQ_CITY=$cert_city
fi
if [[ ! -z $cert_org ]]; then
  export EASYRSA_REQ_ORG=$cert_org
fi
if [[ ! -z $cert_ou ]]; then
  export EASYRSA_REQ_OU=$cert_ou
fi
if [[ ! -z $cert_email ]]; then
  export EASYRSA_REQ_EMAIL=$cert_email
fi
if [[ ! -z $key_cn ]]; then
  export EASYRSA_REQ_CN=$key_cn
fi

# Init PKI dirs and build CA certs
./easyrsa init-pki
./easyrsa build-ca nopass
# Generate Diffie-Hellman parameters
./easyrsa gen-dh
# Genrate server keypair
./easyrsa build-server-full server nopass

# Generate shared-secret for TLS Authentication
openvpn --genkey --secret pki/ta.key

print_out 1 "setting up EasyRSA Ok"

print_out i "################## Setup OpenVPN ##################"

# Copy certificates and the server configuration in the openvpn directory
cp /etc/openvpn/easy-rsa/pki/{ca.crt,ta.key,issued/server.crt,private/server.key,dh.pem} "/etc/openvpn/"
cp "$base_path/installation/server.conf" "/etc/openvpn/"
mkdir "/etc/openvpn/ccd"
sed -i "s/port 443/port $server_port/" "/etc/openvpn/server.conf"

if [ $openvpn_proto = "udp" ]; then
  sed -i "s/proto tcp/proto $openvpn_proto/" "/etc/openvpn/server.conf"
fi

nobody_group=$(id -ng nobody)
sed -i "s/group nogroup/group $nobody_group/" "/etc/openvpn/server.conf"

print_out i "################## Setup firewall ##################"

# Make ip forwading and make it persistent

echo "

[Unit]
Description=Firewall Rules
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /usr/sbin/firewall.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target

" > /etc/systemd/system/firewall.service


echo "#/bin/sh
export PATH=$PATH:/usr/sbin:/sbin

echo 1 > "/proc/sys/net/ipv4/ip_forward"

# Get primary NIC device name
primary_nic=`route | grep '^default' | grep -o '[^ ]*$'`

# Iptable rules
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I OUTPUT -o tun0 -j ACCEPT

iptables -A FORWARD -i tun0 -o \$primary_nic -j ACCEPT
iptables -t nat -A POSTROUTING -o \$primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o \$primary_nic -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o \$primary_nic -j MASQUERADE
" > /usr/sbin/firewall.sh

chmod +x /usr/sbin/firewall.sh
systemctl enable firewall.service
systemctl start firewall

print_out i "################## Setup web application ##################"

# Copy bash scripts (which will insert row in MySQL)
cp -r "$base_path/installation/scripts" "/etc/openvpn/"
chmod +x "/etc/openvpn/scripts/"*

# Configure MySQL in openvpn scripts
sed -i "s/HOST=''/HOST='$db_host'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/USER=''/USER='$mysql_user'/" "/etc/openvpn/scripts/config.sh"
sed -i "s/PASS=''/PASS='$mysql_user_pass'/" "/etc/openvpn/scripts/config.sh"

# Create the directory of the web application
mkdir "$openvpn_admin"
cp -r "$base_path/"{index.php,package.json,js,include,css} "$openvpn_admin"
mkdir $www/vpn
#mkdir $www/vpn/conf
cp -r "$base_path/"installation/conf $www/vpn/
ln -s /etc/openvpn/server.conf $www/vpn/conf/server/server.conf

# New workspace
cd "$openvpn_admin"

# Replace config.php variables
sed -i "s/\$host = '';/\$host = '$db_host';/" "./include/config.php"
sed -i "s/\$user = '';/\$user = '$mysql_user';/" "./include/config.php"
sed -i "s/\$pass = '';/\$pass = '$mysql_user_pass';/" "./include/config.php"

# Replace in the client configurations with the ip of the server and openvpn protocol
for file in $(find ../ -name client.ovpn); do
    sed -i "s/remote xxx\.xxx\.xxx\.xxx 443/remote $ip_server $server_port/" $file
    echo "<ca>" >> $file
    cat "/etc/openvpn/ca.crt" >> $file
    echo "</ca>" >> $file
    echo "<tls-auth>" >> $file
    cat "/etc/openvpn/ta.key" >> $file
    echo "</tls-auth>" >> $file

  if [ $openvpn_proto = "udp" ]; then
    sed -i "s/proto tcp-client/proto udp/" $file
  fi
done

# Copy ta.key inside the client-conf directory
for directory in "../vpn/conf/gnu-linux/" "../vpn/conf/osx-viscosity/" "../vpn/conf/windows/"; do
  cp "/etc/openvpn/"{ca.crt,ta.key} $directory
done

print_out 1 "Setup Web Application done"

print_out i "Install third party module"
yarn install
# backward compatibility to bower in php scripts
ln -s node_modules vendor

chown -R "$user:$group" "$openvpn_admin"
chown -R "$user:$group" $www/vpn
chown "$user:$group" $www/vpn/conf/server/server.conf

print_out 1 "Finish Installation OpenVPN-Admin"
print_out i "Please, finish the installation by configuring your web server (Apache, NGinx...)"
print_out i "Restart your Server after installation please!"
print_out d "Please, report any issues here https://github.com/wutze/OpenVPN-Admin"
