code_dir=$(pwd)

echo -e "\e[35m installing nginx \e[0m"
yum install nginx -y

echo -e "\e[35m removing old content \e[0m"
rm -rf /usr/share/nginx/html/*

echo -e "\e[35m downloading frontend content \e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip

echo -e "\e[35m extracting the downloaded frontend \e[0m"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip

echo -e "\e[35m copying nginx configuration for roboshop\e[0m"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf

echo -e "\e[35m enabling nginx \e[0m"
systemctl enable nginx

echo -e "\e[35m starting nginx \e[0m"
systemctl restart nginx

