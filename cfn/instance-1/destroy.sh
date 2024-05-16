# All parameters are default, coded in template
alias aws='aws --no-verify-ssl --profile sleonov-green'

CFN_STACK_NAME="learning-ec2-instance"
aws cloudformation delete-stack --stack-name ${CFN_STACK_NAME}
