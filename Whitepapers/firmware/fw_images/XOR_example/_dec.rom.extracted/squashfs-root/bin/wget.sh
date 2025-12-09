#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Need three parameters!"
    echo "Please enter: [Device IP] [Device password]"
    exit
fi

time=`date +%s%3N`
ip=$1
pwd=$2
host_path=http://$1
nonce_path=${host_path}/webNonce?time=$time

cookie_file='cookie.txt'
nonce_file='webNonce.txt'
cd /var/system_status
cp -ar /usr/webs/*.js /var/system_status
cp -ar /usr/webs/Signal*.gif /var/system_status
cp -ar /usr/webs/*.css /var/system_status


wget -O $nonce_file $nonce_path
webNonce=`cat ${nonce_file}`
cookie=`echo -n $pwd$webNonce | md5sum | awk '{print $1}'`
echo $cookie > $cookie_file
CookieValue="Password508="$cookie
wget --header "Cookie: name=${CookieValue}" ${host_path}/main.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/system_status.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/wireless_status.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/client_list.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/DinPwrStatus.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/bridge_status.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/routing.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/lldp.asp
wget --header "Cookie: name=${CookieValue}" ${host_path}/arp.asp
