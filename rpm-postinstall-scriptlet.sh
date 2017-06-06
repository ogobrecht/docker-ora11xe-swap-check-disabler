echo "Executing post-install steps..."

if [ "$1" = "1"  -o -z "$2" ]  # first install
then
	if `grep -q -i ^dba: /etc/group`
	then
		echo ""
	else
		/usr/sbin/groupadd dba
	fi
	id oracle > /dev/null 2>&1
	status=$?
	if test $status -eq 0
	then
	        groups oracle | grep dba > /dev/null
		status=$?
	        if test $status != 0
	        then
	                /usr/sbin/usermod -G dba oracle
	        fi
	else
	        /usr/sbin/useradd -M -g dba -d /u01/app/oracle -s /bin/bash oracle
	fi


	# Creating the required symbolic links,directories and instantiatation
	if [ ! -d /u01/app/oracle/product/11.2.0/xe/config/log ]
	then
		mkdir -p /u01/app/oracle/product/11.2.0/xe/config/log
	fi

	if [ ! -d /u01/app/oracle/product/11.2.0/xe/rdbms/audit ]
	then
		mkdir -p /u01/app/oracle/product/11.2.0/xe/rdbms/audit
	fi

	if [ ! -d /u01/app/oracle/product/11.2.0/xe/rdbms/log ]
	then
		mkdir -p /u01/app/oracle/product/11.2.0/xe/rdbms/log
	fi

	if [ ! -d /u01/app/oracle/product/11.2.0/xe/network/trace ]
	then
		mkdir -p /u01/app/oracle/product/11.2.0/xe/network/trace
	fi

	if [ ! -d /u01/app/oracle/product/11.2.0/xe/network/log ]
	then
		mkdir -p /u01/app/oracle/product/11.2.0/xe/network/log
	fi

	cd /u01/app/oracle/product/11.2.0/xe/lib
	if [ ! -h /u01/app/oracle/product/11.2.0/xe/lib/libclntsh.so ]
	then
		ln -s libclntsh.so.11.1 libclntsh.so
	fi
	if [ ! -h /u01/app/oracle/product/11.2.0/xe/lib/libocci.so ]
	then
		ln -s libocci.so.11.1 libocci.so
	fi
	if [ ! -h /u01/app/oracle/product/11.2.0/xe/lib/libagtsh.so ]
	then
		ln -s libagtsh.so.1.0 libagtsh.so
	fi

	sed -i "s/%ORACLE_HOME%/\/u01\/app\/oracle\/product\/11.2.0\/xe/" /u01/app/oracle/product/11.2.0/xe/rdbms/admin/dbmssml.sql
	sed -i "s/%SO_EXT%/so/" /u01/app/oracle/product/11.2.0/xe/rdbms/admin/dbmssml.sql
	sed -i "s/%ORACLE_HOME%/\/u01\/app\/oracle\/product\/11.2.0\/xe/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/postScripts.sql

	# Remove -lipgo and -lsvml from sysliblist as they were not shipped in 11.2XE
	sed -i "s/-lipgo //" /u01/app/oracle/product/11.2.0/xe/lib/sysliblist
	sed -i "s/ -lsvml//" /u01/app/oracle/product/11.2.0/xe/lib/sysliblist

	availphymem=`cat /proc/meminfo | grep '^MemTotal' | awk '{print $2}'`
	availphymem=`echo $availphymem / 1024 | bc`
	memory_target=`echo 0.40 \* $availphymem | bc | sed "s/\..*//"`
	if [ $memory_target -gt 1024 ];
	then
		memory_target=`echo 1024 \* 1048576 | bc`
	else
		memory_target=`echo $memory_target \* 1048576 | bc`
	fi

	/bin/sed -i "s/%memory_target%/$memory_target/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
	/bin/sed -i "s/%memory_target%/$memory_target/g" /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora

fi

