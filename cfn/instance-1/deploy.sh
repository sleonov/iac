# All parameters are default, coded in template
alias aws='aws --no-verify-ssl --profile sleonov-green'

CFN_STACK_NAME="learning-ec2-instance"
aws cloudformation deploy \
  --stack-name ${CFN_STACK_NAME} \
  --template-file ./ec2.yaml

aws cloudformation describe-stacks --stack ${CFN_STACK_NAME}