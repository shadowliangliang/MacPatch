# MacPatch - Install Distribution Server(s)

#### Mac OS X Requirements

Java JDK needs to be installed.

#### Linux Requirements

##### APT

	sudo apt-get update
	sudo apt-get install git
	sudo apt-get install build-essential
	sudo apt-get install openjdk-7-jdk
	sudo apt-get install zip
	sudo apt-get install libssl-dev
	sudo apt-get install libxml2-dev
	sudo apt-get install python-pip
	sudo apt-get install python-mysql.connector 


	sudo yum install gcc-c++
	sudo yum install openssl-devel
	sudo java-1.7.0-openjdk-devel
	sudo yum install libxml2-devel
	sudo yum install bzip2
	sudo yum install bzip2-libs
	sudo yum install bzip2-devel
	sudo yum install python-pip
	sudo yum install mysql-connector-python

	pip install requests
	pip install python-crontab
	cp {FROM_PATH}/MacPatch_Server.zip /Library/MacPatch
	cd /Library/MacPatch
	unzip ./MacPatch_Server.zip
	mv ./MacPatch_Server ./Server

##### Run Setup Scripts

	cd /Library/MacPatch/Server	
	./conf/scripts/Setup/DataBaseLDAPSetup.sh
	./conf/scripts/Setup/WebServicesSetup.sh

    BalancerMember http://localhost:3601 route=localhost-site1 loadfactor=50

	/Library/MacPatch/Server/conf/scripts/Setup/StartServices.py --load All