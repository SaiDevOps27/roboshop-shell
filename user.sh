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

print_head "create roboshop user"
id roboshop &>>${log_file}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${log_file}
fi
status_check $?

print_head "create application directory"
if [ ! -d /app ]; then
  mkdir /app &>>${log_file}
fi
status_check $?

print_head "delete old content"
rm -rf /app/* &>>${log_file}
status_check $?

print_head "downloading app content"
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>>${log_file}
status_check $?
cd /app

print_head "extracting app content"
unzip /tmp/user.zip &>>${log_file}
status_check $?

print_head "installing nodejs dependencies"
npm install &>>${log_file}
status_check $?

print_head "copying systemd service file"
cp ${code_dir}/configs/user.service /etc/systemd/system/user.service &>>${log_file}
status_check $?

print_head "reload systemd"
systemctl daemon-reload &>>${log_file}
status_check $?

print_head "enable user service"
systemctl enable user &>>${log_file}
status_check $?

print_head "starting user service"
systemctl restart user &>>${log_file}
status_check $?

print_head "copying mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log_file}
status_check $?

print_head "install mongo client"
yum install mongodb-org-shell -y &>>${log_file}
status_check $?

print_head "load schema"
mongo --host mongodb.devopsb.cloud </app/schema/user.js &>>${log_file}
status_check $?