source common.sh

mysql_root_password=$1
if [ -z "${mysql_root_password}" ]; then
  echo -e "\e[31m missing mysql root password argument\e[0m"
  exit 1
fi


print_head " disabling mysql 8 version"
dnf module disable mysql -y &>>${log_file}
status_check $?

print_head " copy mysql repo file "
cp ${code_dir}/configs/mysql.repo /etc/yum.repos.d/mysql.repo &>>${log_file}
status_check $?

print_head " installing mysql server "
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head " enabling mysql"
systemctl enable mysqld &>>${log_file}
status_check $?

print_head " restarting mysql "
systemctl restart mysqld &>>${log_file}
status_check $?

print_head " set root password "
echo show databases | mysql -uroot -p${mysql_root_password} &>>${log_file}
if [ $? -ne 0 ]; then
  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>${log_file}
fi
status_check $?



