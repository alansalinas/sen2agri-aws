#!/bin/bash

### Installation script for Sen2Agri 2 with MAJA 3.3
### This software will provision the minimal CentOS 7 machine with the required
### dependencies and then install the Sen2Agri System, it requires you to provide
### the Sen2Agri installation package, the MAJA 3.3 installation package and the
### GIPP files for the respective version of MAJA you are using (CAMS, TM, etc)
### These files must be in an S3 bucket as specified in the paths below in the code

yum -y install epel-release # Add extra repositories
yum -y update  # Update repositories
yum -y install perl dkms kernel-devel make bzip2 # headers need restart for vmware tools install
yum -y install gcc gcc-c++ python-devel
yum -y install python-pip
yum -y install unzip
yum -y install python-beautifulsoup4
yum -y install git
yum -y install postgresql-devel # required for psycopg2
yum -y install postgis
# Install Python 3.6
yum -y install https://centos7.iuscommunity.org/ius-release.rpm
yum -y install python36u
yum -y install python36u-pip
yum -y install python36u-devel

# Install required Python packages
pip install lxml
pip install psycopg2
pip install awscli

# Make sure to be authenticated with AWS at this point either with aws configure or an IAM role in the instance
# Role needs to have S3 permmissions

# Download MAJA
aws s3 cp s3://your-bucket/provision/Maja-3.3.0-TM.zip /home/centos/Maja-3.3.0-TM.zip
unzip -d /home/centos/ /home/centos/Maja-3.3.0-TM.zip
rm -f /home/centos/Maja-3.3.0-TM.zip
chmod u+x /home/centos/Maja-3.3.0-TM/MAJA-3.3.0-TM.run
/home/centos/Maja-3.3.0-TM/MAJA-3.3.0-TM.run
# Download Sen2Agri 2.0
aws s3 cp s3://your-bucket/provision/Sen2Agri-package-2.0.zip /home/centos/
unzip -d /home/centos/ /home/centos/Sen2Agri-package-2.0.zip
rm -f /home/centos/Sen2Agri-package-2.0.zip
# Install Sen2Agri
(cd /home/centos/Sen2AgriDistribution/install_script && ./sen2agriPlatformInstallAndConfigCore.sh) # Install script needs to run from local dir
rpm -i /home/centos/Sen2AgriDistribution/rpm_binaries/sen2agri-downloaders-demmaccs-2.0.centos7.x86_64.rpm

# L2A processing sometimes fails with the included GIPP parameters in Sen2Agri
# it requires these extra files from Olivier Hagolle's repository
# Download the GIPP parameters for MAJA
git clone http://tully.ups-tlse.fr/olivier/gipp_maja.git /home/centos/gipp_maja
# Copy missing GIPP files
unalias cp
cp -rf /home/centos/gipp_maja/SENTINEL2_TM/* /home/centos/Sen2AgriDistribution/gipp_maja/SENTINEL2/

# Download SRTM files
curl http://www.esa-sen2agri.org/wp-content/uploads/resources/software/srtm.zip --output /home/centos/srtm.zip
mkdir /home/centos/srtm
unzip /home/centos/srtm.zip -d /home/centos/srtm
rm /home/centos/srtm.zip
# Download SWBD files
curl http://www.esa-sen2agri.org/wp-content/uploads/resources/software/swbd.zip --output /home/centos/swbd.zip
mkdir /home/centos/swbd
unzip /home/centos/swbd.zip -d /home/centos/swbd
rm /home/centos/swbd.zip

echo "Finished"