Bootstrap: docker
From: ubuntu

%files
	. /planner/translate

%post
	export DEBIAN_FRONTEND=noninteractive
    apt-get update
	ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
	apt-get install -y tzdata
	dpkg-reconfigure --frontend noninteractive tzdata

	apt install -y cmake g++ git make python3 haskell-stack flex bison

	# parser
	git clone https://github.com/panda-planner-dev/pandaPIparser.git /planner/parser
	cd /planner/parser
	make

	# HTN translate
	cd /planner/translate
	stack upgrade
	stack install
	cp /root/.local/bin/htntranslate .

	# FD
	git clone https://github.com/aibasel/downward.git /planner/fd
	cd /planner/fd
	./build.py

%runscript
    DOMAINFILE=$1
    PROBLEMFILE=$2
    PLANFILE=$3
    TIME=$4
    MEMORY=$5
    RANDOMSEED=$6
	
	stdbuf -o0 -e0 /planner/translate/execution-environment/runRonsPlanner.sh $DOMAINFILE $PROBLEMFILE 2>&1 | tee $PLANFILE


