if [ "$#" -ne 1 ]
then
  echo "Usage: source assume_role.sh [role_arn]"
  exit 1
fi

ROLE_ARN="$1"

role_session_name="AWSCLIResourceSession"
# 15 minutes should be sufficient to execute most AWS commands
aws_creds=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $role_session_name --duration-seconds 900 --output json)

if [ "$?" -ne 0 ]
then
  exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "${aws_creds}" | grep AccessKeyId | awk -F'"' '{print $4}' )
export AWS_SECRET_ACCESS_KEY=$(echo "${aws_creds}" | grep SecretAccessKey | awk -F'"' '{print $4}' )
export AWS_SESSION_TOKEN=$(echo "${aws_creds}" | grep SessionToken | awk -F'"' '{print $4}' )
export AWS_SECURITY_TOKEN=$(echo "${aws_creds}" | grep SessionToken | awk -F'"' '{print $4}' )
echo "session '$role_session_name' valid for 15 minutes"
