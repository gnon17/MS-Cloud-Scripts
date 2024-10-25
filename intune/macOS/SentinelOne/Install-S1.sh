#!/bin/sh
siteToken="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
installerurl="https://yourstorageaccount.blob.core.windows.net/test/Sentinel-Release-24-2-2-7632_macos_v24_2_2_7632.pkg"
installer="Sentinel-Release-24-2-2-7632_macos_v24_2_2_7632.pkg"
dir="/tmp/"
tokenfile="com.sentinelone.registration-token"

if [ -d /Applications/SentinelOne/ ];
then
  echo "SentinelOne is already Installed"
  exit 0

else
#Download installer into tmp directory
curl -L -o /tmp/$installer $installerurl

#Create Site Token File
echo $siteToken > $dir$tokenfile

#Install Agent
/usr/sbin/installer -pkg /tmp/$pkgName -target /

#Cleanup token file
rm -f $dir$tokenfile
fi