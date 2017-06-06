# Do not execute %pre section during upgrade

if [ "$1" != "1" -o -n "$2" ]
then
    exit 0
fi

# User must be root

if [ $(id -u) != "0" ]
then
    echo "You must be the root user to install the software" >&2
    exit 1
fi

# ORACLE_BASE must be unset
if `env | grep -q ORACLE_BASE`
then
	unset ORACLE_BASE
fi

if [ -f /etc/oratab ]
then
	if `grep -q ^XE: /etc/oratab`
	then
	        echo "The install cannot proceed because a database instance named 'XE' is
	configured on the system.  Delete the instance, remove the entry corresponding
	to this instance from the oratab file (/etc/oratab), and retry the installation."
        	exit 1
	fi
fi

# Check and disallow installation of 11.2XE, if /u01/app/oracle/product/11.2.0/xe directory
# exists and is not empty

if  [ -d /u01/app/oracle/product/11.2.0/xe ]
then
        if [ X"`ls -A /u01/app/oracle/product/11.2.0/xe`" != "X" ]
        then
        echo "The install cannot proceed because the directory \"/u01/app/oracle/product/11.2.0/xe\"
is not empty. Remove its contents and retry the installation."
        echo
        exit 1
        fi
fi

# Check and disallow if ORACLE_BASE directory /u01/app/oracle exists and not owned by oracle:dba

if [ -d /u01/app/oracle ]
then
        if [ "`ls -ld /u01/app/oracle | grep ^d | awk '{ print $3}'`" != "oracle" ]
        then
	echo
        echo "The install cannot proceed because ORACLE_BASE directory (/u01/app/oracle)
is not owned by \"oracle\" user. You must change the ownership of ORACLE_BASE
directory to \"oracle\" user and retry the installation."
        echo
        exit 1
        fi
fi

if [ -d /u01/app/oracle ]
then
        if [ "`ls -ld /u01/app/oracle | grep ^d | awk '{ print $4}'`" != "dba" ]
        then
	echo
        echo "The install cannot proceed because ORACLE_BASE directory (/u01/app/oracle)
is not owned by \"dba\" group. You must change the ownership of
ORACLE_BASE directory to \"dba\" group and retry the installation."
        echo
        exit 1
        fi
fi

# Check and change /u01,/u01/app,/u01/app/oracle,/u01/app/oracle/product,/u01/app/oracle/product/11.2.0
# and /u01/app/oracle/product/11.2.0/xe directory permissions to 755 if it is less.

if [ -d /u01  ]
then
        if test `stat -c "%a" /u01` -lt 755
	then
		chmod 755 /u01
        fi
fi

if [ -d /u01/app ]
then
	if test `stat -c "%a" /u01/app` -lt 755
	then
		chmod 755 /u01/app
	fi
fi

if [ -d /u01/app/oracle ]
then
	if test `stat -c "%a" /u01/app/oracle` -lt 755
	then
		chmod 755 /u01/app/oracle
	fi
fi

if [ -d /u01/app/oracle/product ]
then
	if test `stat -c "%a" /u01/app/oracle/product` -lt 755
	then
                chmod 755 /u01/app/oracle/product
        fi
fi

if [ -d /u01/app/oracle/product/11.2.0 ]
then
	if test `stat -c "%a" /u01/app/oracle/product/11.2.0` -lt 755
        then
                chmod 755 /u01/app/oracle/product/11.2.0
        fi
fi

if [ -d /u01/app/oracle/product/11.2.0/xe ]
then
	if test `stat -c "%a" /u01/app/oracle/product/11.2.0/xe` -lt 755
        then
                chmod 755 /u01/app/oracle/product/11.2.0/xe
        fi
fi

# Check and disallow for 1.5GB diskspace is not present on the system
if [ -d /u01/app/oracle ]
then
	diskspace=`df -k /u01/app/oracle | grep % | tr -s " " | cut -d" " -f4 | tail -1`
	diskspace=`expr $diskspace / 1024`
	if [ $diskspace -lt 1536 ]
	then
	echo "You have insufficient diskspace in the destination directory (/u01/app/oracle)
to install Oracle Database 11g Express Edition.  The installation requires at
least 1.5 GB free on this disk."
        exit 1
	fi
elif [ -d /u01/app ]
then
	diskspace=`df -k /u01/app | grep % | tr -s " " | cut -d" " -f4 | tail -1`
	diskspace=`expr $diskspace / 1024`
	if [ $diskspace -lt 1536 ]
	then
	echo "You have insufficient diskspace in the destination directory (/u01/app) to
install Oracle Database 11g Express Edition.  The installation requires at
least 1.5 GB free on this disk."
        exit 1
	fi
elif [ -d /u01 ]
then
	diskspace=`df -k /u01 | grep % | tr -s " " | cut -d" " -f4 | tail -1`
	diskspace=`expr $diskspace / 1024`
        if [ $diskspace -lt 1536 ]
        then
        echo "You have insufficient diskspace in the destination directory (/u01) to
install Oracle Database 11g Express Edition.  The installation requires at
least 1.5 GB free on this disk."
        exit 1
        fi
