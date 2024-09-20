#!/bin/sh

# Configuration
#########################################
plugin="ipaudiopro"
git_url="https://github.com/biko-73/ipaudio/-/raw/main/1.3"
version=$(wget $git_url/version -qO- | awk 'NR==1')
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/IPaudioPro"
package="enigma2-plugin-extensions-$plugin"
temp_dir="/tmp"

arch=$(uname -m)
python=$(python -c "import platform; print(platform.python_version())")

case $python in 
3.9.9)
if [ "$arch" == "mips" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py3.9/ipaudiopro-mips.tar.gz"
targz_file="$plugin-mips.tar.gz"
elif [ "$arch" == "armv7l" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py3.9/ipaudiopro-arm.tar.gz"
targz_file="$plugin-arm.tar.gz"
fi
;;

2.7.18)
if [ "$arch" == "mips" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py2/ipaudiopro-mips.tar.gz"
targz_file="$plugin-mips.tar.gz"
elif [ "$arch" == "armv7l" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py2/ipaudiopro-arm.tar.gz"
targz_file="$plugin-arm.tar.gz"
fi
;;

3.12.1|3.12.2|3.12.3|3.12.4|3.12.5|3.12.6)
if [ "$arch" == "mips" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py3.12/ipaudiopro-mips.tar.gz"
targz_file="$plugin-mips.tar.gz"
elif [ "$arch" == "armv7l" ]; then
url1="https://github.com/biko-73/ipaudio/-/raw/main/1.3/py3.12/ipaudiopro-arm.tar.gz"
targz_file="$plugin-arm.tar.gz"
fi
;;
3.11.1|3.11.2|3.11.3|3.11.4|3.11.5|3.11.6)
wget -q "--no-check-certificate" https://github.com/biko-73/ipaudio/-/raw/main/ipaudiopro.sh -O - | /bin/sh
exit 1
;;
*)
echo "> your image python version: $python is not supported"
sleep 3
exit 1
;;
esac

# Determine package manager
#########################################
if command -v dpkg &> /dev/null; then
package_manager="apt"
status_file="/var/lib/dpkg/status"
uninstall_command="apt-get purge --auto-remove -y"
else
package_manager="opkg"
status_file="/var/lib/opkg/status"
uninstall_command="opkg remove --force-depends"
fi

#check and_remove package old version
#########################################
check_and_remove_package() {
if [ -d $plugin_path ]; then
echo "> removing package old version please wait..."
sleep 3 
rm -rf $plugin_path > /dev/null 2>&1

if grep -q "$package" "$status_file"; then
echo "> Removing existing $package package, please wait..."
$uninstall_command $package > /dev/null 2>&1
fi
echo "*******************************************"
echo "*            Package uninstalled          *"
echo "*            Uploaded By Biko_73          *"
echo "*******************************************"
sleep 3
exit 1
else
echo " " 
fi  }
check_and_remove_package

#check and install dependencies
#######################################
pyv=$(python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
#check python version
python=$(python -c "import platform; print(platform.python_version())")
sleep 1
deps=("alsa-conf" "alsa-plugins" "alsa-state" "libasound2" "enigma2" "libc6" "libgcc1" "libasound2" "libstdc++6" "libpython${pyv}-1.0")

if [ "$(opkg info libavcodec60 | grep -Fic Package)" = 1 ]; then
deps+=("libavcodec60" "libavformat60")
elif [ "$(opkg info libavcodec58 | grep -Fic Package)" = 1 ]; then
deps+=("libavcodec58" "libavformat58")
fi

left=">>>>"
right="<<<<"
LINE1="---------------------------------------------------------"
LINE2="-------------------------------------------------------------------------------------"
if [ -f /etc/opkg/opkg.conf ]; then
  STATUS='/var/lib/opkg/status'
  OSTYPE='Opensource'
  OPKG='opkg update'
  OPKGINSTAL='opkg install'
elif [ -f /etc/apt/apt.conf ]; then
  STATUS='/var/lib/dpkg/status'
  OSTYPE='DreamOS'
  OPKG='apt-get update'
  OPKGINSTAL='apt-get install -y'
fi

install() {
  if ! grep -qs "Package: $1" "$STATUS"; then
    $OPKG >/dev/null 2>&1
    rm -rf /run/opkg.lock
    echo -e "> Need to install ${left} $1 ${right} please wait..."
    echo "$LINE2"
    sleep 0.8
    echo
    if [ "$OSTYPE" = "Opensource" ]; then
      $OPKGINSTAL "$1"
      sleep 1
      clear
    elif [ "$OSTYPE" = "DreamOS" ]; then
      $OPKGINSTAL "$1" -y
      sleep 1
      clear
    fi
  fi
}
for i in "${deps[@]}"; do
  install "$i"
done

#image version
imageversion=$(grep ^imgversion=* /usr/lib/enigma.info | sed 's/imgversion=//g')
imageversion=$(echo "$imageversion" | awk '{print substr($0, 2, length($0) - 2)}')

#image
  if [ -f /etc/image-version ]; then
image=$(cat /etc/image-version | grep -iF "creator" | cut -d"=" -f2 | xargs)
  elif [ -f /etc/issue ]; then
image=$(cat /etc/issue | head -n1 | awk '{print $1;}')
  else
  image=''
  fi

if [[ "$imageversion" == "7.5" ]] && [[ "$image" == "openATV" ]]; then
#check arch armv7l aarch64 mips 7401c0 sh4
arch=$(uname -m)
if [ -f /etc/apt/apt.conf ]; then
install="apt-get install -y"
elif [ -f /etc/opkg/opkg.conf ]; then
install="opkg install --force-reinstall --force-depends"
fi
mips_url="https://github.com/biko-73/Feed/-/raw/main/dependencies/mips"
arm_url="https://github.com/biko-73/Feed/-/raw/main/dependencies/armv7l"

for i in libswresample4 libavutil58 libavcodec60 libavformat60 
do
echo -e "> Need to install ${left} $i ${right} please wait..."
if [ "$arch" == "aarch64" ]; then
echo "> your device is not supported"
sleep 3
exit 1
elif [ "$arch" == "mips" ]; then
wget --show-progress $mips_url/$i.ipk -qP /tmp; $install /tmp/$i.ipk ; rm -f /tmp/$i.ipk

elif [ "$arch" == "armv7l" ]; then
wget --show-progress $arm_url/$i.ipk -qP /tmp; $install /tmp/$i.ipk ; rm -f /tmp/$i.ipk
fi
done
fi

#download & install package
#########################################
download_and_install_package() {
echo "> Downloading $plugin-$version package  please wait ..."
sleep 3
wget --show-progress -qO $temp_dir/$targz_file --no-check-certificate $url1
tar -xzf $temp_dir/$targz_file -C / > /dev/null 2>&1
extract=$?
rm -rf $temp_dir/$targz_file >/dev/null 2>&1

if [ $extract -eq 0 ]; then
  echo "> $plugin-$version package installed successfully"
  sleep 3
  echo ""
else
  echo "> $plugin-$version package download failed"
  sleep 3
fi  }
download_and_install_package

# Remove unnecessary files and folders
#########################################
print_message() {
echo "> [$(date +'%Y-%m-%d')] $1"
}
cleanup() {
[ -d "/CONTROL" ] && rm -rf /CONTROL >/dev/null 2>&1
rm -rf /control /postinst /preinst /prerm /postrm /tmp/*.ipk /tmp/*.tar.gz >/dev/null 2>&1
print_message "> Uploaded By Biko_73"
}
cleanup
    