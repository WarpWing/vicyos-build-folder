#!/bin/bash
#set -e

buildFolder="$HOME/Vicyos-build"
outFolder="$HOME/Vicyos-Iso-Complete/"
finishedIso="$buildFolder/archiso/out/"
mkdir $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 1 : clean up and download the latest vicyos-iso from github";tput sgr0
echo "################################################################## "
echo
echo "Deleting the work folder if one exists"
[ -d work ] && rm -rf work
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder
echo "Git cloning files and folder to work folder"
git clone https://github.com/felipendc/vicyoslinux-unified-iso.git work

echo
echo "################################################################## "
tput setaf 2;echo "Phase 2 : Getting the latest versions for some important files";tput sgr0
echo "################################################################## "
echo
echo "Removing the old packages.x86_64 file from work folder"
rm work/archiso/packages.x86_64
echo "Copying the new packages.x86_64 file"
cp -f archiso/packages.x86_64 work/archiso/packages.x86_64
echo




##############################################################################
#######  Adapting the Output to be compatible with VicyosLinux-Dark:  ########
##############################################################################



# Set the Iso Label, Name, Publisher, Aplication, and ISO version!
sed -i "s/iso_name=/iso_name=vicyoslinux-dark/g" work/archiso/build.sh
sed -i "s/iso_label=/iso_label="vicyoslinux-dark-$(date +%Y.%m.%d)"/g" work/archiso/build.sh
sed -i "s/iso_publisher="'""'"/iso_publisher="'"vicyoslinux-dark <https:\/\/github.com\/felipendc>"'"/g" work/archiso/build.sh
sed -i "s/iso_application="'""'"/iso_application="'"vicyoslinux-dark Live\/Rescue CD"'"/g" work/archiso/build.sh
sed -i "s/iso_version=/iso_version="$(date +%Y.%m.%d)"/g" work/archiso/build.sh

# Add the build date to the "DISTRIB_RELEASE"
release=$(date +%Y.%m.%d)
sed -i "s/DISTRIB_ID=VicyosLinux/DISTRIB_ID=VicyosLinux-Dark-$release/g" work/archiso/airootfs/etc/vicyos-release
sed -i "s/DISTRIB_RELEASE=/DISTRIB_RELEASE=$release/g" work/archiso/airootfs/etc/vicyos-release
sed -i "s/VERSION_ID=/VERSION_ID=$release/g" work/archiso/airootfs/etc/os-release

# Print the Build dev-rel :
sed -i "s/ISO_CODENAME=VicyosLinux/ISO_CODENAME=VicyosLinux-Dark-$release/g" work/archiso/airootfs/etc/dev-rel
sed -i "s/ISO_RELEASE=/ISO_RELEASE=$release/g" work/archiso/airootfs/etc/dev-rel

# Change the Grub Distributor
sed -i "s/GRUB_DISTRIBUTOR="'"VicyosLinux"'"/GRUB_DISTRIBUTOR="'"VicyosLinux-Dark"'"/g" work/archiso/airootfs/etc/default/grub

###################################################################################
##################################################################################




echo "################################################################## "
tput setaf 2;echo "Phase 4 : Checking if archiso is installed";tput sgr0
echo "################################################################## "
echo

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "################## "$package" is already installed"
		echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with yay"
		echo "################################################################"
		yay -S --noconfirm $package

	elif pacman -Qi trizen &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with trizen"
		echo "################################################################"
		trizen -S --noconfirm --needed --noedit $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "#########  "$package" has been installed"
		echo "################################################################"

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

fi

echo
echo "################################################################## "
tput setaf 2;echo "Phase 5 : Moving files to build folder";tput sgr0
echo "################################################################## "
echo

echo "Copying files and folder to build folder as root"
sudo mkdir $buildFolder
sudo cp -r work/* $buildFolder

sudo chmod 750 ~/Vicyos-build/archiso/airootfs/etc/sudoers.d
sudo chmod 750 ~/Vicyos-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd ~/Vicyos-build/archiso/airootfs/etc/polkit-1/rules.d

echo "Deleting the work folder if one exists - clean up"
[ -d work ] && rm -rf work

cd $buildFolder/archiso


echo
echo "################################################################## "
tput setaf 2;echo "Phase 6 : Cleaning the cache";tput sgr0
echo "################################################################## "
echo

yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 7 : Build ISO";tput sgr0
echo "################################################################## "
echo

sudo ./build.sh -v

echo
echo "################################################################## "
tput setaf 2;echo "Phase 8 : Moving the iso to Vicyos-Iso-Complete folder";tput sgr0
echo You just need to access: /home/user/Vicyos-Iso-Complete/     
echo "################################################################## "
echo

# Using these lines below will fix the error: "no such file or directory" (GO BACK TO THE LINE 18,20,21 TO SET YOUR VARIABLE)
cp -r $finishedIso* $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 9 : Making sure we start with a clean slate next time";tput sgr0
echo "################################################################## "
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder