#!/bin/bash
yum update -y

yum install wget pip tree git unzip zip net-tools -y

yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm -y

yum install epel-release -y

yum install icinga2 -y

systemctl enable icinga2

systemctl start icinga2

icinga2 feature list

yum install nagios-plugins-all -y

systemctl restart icinga2

yum install icinga2-selinux -y

yum install mariadb-server mariadb -y

systemctl enable mariadb

systemctl start mariadb

mysql_secure_installation <<EOF

n
y
y
y
y
EOF

yum install icinga2-ido-mysql -y

mysql -u root <<EOF
CREATE DATABASE icinga;

GRANT ALL PRIVILEGES ON icinga.* TO 'icingauser'@'localhost' IDENTIFIED BY 'abc123.';

CREATE DATABASE icingaweb;

GRANT ALL PRIVILEGES ON icingaweb.* TO 'icingauser'@'localhost' IDENTIFIED BY 'abc123.';

FLUSH PRIVILEGES;

exit
EOF

mysql -u root icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql

icinga2 feature enable ido-mysql

systemctl restart icinga2

yum install httpd -y

systemctl enable httpd

systemctl start httpd

firewall-cmd --add-service=http

firewall-cmd --permanent --add-service=http

icinga2 api setup

echo 'object ApiUser "icingaweb2" {
password = "abc123."
permissions = [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
}' >> /etc/icinga2/conf.d/api-users.conf

mv /etc/icinga2/features-enabled/ido-mysql.conf /etc/icinga2/features-enabled/ido-mysql.conf.original
touch /etc/icinga2/features-enabled/ido-mysql.conf
echo 'library "db_ido_mysql"

object IdoMysqlConnection "ido-mysql" {
user = "icingauser"
password = "abc123."
host = "localhost"
database = "icinga"
}' >> /etc/icinga2/features-enabled/ido-mysql.conf

systemctl restart icinga2

yum install centos-release-scl -y

yum install icingaweb2 icingacli -y

yum install icingaweb2-selinux -y

yum install rh-php71-php-fpm -y

systemctl start rh-php71-php-fpm.service

systemctl enable rh-php71-php-fpm.service

yum install rh-php71-php-mysqlnd

systemctl restart rh-php71-php-fpm.service

icingacli setup token create

yum install sed -y

sed -i 's%;date.timezone =%date.timezone = Europe/Madrid%g' /etc/opt/
rh/rh-php71/php.ini

systemctl restart httpd

yum install sclo-php71-php-pecl-imagick -y

systemctl restart httpd

systemctl restart rh-php71-php-fpm.service

icingacli setup token show

exit 0
