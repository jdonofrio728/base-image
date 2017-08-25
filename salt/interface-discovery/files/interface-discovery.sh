#!/bin/sh

# Author: Jacob D'Onofrio
# Description: This purpose of this script is to fix the NIC names
# for vmware. VMware likes to change the hardware out when promoting
# between workstation/fusion to the ESX hosts. The NIC name will also change
# again when upgrading the virtual hardware once the VM lives on ESX.
# This is very frusterating as it causes vagrant/packer/terraform to break
# as the VM will not come up with an IP address since the new NIC doesn't
# have any settings. 
# If a static IP is needed, the vm needs to be provisioned with a config
# file for the NIC, and this script will leave it alone.

# Get list of interfaces
for link in `ip link | grep -v link | awk '{print $2;}' | sed 's/\://g'`; do
	echo $link
	if [ $link = "lo" ]; then
		echo "Skipping loopback interface"
		continue
	elif [ $link = "docker0" ]; then
		echo "Skipping docker bridge"
		continue
	elif [ $link =~ "^vmnet.*$" ]; then
		echo "Skipping VMware intergace ${link}"
		continue
	fi
	# Check to see if a config file exists for the interface
	fileName="/etc/sysconfig/network-scripts/ifcfg-${link}"
	if [ -f $fileName ]; then
		echo "Config script exists, skipping"
		continue
	fi
	echo "Generating file for ${link}"

	echo "NAME=${link}"  > $fileName
	echo "DEVICE=${link}" >> $fileName
	echo "ONBOOT=yes" >> $fileName
	echo "NETBOOT=yes" >> $fileName
	echo "BOOTPROTO=dhcp" >> $fileName
	echo "TYPE=Ethernet" >> $fileName
	echo "DEFROUTE=yes" >> $fileName
	echo "PEERDNS=yes" >> $fileName
	echo "PEERROUTES=yes" >> $fileName

	echo "Done"
done

# When interface names change, we want to remove the stale files so `systemctl network restart` call doesn't fail
for config in `ls /etc/sysconfig/network-scripts/ifcfg*`; do
	interface=$(echo $config | cut -d '-' -f3)
	echo "Verifying interface exists for file ${config}"
	flag="false"
	for link in `ip link | grep -v link | awk '{print $2;}' | sed 's/\://g'`; do
		if [ $link = $interface ]; then
			flag=true
			break
		fi
	done
	if [ $flag = "false" ]; then
		echo "Deleting file ${config}"
		rm -rf $config
	fi
done
