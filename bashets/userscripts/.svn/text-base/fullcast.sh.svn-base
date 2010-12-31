#!/bin/bash

COUNTRY=`conkyForecast -d CO`
CITY=`conkyForecast -d CN`
CONDITIONS=`conkyForecast -d CT`
WINDDIR=`conkyForecast -d WD`
WINDSPEED=`conkyForecast -d WS`
HUMIDITY=`conkyForecast -d HM`
SUNRISE=`conkyForecast -d SR`
SUNSET=`conkyForecast -d SS`

echo "$CITY - $COUNTRY"
echo "-----------------------"
echo ""
echo "$CONDITIONS"
echo "Wind: $WINDDIR, $WINDSPEED"
echo "Sun: $SUNRISE to $SUNSET"
