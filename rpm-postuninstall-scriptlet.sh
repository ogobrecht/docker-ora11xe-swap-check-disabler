/sbin/ldconfig >/dev/null
if [ "$1" = "0" ]  # last uninstall
then

	if [ -f /etc/oratab ]
	then
		/bin/cp /etc/oratab /etc/oratab.xe
		/bin/sed -i -s '/XE:\/u01\/app\/oracle\/product\/11.2.0\/xe:N/d' /etc/oratab.xe
		/bin/cp /etc/oratab.xe /etc/oratab
		/bin/rm -f /etc/oratab.xe
	fi

	rm -fr /etc/sysconfig/oracle-xe

	if test -d /u01/app/oracle/oradata/XE
	then
		rm -fr /u01/app/oracle/oradata/XE
	fi
	if test -d /u01/app/oracle/oradata
	then
		rm -fr /u01/app/oracle/oradata
	fi
	if test -d /u01/app/oracle/admin/XE
	then
		rm -fr /u01/app/oracle/admin/XE
	fi
	if test -d /u01/app/oracle/flash_recovery_area/XE
	then
		rm -fr /u01/app/oracle/flash_recovery_area/XE
	fi
	if test -d /u01/app/oracle/flash_recovery_area
	then
		rm -fr /u01/app/oracle/flash_recovery_area
	fi
	if test -d /u01/app/oracle/admin/cfgtoollogs/dbca/XE
	then
		rm -fr /u01/app/oracle/admin/cfgtoollogs/dbca/XE
	fi
	if test -d /u01/app/oracle/admin/cfgtoollogs/dbca
	then
		rm -fr /u01/app/oracle/admin/cfgtoollogs/dbca
	fi
	if test -d /u01/app/oracle/admin
	then
		rm -fr /u01/app/oracle/admin
	fi

	if test -d /u01/app/oracle/diag
        then
                rm -fr /u01/app/oracle/diag
        fi

	rm -fr /u01/app/oracle/product/11.2.0/xe
	rm -fr /u01/app/oracle/doc
	rm -fr /usr/share/doc/oracle_xe
	rm -fr /usr/share/desktop-menu-files/oraclexe-11g.directory
	rm -fr /usr/share/desktop-menu-files/oraclexe-gethelp.directory
	rm -fr /etc/kde/xdg/menus/OracleXE
	rm -fr /usr/share/gnome/vfolders/oraclexe-11g.directory
	rm -fr /usr/share/gnome/vfolders/oraclexe-gethelp.directory


	if [ -f /etc/xdg/menus/applications.menu ]
	then
		rm -f /usr/share/desktop-directories/oraclexe-11g.directory
		rm -f /usr/share/desktop-directories/oraclexe-gethelp.directory
		rm -f /etc/xdg/menus/oraclexe.menu

		sed -i '/<\!\-- Oracle XE \-->/,/<\!\-- End of Oracle XE \-->/d' /etc/xdg/menus/applications.menu

	elif [ -f /etc/X11/desktop-menus/applications.menu ]
	then
		sed -i '/<\!\-- Oracle XE \-->/,/<\!\-- End of Oracle XE \-->/d' /etc/X11/desktop-menus/applications.menu
	elif [ -f /etc/xdg/menus/applications-merged/kde-essential.menu ]
	then
		rm -f /usr/share/desktop-directories/oraclexe-11g.directory
		rm -f /usr/share/desktop-directories/oraclexe-gethelp.directory
		rm -f /etc/xdg/menus/oraclexe.menu
		sed -i '/<\!\-- Oracle XE \-->/,/<\!\-- End of Oracle XE \-->/d' /etc/xdg/menus/applications-merged/kde-essential.menu
	fi

	homedir=`echo $HOME`

        if [ "$homedir" != "/root" ]
        then
		loginuser=`who | cut -d' ' -f1 | uniq | sed -n '1p'`
                if [ -d $homedir/.gnome-desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "rm -f  $homedir/.gnome-desktop/oraclexe-gettingstarted.desktop"
                fi
                if [ -d $homedir/Desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "rm -f $homedir/Desktop/oraclexe-gettingstarted.desktop"
                fi
        else
		loginuser=`who | cut -d' ' -f1 | uniq | sed -n '1p'`
                homedir=`sh -c "echo ~$loginuser"`
                if [ -d $homedir/.gnome-desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "rm -f $homedir/.gnome-desktop/oraclexe-gettingstarted.desktop"
                fi
                if [ -d $homedir/Desktop ]
                then
                        /bin/su -s /bin/sh $loginuser -c "rm -f $homedir/Desktop/oraclexe-gettingstarted.desktop"
                fi
        fi

fi
