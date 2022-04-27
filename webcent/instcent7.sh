#!/bin/bash
menu(){
ipweb=$(curl https://bigbolgames.com)
clear
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%30s%s%-10s\n' "Instalador PainelWEB GESTOR-SSH CENTOS 7" ; tput sgr0 ; echo ""
echo "Continuar? S\n"
echo -n "> "
read option
if [ $option = "S" ]; then
install
elif [ $option = "s" ]; then
install
elif [ $option = "n" ]; then
exit
elif [ $option = "N" ]; then
exit
else
menu
fi
}
install(){
clear
yum update -y
yum upgrade -y
yum install epel-release -y 
yum install php htop zip nload nano phpmyadmin httpd mysql mariadb-server php-pecl-ssh2 -y --skip-broken
yum install gcc php-devel libssh2 libssh2-devel php-pear make php-mcrypt unzip wget screen -y --skip-broken
setsebool -P httpd_can_network_connect 1
systemctl enable httpd 
systemctl enable mariadb
service httpd restart
service mariadb start
dbconfig
}
dbconfig(){
clear
echo "Insira a senha do ROOT Banco de dados"
echo -n "> "
read root_password
if [ -z $root_password ]; then
clear 
echo "Por favor coloque senha do MYsql"
sleep 2
dbconfig
else
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$root_password') WHERE User = 'root'"
mysql -e "FLUSH PRIVILEGES"
phpmyadminfix
fi
}
phpmyadminfix(){
rm /etc/httpd/conf.d/phpMyAdmin.conf
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/phpMyAdmin.conf -O /etc/httpd/conf.d/phpMyAdmin.conf
chmod 777 /etc/httpd/conf.d/phpMyAdmin.conf
service httpd restart
installweb
}
installweb(){
cd /var/www/html
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/gestorssh.zip
unzip gestorssh.zip
sed -i "s;1020;$root_password;g" /var/www/html/pages/system/pass.php > /dev/null 2>&1
rm gestorssh.zip
chmod 777 -R /var/www/
cd
createdb
}
createdb(){
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/sshplus.sql
mysql -h localhost -u root -p$root_password -e "CREATE DATABASE sshplus"
mysql -h localhost -u root -p$root_password --default_character_set utf8 sshplus < sshplus.sql
rm sshplus.sql
croninstall
}
croninstall(){
crontab -l > mycron
echo "@reboot /root/startup" >> mycron
crontab mycron
rm mycron
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/cronc.sh
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/cronb.sh
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/clean.sh
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/startup.sh
wget https://github.com/nandoslayer/plusnssh/raw/ntech/webcent/backupsql.sh
chmod +x *.sh
./startup.sh
final
}
final(){
clear
echo "Login Painel ADMIN: admin"
echo "Senha Painel ADMIN: admin"
echo "Acesso Painel ADMIN: $ipweb/admin"
echo "Acesso PHPMYADMIN: $ipweb/phpmyadmin"
echo "Login PHPMYADMIN: root" 
echo "senha PHPMYADMIN: $root_password"
echo "Backup dos dados do PHPMyadmin se encontra no /root/PHPMYADMIN.txt"
echo "Acesso PHPMYADMIN: $ipweb/phpmyadmin" >> PHPMYADMINDATA.txt
echo "Login PHPMYADMIN: root" >> PHPMYADMINDATA.txt
echo "senha PHPMYADMIN: $root_password" >> PHPMYADMINDATA.txt
sleep 10
}
menu1
