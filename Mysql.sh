source common.sh

print_head " disabling mysql "
dnf module disable mysql -y &>>${log_file}
status_check $?

print_head " installing mysql "
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head " enabling mysql"
systemctl enable mysqld &>>${log_file}
status_check $?

print_head " restarting mysql "
systemctl restart mysqld &>>${log_file}
status_check $?

print_head " updating the default password "
mysql_secure_installation --set-root-pass RoboShop@1 &>>${log_file}
status_check $?

print_head "setting up user and passwords "
mysql -uroot -pRoboShop@1 &>>${log_file}
status_check $?