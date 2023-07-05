#!/bin/bash

# e-mail source address
FROMADDRESS='master@example.com'

# personal name with e-mail source address
FROMNAME='John Smith'

# This $str will never be used.
echo "When you are ready, press the Enter key to execute the parallel individual transmission."
read -p "Hit the enter key! : " str

# email subject
MAILSUBJECT='<mail subject strings>'

# email authentication info
SMTPSERVER='<smtp server FQDN>'
SMTPPORT='<tcp port number which smtp server uses>'
SMTPUSER='<smtp auth username>'
SMTPPASS='<smtp auth password strings>'

i=0
while read line
do
  # Skip only when the first line of atesaki.csv is read
  if [ $i = 0 ] ; then
    i=$((i += 1))
    continue
  fi

  NAME=$(awk -F',' '{print $1}' <<<${line})
  ADDRESS=$(awk -F',' '{print $2}' <<<${line})
  MSG=$(awk -F',' '{print $3}' <<<${line})
  cat <<EOF | mail -s ${MAILSUBJECT} \
    -S smtp=smtp://${SMTPSERVER}:${SMTPPORT} \
    -S smtp-auth=login \
    -S smtp-auth-user=${SMTPUSER} \
    -S smtp-auth-password=${SMTPPASS} \
    -r $FROMADDRESS \
    $ADDRESS
${NAME}さん

お疲れ様です。${FROMNAME}です。

${MSG}

どうぞよろしくお願いします。
EOF

ret=$?
if [ ! $ret -eq 0 ] ; then
  echo "$NAME（$ADDRESS）への送信が失敗しました。"
elif [ $ret -eq 0 ] ; then
  echo "$NAME（$ADDRESS）への送信が成功しました。"
fi

i=$((i += 1))

done < atesaki.csv