#!/usr/bin/env bash
//上传

[plain] view plain copy
#!bin/sh  
export PUTFILE=a.txt  
ftp -v -n 223.105.1.174<<EOF     //服务器地址  
user userftp 12345678     //ftp用户名  密码  
binary       //二进制镜像传输  
cd /            //服务器上的ftp路径  
lcd /root         //本地的路径  
put $PUTFILE  
prompt  
bye  
EOF  
echo "commit to ftp successfully"  
//下载

[plain] view plain copy
#!bin/sh  
export GETFILE=b.txt  
ftp -v -n 223.105.1.174<<EOF  
user userftp 12345678  
binary  
cd /  
lcd /root  
get $GETFILE  
prompt  
bye  
EOF  
echo "get from ftp successfully"  
