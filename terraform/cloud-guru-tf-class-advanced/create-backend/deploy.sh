# AWS profile and options
AWS_PROFILE='sleonov-green'
AWS_OPTS='--no-verify-ssl'
# Stack
CFN_TEMPLATE='./backend.yml'
CFN_STACK_NAME='green-terraform-backend-infra'
# Params to CFN_TEMPLATE
S3_BUCKET_NAME_PARAM="green-terraform-backend"
DYNAMODB_TABLE_NAME_PARAM="green-terraform-backend"
KMS_ALIAS_NAME_PARAM="green-terraform-backend"

alias AWS="aws --profile ${AWS_PROFILE} ${AWS_OPTS}"

AWS --profile ${AWS_PROFILE} ${AWS_OPTS} cloudformation deploy \
    --stack-name $CFN_STACK_NAME \
    --template-file $CFN_TEMPLATE \
    --parameter-overrides "S3BucketName=${S3_BUCKET_NAME_PARAM}" \
      "DynamodbTableName=${DYNAMODB_TABLE_NAME_PARAM}" \
      "KMSAliasName=${KMS_ALIAS_NAME_PARAM}" \
      "Project=${CFN_STACK_NAME}"

s3_bucket=$(AWS cloudformation describe-stacks --stack ${CFN_STACK_NAME} --output text --query "Stacks[*].Outputs[?OutputKey=='S3Bucket'].OutputValue" | xargs)
dynamodb_table=$(AWS cloudformation describe-stacks --stack ${CFN_STACK_NAME} --output text --query "Stacks[*].Outputs[?OutputKey=='DynamoDBTable'].OutputValue" | xargs)

echo
echo "S3 bucket: ${s3_bucket}"
echo "DynamoDB Table: ${dynamodb_table}"
echo "*** Please, add these two values in your Backend block ***"
