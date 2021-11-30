# AWS CLIの認証情報だけでコンソールにログインするマジックリンクを作る

光栄なことにゲームエイトアドベントカレンダー１日目を拝命しました。

パスワードレス認証の１種であるマジックリンクっていいですよね。ユーザーは認証の手間なく、かつID・パスワード管理や漏洩のリスクの無いログイン基盤を提供できます。

AWSでも似たことができないかと思い、色々漁ってみたネタ記事になります。フェデレーテッドログインで近いことができそうなので試してみました。スクリプトは[githubに上げました](https://github.com/umihico/aws-magic-link)が、肝は以下の部分です。

```bash
USERNAME=$(aws sts get-caller-identity --output text --query 'Arn' | awk -F/ '{print $NF}')
TEMP_CRED=$(aws sts get-federation-token \
    --name $USERNAME$(date +%s) \
    --policy '{"Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}]}' \
    --output text \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    | sed $'s/\t/ /g')

SIGNIN_TOKEN=$(curl -sG \
    --data-urlencode "Action=getSigninToken" \
    --data-urlencode "SessionDuration=1800" \
    --data-urlencode "Session={\"sessionId\":\"$(echo $TEMP_CRED | cut -d ' ' -f1)\",\"sessionKey\":\"$(echo $TEMP_CRED | cut -d ' ' -f2)\",\"sessionToken\":\"$(echo $TEMP_CRED | cut -d ' ' -f3)\"}" \
    https://signin.aws.amazon.com/federation | jq -r .SigninToken)

CONSOLE_URL="https://console.aws.amazon.com/"
LOGIN_URL="https://signin.aws.amazon.com/federation?Action=login&Destination=${CONSOLE_URL}&SigninToken=${SIGNIN_TOKEN}"

echo $LOGIN_URL
```

AWS CLIが有効なシェル上でスクリプトを実行すると、最後に長いリンクが吐き出されます。これでブラウザを叩くと、ログインを完了してくれるマジックリンクになります。

顧問や業務委託の方にGUIに入って作業してほしい、かつ一時的であってほしいときなんかは、IAMユーザー作ってIDとパスワード発行してあげるよりは、こちらのURL渡してあげたほうがCoolかもしれません。この方法は時間制限が必須になり制御できるところも都合良いです。その際は`aws sts get-federation-token`の`--name`引数を修正してあげましょう。また、`get-federation-token`よりも`assume-role`を検討すべきかもしれません。

複数のAWSアカウントを日頃から細かく分けて作業している方なんかは、AWS_PROFILEを引数にショートカットを複数登録しておくとGUIに入るのが楽になるかもしれません。最後に`open -a 'Google Chrome' $LOGIN_URL`と足せばchromeが自動で開いてくれるようになります。

また、ログインは発行元のIAMユーザーではなくフェデレーテッドユーザーになり、IAMまわりに制約もでます。他の使途も提示こそしましたが、マジックリンクの実現という観点ではネタの域を出ることは難しそうでした。

個人的な学びはSSO系のログイン基盤の実装方法を知れたことと、aws-cliの`--output text --query`はカンマ区切りでキーを複数指定できて、タブ区切り出力できること、そしてターミナル上だとタブ区切りなのにシェル上の戻り値だとスペースに変換されるbashの挙動でした（今更すぎる）
