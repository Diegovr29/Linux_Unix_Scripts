
#!/bin/bash

if [ -f /usr/local/bin/pbrun ]
then
        ROOT="/usr/local/bin/pbrun"
else
        ROOT="/usr/local/bin/sudo"
fi

if [ -z "$1" ]
then
        echo "Ticket missing"
        exit 1
else
        if [ ! -d ~/share ]
        then
                mkdir ~/share
                # $ROOT mount ndhnas002.pfizer.com:/vol/wtivol01/unixhome/$USER    ~/share/
                $ROOT mount gsun20.pfizer.com:/export/home3/$USER   ~/share/
        else
                $ROOT umount ~/share
                rm -r ~/share
                mkdir ~/share
                $ROOT mount gsun20.pfizer.com:/export/home3/$USER   ~/share/
        fi
        LOGFILE=~/share/$1".txt"
        touch $LOGFILE
fi

Linux_fn ()
{
        ARCH=`uname -r | cut -c1-3`
        if [ $ARCH = "2.6" ]
        then
                echo " " >> $LOGFILE;
                echo "=================================================================================================== " >> $LOGFILE;
                hostname >> $LOGFILE;
                echo "HBA Driver:" >> $LOGFILE;
                RH_ARCH=`cat /etc/redhat-release | cut -d " " -f 7`
                if [ $RH_ARCH = "4" ]
                then
                        $ROOT /sbin/modinfo lpfc | egrep -v "parm|alias" >> $LOGFILE;
                        echo "Multipath:" >> $LOGFILE;
                        $ROOT /sbin/powermt display dev=all >> $LOGFILE;
                else
                        $ROOT /sbin/modinfo lpfc | head -6 >> $LOGFILE;
                        echo "Multipath:" >> $LOGFILE;
                        $ROOT /sbin/multipath -ll -v2 >> $LOGFILE;
                fi
                echo "=================================================================================================== " >> $LOGFILE;
                echo " " >> $LOGFILE
        else
                echo " " >> $LOGFILE;
                echo "=================================================================================================== " >> $LOGFILE;
                hostname >> $LOGFILE;
                echo "HBA Driver:" >> $LOGFILE;

                for i in `ls /proc/scsi/lpfc/`
                do
                        cat /proc/scsi/lpfc/$i >> $LOGFILE;
                done

                echo "Multipath:" >> $LOGFILE;
                if [ -f /sbin/powermt ]
                then
                        $ROOT /sbin/powermt display dev=all >> $LOGFILE;
                fi
                echo "=================================================================================================== " >> $LOGFILE;
                echo " " >> $LOGFILE
        fi
}

Solaris_fn ()
{
        echo " " >> $LOGFILE
        echo "=================================================================================================== " >> $LOGFILE;
        hostname >> $LOGFILE

        ARCH=`uname -r`
        if [ $ARCH = "5.10" ]
        then
                echo "HBA Driver:" >> $LOGFILE;
                $ROOT fcinfo hba-port >> $LOGFILE;
                echo "Multipath" >> $LOGFILE;
                getpath_fn
                echo " " >> $LOGFILE;
        else
                echo "HBA Driver:" >> $LOGFILE;
                $ROOT pkginfo -l lpfc >> $LOGFILE;
                echo "Multipath" >> $LOGFILE;
                if [ -f /etc/powermt ]
                then
                        $ROOT /etc/powermt display dev=all >> $LOGFILE;
                        echo " " >> $LOGFILE;
                else
                        getpath_fn
                        echo " " >> $LOGFILE;
                fi
        fi
        echo "=================================================================================================== " >> $LOGFILE;
}

getpath_fn ()
{
        $ROOT /usr/sbin/vxdmpadm listctlr all | egrep -v 'CTL|==' | awk '{print $1}' | sort | uniq > /tmp/controllers.txt;
        echo 'Controllers: ' ; cat /tmp/controllers.txt ;
        sed -e 's/.*/vxdmpadm getsubpaths ctlr=&/g' /tmp/controllers.txt > /tmp/control_check.txt ;
        echo 'To execute: ' ; cat /tmp/control_check.txt;
        chmod 777 /tmp/control_check.txt ;
        $ROOT /tmp/control_check.txt >> $LOGFILE
}

PLATFORM=`uname -s`

if [ $PLATFORM = "SunOS" ]
then
        Solaris_fn
else
        Linux_fn
fi

$ROOT umount ~/share/
rmdir ~/share

exit 0