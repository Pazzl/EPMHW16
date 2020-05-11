#!/bin/bash

# Script for batch creating system users with shell access from file users.txt
#
# File should be located with same durectory with script
# Format of file should be like this:
# 1. user
# 2. another_user
# ....
# N. last_user
#
# Script will create files <user>-login-password.txt with username and password for each user in list
#

make_user() {
    usr=$1
    pass=$(cat /dev/urandom | tr -dc [:alnum:] | fold -w 16 | head -n 1)
    salt=$(cat /dev/urandom | tr -dc [:alnum:] | fold -w 8 | head -n 1)
    enc_pass=$(openssl passwd -6 -salt "${salt}" "${pass}")
    useradd -m -s /bin/bash -p $enc_pass $usr
    echo "${usr} - ${pass}" > "${usr}-login-password.txt"

    return
}

FILE='./users.txt'

if ! [[ -e ${FILE} ]]; then
    echo "File ${FILE} does not exists. Please check it."
    exit -1
fi

while read -r _ user; do
    make_user $user
done < "${FILE}"

if [[ -n $user ]]; then
    make_user $user
fi
