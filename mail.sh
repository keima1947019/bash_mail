#!/bin/bash

# メール送信元アドレス
FROMADDRESS='s.john@fsolution.co.jp'

# メール送信元の人の名前
FROMNAME='John Smith'

# 実行前にワンクッションおく。readコマンドで$strに何か代入しているけどこのスクリプト内で$strが使われることは永遠にない。
echo "atesaki.csvを使ってメール並列個別送信します。"
echo "心の準備ができたらエンターキーを押して並列個別送信を実行下さい。"
read -p "Hit the enter key! : " str

# メール件名
MAILSUBJECT='パスワード変更通知'

i=0
while read line
do

# atesaki.csvの1行目を読み込んだ時だけスキップ
if [ $i = 0 ] ; then
  i=$((i += 1))
  continue
fi

  NAME=$(awk -F',' '{print $1}' <<<${line})
  ADDRESS=$(awk -F',' '{print $2}' <<<${line})
  PASSWORD=$(awk -F',' '{print $3}' <<<${line})
  cat <<EOF | mail -s ${MAILSUBJECT} \
    -S smtp=smtp://mail.fsolution.co.jp:587 \
    -S smtp-auth=login \
    -S smtp-auth-user=send-svinfo@fsolution.co.jp \
    -S smtp-auth-password=fs0123456789 \
    -r $FROMADDRESS \
    $ADDRESS
${NAME}さん

お疲れ様です。
情報システム部 $FROMNAMEです。

この度、パスワードポリシー変更に伴い、
${NAME}さんのパスワードが変更になりましたのでお知らせします。
新しいパスワードは「 ${PASSWORD} 」です。

パスワードの取り扱いについては慎重にお願いします。

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
