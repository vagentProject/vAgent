#!/bin/bash

# while-menu: a menu-driven system information program


DELAY=1 # Number of seconds to display results




function_checkService()

{
dpkg-query -l stunnel4 &> /dev/null
stunnelStatus=$?

if [ $stunnelStatus -eq 0 ];then
          dpkg-query -l squid3 &> /dev/null
          sqStatus=$?
         if [ $sqStatus -eq 0 ];then

            clear
            echo -e "\033[32m---------------------------------\033[0m"
            echo -e "\033[32m vagent already installed\033[0m"
         else
         function_install
         function_ServicePort
         function_SqConf
         function_Basic_Authentication
         function_Stunnel_config
         function_vagentEcc
         function_vagentRestart
         function_printKey

         fi

else
        function_install
        function_ServicePort
        function_SqConf
        function_Basic_Authentication
        function_Stunnel_config
        function_vagentEcc
        function_vagentRestart
        function_printKey
fi



}

function_install()
{
echo -e "\033[32m install vagent.............\033[0m"
apt-get install squid3 stunnel4 apache2-utils -y  &> /dev/null
}

function_hitscheck()

{
dpkg-query -l stunnel4 &> /dev/null
stunnelStatus=$?

if [ $stunnelStatus -eq 0 ];then
          dpkg-query -l squid3 &> /dev/null
          sqStatus=$?
         if [ $sqStatus -eq 0 ];then

            clear
            echo -e "\033[32m---------------------------------\033[0m"
            echo -e "\033[32m vagent already installed\033[0m"
         else
         function_install
         function_ServicePort
         function_SqConf
         function_Basic_Authentication
         function_Stunnel_config
         function_vagentEcc
         function_vagentRestart
         function_printKey

         fi

else
        function_install
        function_ServicePort
        function_SqConf
        function_Basic_Authentication
        function_Stunnel_config
        function_vagentEcc
        function_vagentRestart
        function_printKey
fi



}


function_Uninstall()
{
service stunnel4 stop
/etc/init.d/squid stop
rm -R /etc/squid/*
rm -R /etc/stunnel
 apt-get purge --auto-remove  squid3 stunnel4
}

function_status()
{
/etc/init.d/squid status &> /dev/null
# store exit status of grep
# if found grep will return 0 exit stauts
# if not found, grep will return a nonzero exit stauts
status=$?

if test $status -eq 0
then
        echo -e "\033[32m Great vagent already running.............\033[0m"
else
        echo "------------------------"
        echo -e "\e[31mplease restart vagent\e[0m"
        echo "------------------------"
fi

}



function_SqConf()

{
echo -e "\033[32m Great vagent already running.............\033[0m"
wget --no-check-certificate -O /etc/squid/squid.conf https://gist.githubusercontent.com/e7d/1f784339df82c57a43bf/raw/squid.conf &> /dev/null
mkdir /var/log/squid  &> /dev/null
mkdir /var/cache/squid  &> /dev/null
mkdir /var/spool/squid  &> /dev/null
chown -cR proxy /var/log/squid  &> /dev/null
chown -cR proxy /var/cache/squid  &> /dev/null
chown -cR proxy /var/spool/squid  &> /dev/null
squid -z  &> /dev/null

}


function_Basic_Authentication()

{
userPwd=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')
htpasswd -c -b -d /etc/squid/users.pwd vagent $userPwd
echo "$userPwd" > /etc/squid/vagentPwd
}



function_printKey()

{
dpkg-query -l stunnel4 &> /dev/null
stunnelStatus=$?

if [ $stunnelStatus -eq 0 ];then
    dpkg-query -l squid3 &> /dev/null
    sqStatus=$?
                   if [ $sqStatus -eq 0 ];then

                             clear
                             echo -e "\e[31m----------------------------------------------key info Begin------------------------------\e[0m"
                             infoHits=$(cat /etc/stunnel/stunnel.pem)
                             echo -e "\033[32m $infoHits \033[0m"

                             echo -e "\e[31m----------------------------------------------key info END------------------------------\e[0m"
                             echo -e "\033[32m userName : vagent \033[0m"


                             userPwd=$(cat /etc/squid/vagentPwd)
                             echo -e "\033[32m password : $userPwd \033[0m"

                             #cat /etc/squid/vagentPwd
                             serverAdd=$(cat /etc/squid/vagentAdd)

                             echo -e "\033[32m $serverAdd \033[0m"
                             echo -e "\e[31m-----------------------------------------Authentication Account END----------------------\e[0m"

                        else
                          echo -e "\e[31mpleasee install vagent\e[0m"
                         fi

else
 echo -e "\e[31mpleasee install vagent\e[0m"
fi


}

function_Stunnel_config()
{

cat << EOF > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
[squid]
# Ensure the .connect. line matches your squid port. Default is 3128
accept = $port
connect = 127.0.0.1:3128
EOF
cat /etc/stunnel/stunnel.conf

}

function_vagentRestart()

{
/etc/init.d/squid restart &> /dev/null
status=$?

if test $status -eq 0
then
        echo -e "\033[32m Cache restart success \033[0m"
        stunnel4  &> /dev/null
        status=$?
        if test $status -eq 0
        then
        echo -e "\033[32m TLS services restart success \033[0m"
        else
        echo "------------------------"
        echo -e "\e[31mcache start fail\e[0m"
        fi

else
        echo "------------------------"
        echo -e "\e[31mTLS service fail\e[0m"
        echo "------------------------"
fi

}

function_vagentEcc()


{

Server_add=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'` 

# generate 384bit ca certicate
openssl ecparam -out /etc/stunnel/vagent.key -name  secp384r1 -genkey
openssl req -x509 -new -key /etc/stunnel/vagent.key \
-out /etc/stunnel/vagent.pem -outform PEM -days 3650 \
-subj "/emailAddress=$Email/CN=$Server_add/O=vAgent/OU=vAgent/C=Sl/ST=cn/L=vagent"

#Create the stunnel private key (.pem) and put it in /etc/stunnel.
cat /etc/stunnel/vagent.key /etc/stunnel/vagent.pem >> /etc/stunnel/stunnel.pem
#Show Algorithm
#openssl x509 -in  /etc/stunnel/stunnel.pem -text -noout
#openssl ecparam -list_curves
}



function_ServicePort()


{

read -p "input a port: "  port
Server_add=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
echo "$Server_add:$port" > /etc/squid/vagentAdd
read -p "input a Email: "  Email


}



while true; do
 # clear
  cat << _EOF_
Please Select:
------------------------------------------------------
1. Install vagent
2. Uninstall vagent
3. Show vagent status
4. print key and server info
5. restart vagent
0. Quit

_EOF_

  read -p "Enter selection [0-5] > "

  if [[ $REPLY =~ ^[0-5]$ ]]; then
    case $REPLY in
      1)
        function_checkService
        sleep $DELAY
        continue
        ;;
      2)
        function_Uninstall
        sleep $DELAY
        continue
        ;;
      3)
        function_status
        sleep 7
        continue
        ;;
      4)
        function_printKey

        sleep $DELAY
        continue
        ;;

       5)
        function_vagentRestart
        sleep $DELAY
        continue
        ;;
      0)
        break
        ;;
    esac
  else
    echo -e "\e[31mInvalid entry.\e[0m"
    sleep $DELAY
  fi
done
echo -e "\e[31mProgram terminated.\e[0m"