else
	diskspace=`df -k / | grep % | tr -s " " | cut -d" " -f4 | tail -1`
	diskspace=`expr $diskspace / 1024`
	if [ $diskspace -lt 1536 ]
        then
        echo "You have insufficient diskspace to install Oracle Database 11g Express Edition.
 The installation requires at least 1.5 GB free diskspace."
        exit 1
        fi
fi

# Check and disallow install, if RAM is less than 256 MB
space=`cat /proc/meminfo | grep '^MemTotal' | awk '{print $2}'`
PhyMem=`expr $space / 1024`
swapspace=`free -m | grep Swap | awk '{print $4}'`

if [ $PhyMem -lt 256 ]
then
        echo "Oracle Database 11g Express Edition requires a minimum of 256 MB of physical
memory (RAM).  This system has $PhyMem MB of RAM and does not meet minimum
requirements."
	echo
        exit 1
fi

reqswapspace=`echo 2 \* $PhyMem | bc`

min() {
    echo "$@" | tr '[[:space:]]' '\n' \
     | grep -Ee '^-?[[:digit:],]*(.[[:digit:]]+)?$' \
     | sort -n | sed 1q
}

requiredswapspace=`min 2047 $reqswapspace`

# check and disallow install, if swap space is less than Min( 2047, 2 * RAM)
# if [ $swapspace -lt $requiredswapspace ]
# then
# 	if [ "$requiredswapspace" = "2047" ];
# 	then
# 		requiredswapspace=2048
# 	fi
# 	echo
#         echo "This system does not meet the minimum requirements for swap space.  Based on
# the amount of physical memory available on the system, Oracle Database 11g
# Express Edition requires $requiredswapspace MB of swap space. This system has $swapspace MB
# of swap space.  Configure more swap space on the system and retry the
# installation."
# 	echo
#         exit 1
# fi

# Check and Update Kernel parameters
semmsl=`cat /proc/sys/kernel/sem | awk '{print $1}'`
semmns=`cat /proc/sys/kernel/sem | awk '{print $2}'`
semopm=`cat /proc/sys/kernel/sem | awk '{print $3}'`
semmni=`cat /proc/sys/kernel/sem | awk '{print $4}'`
shmmax=`cat /proc/sys/kernel/shmmax`
shmmni=`cat /proc/sys/kernel/shmmni`
shmall=`cat /proc/sys/kernel/shmall`
filemax=`cat /proc/sys/fs/file-max`
ip_local_port_range_lb=`cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $1}'`
ip_local_port_range_ub=`cat /proc/sys/net/ipv4/ip_local_port_range | awk '{print $2}'`

change=no
if [ $semmsl -lt 250 ]
then
        semmsl=250
	change=yes
fi

if [ $semmns -lt 32000 ]
then
        semmns=32000
	change=yes
fi

if [ $semopm -lt 100 ]
then
        semopm=100
	change=yes
fi
if [ $semmni -lt 128 ]
then
        semmni=128
	change=yes
fi

if [ "$change" != "no" ]
then
	echo "###########" >> /etc/sysctl.conf
	echo "# Oracle Database 11g Express Edition Recommended Values" >> /etc/sysctl.conf
	/sbin/sysctl -w kernel.sem="$semmsl $semmns $semopm $semmni" >> /etc/sysctl.conf
fi

changeshmmax=no
if [ $shmmax -lt 4294967295 ]
then
	shmmax=4294967295
	changeshmmax=yes
fi

changeshmmni=no
if [ $shmmni -lt 4096 ]
then
	shmmni=4096
	changeshmmni=yes
fi

changeshmall=no
if [ $shmall -lt 2097152 ]
then
	 shmall=2097152
	 changeshmall=yes
fi

changefilemax=no
if [ $filemax -lt 6815744 ]
then
	filemax=6815744
	changefilemax=yes
fi

if [ "$changeshmmax" != "no" ]
then
	/sbin/sysctl -w kernel.shmmax="4294967295" >> /etc/sysctl.conf
fi

if [ "$changeshmmni" != "no" ]
then
	/sbin/sysctl -w kernel.shmmni="4096" >> /etc/sysctl.conf
fi

if [ "$changeshmall" != "no" ]
then
	 /sbin/sysctl -w kernel.shmall="2097152" >> /etc/sysctl.conf
fi

if [ "$changefilemax" != "no" ]
then
	/sbin/sysctl -w fs.file-max="6815744" >> /etc/sysctl.conf
fi

changeport=no
if [ $ip_local_port_range_lb -lt 9000 ]
then
	changeport=yes
        ip_local_port_range_lb=9000
fi

if [ $ip_local_port_range_ub -gt 65500 ]
then
        ip_local_port_range_ub=65000
	changeport=yes
fi

if [ "$changeport" != "no" ]
then
	/sbin/sysctl -w net.ipv4.ip_local_port_range="$ip_local_port_range_lb $ip_local_port_range_ub" >> /etc/sysctl.conf
fi

if [ "$change" != "no" ] || [ "$changeport" != "no" ] || [ "$changeshmmax" != "no" ] || [ "$changeshmmni" != "no" ] || [ "$changeshmall" != "no" ] || [ "$changefilemax" != "no" ]
then
	echo "########" >> /etc/sysctl.conf
	/sbin/sysctl -e -p > /dev/null
fi
