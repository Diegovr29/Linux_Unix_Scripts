
#!/bin/bash

#
#
#  get_linux_nics.sh
#
#  This script gets the information of Linux NICs, including the bonding interfaces 
#
#



IFS_OLD=$IFS
IFS=$'\n'

for i in `mii-tool 2> /dev/null | awk '{print $1}' | sed 's/\://'`;
do
   echo $i
   echo "IP Add: "`ifconfig $i | grep "inet add"| awk '{print $2}'| cut -d":" -f2`
   Slave=`cat /etc/sysconfig/network-scripts/ifcfg-$i | grep SLAVE | cut -d "=" -f2`
   if [ -z $Slave ]
   then
      echo "SLAVE=No"
   else
      if [ $Slave = "yes" ]
      then
         echo `cat /etc/sysconfig/network-scripts/ifcfg-$i | grep "SLAVE"`
         echo `cat /etc/sysconfig/network-scripts/ifcfg-$i | grep "MASTER"`
      fi
   fi
   for n in `ethtool $i`; do
      echo $n| egrep "Speed|Duplex|Auto-negotiation|Link";
   done
   echo " "
done

echo " "
Bond=`ifconfig | grep bond | wc -l`
if [ $Bond -gt 0 ]
then
   for i in `ifconfig | grep bond | awk '{print $1}'`;
   do
      echo "Bonding interface $i"
      echo "IP Add: "`ifconfig $i | grep "inet add"| awk '{print $2}'| cut -d":" -f2`
      cat /proc/net/bonding/$i
      echo " "
   done
fi

IFS=$IFS_OLD