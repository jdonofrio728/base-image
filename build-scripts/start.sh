#!/bin/bash -x

# Author: Jacob D'Onofrio
# Date: November 2016

# Grab build number as argument
if [ $# -lt 1 ]; then
	echo "Missing build number"
	echo "start.sh <build-number>"
	exit 1
fi
export BOX_VERSION="1.0.${1}"

# Source common variables
source build-scripts/common.env

# Source build specific variables
if [ ! -z $OS ]; then
  source build-scripts/${OS}.env
fi

# Move kickstart template into place
cp kickstart/${KICKSTART_FILE}.template kickstart/${KICKSTART_FILE}

# Uncomment subscription-manager command for rhel
if [ $RH_REGISTER = "true" ]; then
  sed -i "s/\%REGISTER\%//" kickstart/${KICKSTART_FILE}
  # Set username and password
  if [ -z $RH_USERNAME ]; then
    echo "Missing Subscription username"
    exit 1
  fi
  if [ -z $RH_PASSWORD ]; then
    echo "Missing Subscription password"
    exit 1
  fi
  sed -i "s/\%USERNAME\%/${RH_USERNAME}/" kickstart/${KICKSTART_FILE}
  sed -i "s/\%PASSWORD\%/${RH_PASSWORD}/" kickstart/${KICKSTART_FILE}
else
  sed -i "s/\%REGISTER\%/#/" kickstart/${KICKSTART_FILE}
fi

# Set default hostname in kickstart file
sed -i "s/\%HOSTNAME\%/${SERVER_NAME}/" kickstart/anaconda-ks.cfg


export DEBUG=${DEBUG:-"false"}
if [ $DEBUG = "true" ]; then
  DEBUG="-debug"
else
  DEBUG=""
fi


# Run packer
PACKER="packer build ${DEBUG} -force ${PACKER_TEMPLATE}"
echo "Running packer: ${PACKER}"
${PACKER}
exitCode=$?
echo "Packer run complete"

if [ $exitCode -gt 0 ]; then
	echo "Packer build failed, see output"
	rm -rf packer_cache
	exit 1
fi

# Cleanup
rm -rf packer_cache
rm -rf kickstart/${KICKSTART_FILE}
