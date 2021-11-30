# You can change profile
export AWS_PROFILE=default
export AWS_DEFAULT_PROFILE=$AWS_PROFILE

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

# This line lets chrome open the url automatically. 
# open -a 'Google Chrome' $LOGIN_URL