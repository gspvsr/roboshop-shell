#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp/
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
R="\e[31m"
N="\e[0m"
Y="\e[33m"
G="\e[32m"

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo -e " $R ERROR:: Please run script with root access $N "
    exit 1
fi

VALIDATE(){
    if [ $? -ne 0 ];
    then    
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installtion of MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited MongoDB conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MongoDB"