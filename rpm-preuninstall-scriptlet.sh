if [ "$1" = "0" ] # last uninstall
then
	if [ -f /u01/app/oracle/product/11.2.0/xe/config/scripts/stopall.sh ]
	then
		sh /u01/app/oracle/product/11.2.0/xe/config/scripts/stopall.sh
	fi
	rm -f /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora
	rm -f /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
	rm -f /u01/app/oracle/product/11.2.0/xe/config/scripts/postDBCreation.sql
	rm -f /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
	rm -f /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora
	if [ -f /etc/SuSE-release ]
        then
                /usr/lib/lsb/remove_initd /etc/init.d/oracle-xe > /dev/null 2>&1
                /sbin/SuSEconfig > /dev/null 2>&1
        else
                /sbin/chkconfig --del oracle-xe
        fi
	rm -f /etc/init.d/oracle-xe
fi
