#Gmail script

#here are your account settings in plain text
muser=ahmad200512
mpass=0817263509182736ALl

mails="$(wget --secure-protocol=TLSv1 --timeout=3 -t 1 -q -O - \
https://$muser:$mpass@mail.google.com/mail/feed/atom \
--no-check-certificate 2>/dev/null)"

count=`echo "$mails" | grep fullcount | sed -e 's/.*<fullcount>//;s/<\/fullcount>.*//'`

titles=`echo "$mails" | grep title | sed -n -e 's/.*<title>\(.*\)<\/title>.*/\1/p' | sed -e '1d'`

emails=`echo "$mails" | grep email | sed -n -e 's/.*<email>\(.*\)<\/email>.*/\1/p'`

#echo "$titles"
#echo
echo -n "$count"
#echo
#echo "$emails"
