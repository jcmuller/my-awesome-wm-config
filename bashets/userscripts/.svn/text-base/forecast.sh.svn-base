LOCATION=RSXX0091

ICON=`conkyForecast --location=$LOCATION --datatype=WF | tail -n 1`
TEMP=`conkyForecast --location=$LOCATION --datatype=HT | tail -n 1`

if echo "$ICON" | grep -q "No"; then
    echo -n "e N/A"
else
    echo -n "$ICON $TEMP"
fi
