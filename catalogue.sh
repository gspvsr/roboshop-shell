#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp/
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
N="\e[0m"
Y="\e[33m"
G="\e[32m"


if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then    
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabling nodejs"

yum module enable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs:18"

#once the user is created, if you run this cript 2nd time
# This command will defnitely fail
# Improvement : first check the user already exist or not, if not exist then create

useradd roboshop &>>$LOGFILE

if [ $? -eq 0 ]; then
    echo -e "useradd ... $G created $N"
else
    echo -e "useradd ... $R NOT created $N"
fi

# write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

if [ $? -eq 0 ]; then
    echo -e "directory ... $G created $N"
else
    echo -e "directory... $R NOT created $N"
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "downloading catalogue artifact"

cd /app &>>$LOGFILE
VALIDATE $? "moving to into app diectory"

unzip /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "moving to into app diectory"

npm install &>>$LOGFILE
VALIDATE $? "installing the dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "demon-reload"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "estarting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "copying mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "installing mongo client"

mongo --host mongodb.gspaws.online </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "loading catalogue data into the mongodb"
