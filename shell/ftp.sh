#!/usr/bin/env bash
//�ϴ�

[plain] view plain copy
#!bin/sh  
export PUTFILE=a.txt  
ftp -v -n 223.105.1.174<<EOF     //��������ַ  
user userftp 12345678     //ftp�û���  ����  
binary       //�����ƾ�����  
cd /            //�������ϵ�ftp·��  
lcd /root         //���ص�·��  
put $PUTFILE  
prompt  
bye  
EOF  
echo "commit to ftp successfully"  
//����

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
