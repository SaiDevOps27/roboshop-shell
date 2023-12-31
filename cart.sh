source common.sh

print_head "disabling nodejs"
dnf module disable nodejs -y &>>${log_file}
status_check $?

print_head "enabling nodejs"
dnf module enable nodejs:18 -y &>>${log_file}
status_check $?

print_head "installing nodejs"
yum install nodejs -y &>>${log_file}
status_check $?

print_head "create roboshop cart"
id roboshop
if [ $? -ne 0 ]; then
useradd roboshop &>>${log_file}
fi
status_check $?

print_head "create application directory"
if [ ! -ne 0 ]; then
mkdir /app &>>${log_file}
fi
status_check $?

print_head "delete old content"
rm -rf /app/* &>>${log_file}
status_check $?

print_head "downloading app content"
curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip &>>${log_file}
cd /app
status_check $?

print_head "extracting app content"
unzip /tmp/cart.zip &>>${log_file}
status_check $?

print_head "installing nodejs dependencies"
npm install &>>${log_file}
status_check $?

print_head "copying systemd service file"
cp ${code_dir}/configs/cart.service /etc/systemd/system/cart.service &>>${log_file}
status_check $?

print_head "reload systemd"
systemctl daemon-reload &>>${log_file}
status_check $?

print_head "enable cart service"
systemctl enable cart &>>${log_file}
status_check $?

print_head "starting cart service"
systemctl restart cart &>>${log_file}
status_check $?

