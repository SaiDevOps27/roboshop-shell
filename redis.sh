source common.sh

print_head " Installing redis repo file "
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
status_check $?

print_head " Enabling redis 6.2 version "
dnf module enable redis:remi-6.2 -y &>>${log_file}
status_check $?

print_head " Installing redis "
yum install redis -y &>>${log_file}
status_check $?

print_head " Updating listen address to 0.0.0.0 "
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${log_file}
status_check $?

print_head " Enabling redis "
systemctl enable redis &>>${log_file}
status_check $?

print_head " Restarting redis "
systemctl restart redis &>>${log_file}
status_check $?