
#!/bin/bash


if [ -z "$1" ]
then
   echo "You must define at leat one Filesystem separated by spaces"
   echo "Example: ./get_lun_tier.sh fs1 fs2 fs3...."
   exit 1
fi


while [ -n "$1" ]
do
   echo " "
   echo "Luns of $1"
   echo " "
   for i in `df -h $1 | awk '{print $1 }' | cut -d "/" -f 6`;
   do
      if [ $i != "Filesystem" ]
      then
         for n in `vxprint -ht -v $i | grep sd | awk '{print $8}'`;
         do
            echo "Lun Veritas ID = $n"
            LUN_TIER=`vxdmpadm list dmpnode dmpnodename=$n | grep pid | awk '{print $3}'`
            if [ $LUN_TIER == "SYMMETRIX" ]
            then
               echo "LUN is TIER 1"
            else
               echo "LUN is TIER 2"
            fi
            echo "LUN ID = `vxdmpadm list dmpnode dmpnodename=c1t5006048AD52E6008d109s2 | grep avid | awk '{print $3}'`"
            echo " "
         done
      fi
   done
   echo " <========================= END OF VOLUMES DETAILS==============================> "
   shift
done