code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -rf ${log_file}

print_head (){
  echo -e "\e[36m$1\e[0m"
}

status_check(){
  if [ $1 -eq 0 ]; then
    echo SUCCESS
  else
    echo FAILURE
    echo " read the log file ${log_file} for more information about error"
    exit 1
  fi
}

NODEJS(){
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
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
  status_check $?
  cd /app

  print_head "extracting app content"
  unzip /tmp/${component}.zip &>>${log_file}
  status_check $?

  print_head "installing nodejs dependencies"
  npm install &>>${log_file}
  status_check $?

  print_head "copying systemd service file"
  cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
  status_check $?

  print_head "reload systemd"
  systemctl daemon-reload &>>${log_file}
  status_check $?

  print_head "enable ${component} service"
  systemctl enable ${component} &>>${log_file}
  status_check $?

  print_head "starting ${component} service"
  systemctl restart ${component} &>>${log_file}
  status_check $?

  print_head "copying mongodb repo file"
  cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log_file}
  status_check $?

  print_head "install mongo client"
  yum install mongodb-org-shell -y &>>${log_file}
  status_check $?

  print_head "load schema"
  mongo --host mongodb.devopsb.cloud </app/schema/${component}.js &>>${log_file}
  status_check $?
}



