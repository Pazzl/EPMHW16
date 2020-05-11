#!/bin/bash

# Script for maintain simple c++ project
#
# This script should be located at user's home direccotry
# Folder 'mf' with source files should be located at home directory too
# Also should be added crontab with crontab -e:
# */15 * * * * $HOME/script_4.12.2.sh
#

CURR_DIR=$(pwd)
PR_DIR="${CURR_DIR}/mf"
PR_CPP_FILES="${PR_DIR}/*.cpp"
PR_H_FILES="${PR_DIR}/*.h"
PR_MAKE_FILE="${PR_DIR}/Makefile"
MD5_FILE="${CURR_DIR}/mf.md5"
ARCH_DIR="${CURR_DIR}/arch"
DATE_FMT="%Y-%m-%d_%H%M%S"

arch_n_compile() {
    md5sum $PR_CPP_FILES $PR_H_FILES $PR_MAKE_FILE > $MD5_FILE
    DATE=$(date +$DATE_FMT)
    tar -czf "${ARCH_DIR}/${DATE}.tar.gz" $PR_CPP_FILES $PR_H_FILES $PR_MAKE_FILE > /dev/null 2>&1
    cd $PR_DIR; make -f $PR_MAKE_FILE > /dev/null 2>&1

    return
}

if [[ -e "${MD5_FILE}" ]]; then
    if ! md5sum -c --status $MD5_FILE; then
        arch_n_compile
    fi
else
    if ! [[ -e "${ARCH_DIR}" ]]; then mkdir $ARCH_DIR; fi
    arch_n_compile
fi