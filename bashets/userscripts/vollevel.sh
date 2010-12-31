#!/bin/bash
#

#amixer get Master | grep "Front Left:" | awk '{print $5}' > /tmp/vollevel.out
#RES=$( cat /tmp/vollevel.out )

RES=$( amixer get $1 | grep "Front Left:" | awk '{print $5}' )
#echo -e $RES
#RES="[30%]"
RES=${RES##"["}
RES=${RES%%"%]"}
echo -n $RES #> /tmp/vollevel.out
