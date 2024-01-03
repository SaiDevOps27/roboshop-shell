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

systemd_setup(){
  print_head "copying systemd service file"
    cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
    status_check $?

    sed -i -e "s/ROBOSHOP_USER_PASSWORD/${roboshop_app_password}/" /etc/systemd/system/${component}.service &>>${log_file}

    print_head "reload systemd"
    systemctl daemon-reload &>>${log_file}
    status_check $?

    print_head "enable ${component} service"
    systemctl enable ${component} &>>${log_file}
    status_check $?

    print_head "starting ${component} service"
    systemctl restart ${component} &>>${log_file}
    status_check $?
}
schema_setup(){

  if [ "${schema_type}" == "mongo" ]; then
    print_head "copying mongodb repo file"
    cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log_file}
    status_check $?

    print_head "install mongo client"
    yum install mongodb-org-shell -y &>>${log_file}
    status_check $?

    print_head "load schema"
    mongo --host mongodb-dev.devopsb.cloud </app/schema/${component}.js &>>${log_file}
    status_check $?
  elif [ "${schema_type}" == "mysql" ]; then
    print_head " install mysql client "
    dnf install mysql -y &>>${log_file}
    status_check $?

    print_head " load schema "
    mysql -h mysql-dev.devopsb.cloud -uroot -p${mysql_root_password} < /app/schema/${component}.sql &>>${log_file}
    status_check $?
  fi
}

app_prereq_setup() {
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

}



nodejs(){
  print_head "disabling nodejs"
  dnf module disable nodejs -y &>>${log_file}
  status_check $?

  print_head "enabling nodejs"
  dnf module enable nodejs:18 -y &>>${log_file}
  status_check $?

  print_head "installing nodejs"
  yum install nodejs -y &>>${log_file}
  status_check $?

  app_prereq_setup

  print_head "installing nodejs dependencies"
  npm install &>>${log_file}
  status_check $?

  schema_setup
  systemd_setup

}
java(){
  print_head " install maven "
  yum install maven -y &>>${log_file}
  status_check $?


  app_prereq_setup

  print_head " download dependencies and packages "
  mvn clean package &>>${log_file}
  mv target/shipping-1.0.jar shipping.jar &>>${log_file}
  status_check $?

  schema_setup
  systemd_setup

}

python(){
  print_head " install python "
  yum install python36 gcc python3-devel -y &>>${log_file}
  status_check $?


  app_prereq_setup

  print_head " download dependencies and packages "
  pip3.6 install -r requirements.txt &>>${log_file}
  status_check $?



  systemd_setup

}