/bin/chown oracle:dba /u01/app/oracle
/bin/chown -R oracle:dba /u01/app/oracle/product/11.2.0/xe
/bin/chmod 755 /u01/app/oracle
/bin/chmod 755 /u01/app/oracle/product
/bin/chmod 755 /u01/app/oracle/product/11.2.0
/bin/chmod -R 755 /u01/app/oracle/product/11.2.0/xe
/sbin/ldconfig >/dev/null
/bin/chown oracle:dba /u01/app/oracle
/bin/chown -R oracle:dba /u01/app/oracle/product/11.2.0/xe
/bin/chmod 755 /u01/app/oracle
/bin/chmod 755 /u01/app/oracle/product
/bin/chmod 755 /u01/app/oracle/product/11.2.0
/bin/chmod -R 755 /u01/app/oracle/product/11.2.0/xe

/bin/chmod 755 /etc/init.d/oracle-xe

if [ -f /etc/SuSE-release ]
then
	cp -f /u01/app/oracle/product/11.2.0/xe/config/scripts/oracle-xe.sles /etc/init.d/oracle-xe
	/usr/lib/lsb/install_initd /etc/init.d/oracle-xe > /dev/null 2>&1
	/sbin/insserv /etc/init.d/oracle-xe > /dev/null 2>&1
	/sbin/SuSEconfig > /dev/null 2>&1
else
        /sbin/chkconfig --add oracle-xe
fi

/bin/chmod 6751 /u01/app/oracle/product/11.2.0/xe/bin/oracle
/bin/chmod 751 /u01/app/oracle/product/11.2.0/xe/bin/sqlplus

