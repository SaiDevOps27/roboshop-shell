source common.sh

yum install maven -y &>>${log_file}
useradd roboshop &>>${log_file}

mkdir /app &>>${log_file}

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>>${log_file}
cd /app &>>${log_file}
unzip /tmp/shipping.zip &>>${log_file}
cd /app &>>${log_file}
mvn clean package &>>${log_file}
mv target/shipping-1.0.jar shipping.jar &>>${log_file}
systemctl daemon-reload &>>${log_file}
systemctl enable shipping &>>${log_file}
systemctl start shipping &>>${log_file}
dnf install mysql -y &>>${log_file}
mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${log_file}
systemctl restart shipping &>>${log_file}
