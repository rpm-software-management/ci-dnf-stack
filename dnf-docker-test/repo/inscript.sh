#!/usr/bin/bash
#echo -ne "[test]\nname=test\nbaseurl=file:///build/test-5\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo
#dnf -y --disablerepo=* --nogpgcheck --enablerepo=test install TestC
#dnf install vsftpd -y
#service vsftpd start
#mkdir /var/ftp/repo/
#mount --bind /build/test-5/ /var/ftp/repo/
#dnf -y --disablerepo=* --nogpgcheck --enablerepo=test remove TestC
#echo -ne "[test]\nname=test\nbaseurl=ftp://127.0.0.1/repo/\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo


if [ -n "$(ls /build/setup_rpm/)" ]
then
  echo "Hallo1"
  #dnf -y install /build/setup_rpm/*
fi
if [ -n "$(ls /build/tested_rpm/)" ]
then
  echo "Hallo2"
  #dnf -y install /build/tested_rpm/*
fi


