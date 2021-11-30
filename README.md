# aws-magic-link

The magic link generator to log-in AWS console by CLI credentials.

## Demo

1. Just run the script and you'll get the magic link as output. Open it with your browser.

```bash
> sh aws-magic-link.sh

https://signin.aws.amazon.com/federation?Action=login&Destination=https://console.aws.amazon.com/&SigninToken=SUPER_LONG_TOKEN_COMES_HERE
```

## Requirements

- Shell (Linux or Mac)
- AWS Command Line Interface (CLI) with valid IAM user credential
- jq

## Advanced usage

- Specify AWS profile by modifying this line

```bsah
export AWS_PROFILE=default
```

- Remove `#` and enable this line to open chrome automatically

```bsah
# open -a 'Google Chrome' $LOGIN_URL
```