if [ "$1" = "1"  -o -z "$2" ]  # first install
then
	# Start Menu icons

        if test -d  /etc/kde/xdg/menus/OracleXE
        then
                echo ""
        else
                mkdir -p /etc/kde/xdg/menus/OracleXE/GetHelp
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/.directory ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/.directory
                ln -s /usr/share/desktop-menu-files/oraclexe-11g.directory /etc/kde/xdg/menus/OracleXE/.directory
        else
                ln -s /usr/share/desktop-menu-files/oraclexe-11g.directory /etc/kde/xdg/menus/OracleXE/.directory
	fi

        if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-startdb.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-startdb.desktop
                ln -s /usr/share/applications/oraclexe-startdb.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-startdb.desktop
        else
                ln -s /usr/share/applications/oraclexe-startdb.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-startdb.desktop
        fi


        if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-stopdb.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-stopdb.desktop
		ln -s /usr/share/applications/oraclexe-stopdb.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-stopdb.desktop
       	else
               	ln -s /usr/share/applications/oraclexe-stopdb.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-stopdb.desktop
        fi
	if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-runsql.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-runsql.desktop
                ln -s /usr/share/applications/oraclexe-runsql.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-runsql.desktop
        else
                ln -s /usr/share/applications/oraclexe-runsql.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-runsql.desktop
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-backup.desktop ]
        then
		rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-backup.desktop
                ln -s /usr/share/applications/oraclexe-backup.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-backup.desktop
        else
                ln -s /usr/share/applications/oraclexe-backup.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-backup.desktop
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-restore.desktop ]
        then
		rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-restore.desktop
                ln -s /usr/share/applications/oraclexe-restore.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-restore.desktop
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/oraclexe-getstarted.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/oraclexe-getstarted.desktop
                ln -s /usr/share/applications/oraclexe-getstarted.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-getstarted.desktop
        else
                ln -s /usr/share/applications/oraclexe-getstarted.desktop /etc/kde/xdg/menus/OracleXE/oraclexe-getstarted.desktop
        fi


        if [ -f /etc/kde/xdg/menus/OracleXE/GetHelp/.directory ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/GetHelp/.directory
                ln -s /usr/share/desktop-menu-files/oraclexe-gethelp.directory /etc/kde/xdg/menus/OracleXE/GetHelp/.directory
        else
                ln -s /usr/share/desktop-menu-files/oraclexe-gethelp.directory /etc/kde/xdg/menus/OracleXE/GetHelp/.directory
        fi
	if [ -f /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-registerforonlineforum.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-registerforonlineforum.desktop
                ln -s /usr/share/applications/oraclexe-registerforonlineforum.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-registerforonlineforum.desktop
        else
                ln -s /usr/share/applications/oraclexe-registerforonlineforum.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-registerforonlineforum.desktop
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-readdocumentation.desktop ]
	then
                rm -fr  /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-readdocumentation.desktop
                ln -s /usr/share/applications/oraclexe-readdocumentation.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-readdocumentation.desktop
        else
                ln -s /usr/share/applications/oraclexe-readdocumentation.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-readdocumentation.desktop
        fi

        if [ -f /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-gotoonlineforum.desktop ]
        then
                rm -fr /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-gotoonlineforum.desktop
                ln -s /usr/share/applications/oraclexe-gotoonlineforum.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-gotoonlineforum.desktop
        else
                ln -s /usr/share/applications/oraclexe-gotoonlineforum.desktop /etc/kde/xdg/menus/OracleXE/GetHelp/oraclexe-gotoonlineforum.desktop
        fi
	if [ -f /etc/xdg/menus/applications.menu ]
        then
                cp -f /usr/share/desktop-menu-files/oraclexe-11g.directory /usr/share/desktop-directories/oraclexe-11g.directory
                cp -f /usr/share/desktop-menu-files/oraclexe-gethelp.directory /usr/share/desktop-directories/oraclexe-gethelp.directory
                cp -f /u01/app/oracle/product/11.2.0/xe/config/scripts/oraclexe.menu /etc/xdg/menus
		sed -i '1,/<\/Menu>/ { /<\/Menu>/ r /u01/app/oracle/product/11.2.0/xe/config/scripts/oraclexe-merge.menu
                }' /etc/xdg/menus/applications.menu

        fi

	homedir=`echo $HOME`

	if [ "$homedir" != "/root" ]
	then
		loginuser=`who | cut -d' ' -f1 | uniq | sed -n '1p'`
		if [ -d $homedir/.gnome-desktop ]
		then
			/bin/su -s /bin/sh $loginuser -c "cp -f /usr/share/applications/oraclexe-gettingstarted.desktop $homedir/.gnome-desktop"
	        fi
		if [ -d $homedir/Desktop ]
		then
			/bin/su -s /bin/sh $loginuser -c "cp -f /usr/share/applications/oraclexe-gettingstarted.desktop $homedir/Desktop"
	        fi
	else
		loginuser=`who | cut -d' ' -f1 | uniq | sed -n '1p'`
		homedir=`sh -c "echo ~$loginuser"`
		if [ -d $homedir/.gnome-desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "cp -f /usr/share/applications/oraclexe-gettingstarted.desktop $homedir/.gnome-desktop"
                fi
                if [ -d $homedir/Desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "cp -f /usr/share/applications/oraclexe-gettingstarted.desktop $homedir/Desktop"
                fi
	fi

fi
rm -fr /u01/app/oracle/screenrc
rm -fr /u01/app/oracle/gtkrc
rm -fr /u01/app/oracle/emacs
rm -fr /u01/app/oracle/cshrc-DEFAULT_old
rm -fr /u01/app/oracle/cshrc-DEFAULT.06292004
rm -fr /u01/app/oracle/cshrc-DEFAULT
rm -fr /u01/app/oracle/cshrc
rm -fr /u01/app/oracle/bashrc-DEFAULT
rm -fr /u01/app/oracle/bashrc_logout

# Implenting setowner.sh script operations in the spec file, since it has
# dependency on rootmacro.sh script which is not shipped in 11.2XE

if [ ! -d /var/tmp/.oracle ]
then
  mkdir -p /var/tmp/.oracle;
fi

chmod 01777 /var/tmp/.oracle
chown root  /var/tmp/.oracle

if [ ! -d /tmp/.oracle ]
then
  mkdir -p /tmp/.oracle;
fi

chmod 01777 /tmp/.oracle
chown root  /tmp/.oracle

# setowner.sh operations ends here

CONFIGURATION=/etc/sysconfig/oracle-xe

[ -f "$CONFIGURATION" ] && . "$CONFIGURATION"

if [ "$CONFIGURE_RUN" != "true" ]
then
    echo -e "You must run '/etc/init.d/oracle-xe configure' as the root user to configure the database."
    echo
fi
