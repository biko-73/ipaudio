#!/bin/sh
# ==================================================================================================
# Command: wget https://raw.githubusercontent.com/biko-73/ipaudio/main/installerp.sh -O - | /bin/sh #
# ================================================================================================== 
#config
file=ipaudiopro+
url=https://github.com/biko-73/ipaudio/raw/main/ipaudiopro+.tar.gz
package=/var/volatile/tmp/$file.tar.gz

#download & install
echo "> Downloading $file please wait ..."
sleep 3s

wget -O $package --no-check-certificate $url
tar -xzf $package -C /
extract=$?
rm -rf $package >/dev/null 2>&1

echo ''
if [ $extract -eq 0 ]; then
echo '*************************************************'
echo '**     ipaudiopro+ installed successfully"     **'
echo '*************************************************'
echo ''
echo '***************************************'
echo '**       Uploaded By Biko_73"        **'
echo '***************************************'
echo ''
sleep 3s

else

echo '**********************************************'
echo '**     ipaudiopro+ installation failed"     **'
echo '**********************************************'
sleep 3s
fi

exit 0
