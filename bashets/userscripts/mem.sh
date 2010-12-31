#!/bin/bash

TOTAL=`free | grep Mem | awk '{print $2}'`
USED=`free | grep - | awk '{print $3}'`
let PERCC=$USED*100/$TOTAL
echo -n $PERCC
