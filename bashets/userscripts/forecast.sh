LOCATION=USNJ0095

ICON=`conkyForecast --location=$LOCATION --imperial --datatype=WF | tail -n 1`
TEMP=`conkyForecast --location=$LOCATION --imperial --datatype=HT | tail -n 1`

if echo "$ICON" | grep -q "No"; then
    echo -n "e N/A"
else
    echo -n "$ICON $TEMP"
fi
