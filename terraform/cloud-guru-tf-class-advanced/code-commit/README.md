## Flow
### Create code commit repo in ```cicd```
- codecommit.tf (repository my-repo-1)
- outputs.tf (repository http URL)
- terraform (aws backend)
- run terraform apply
- After repo created:
  - generate HTTP credentials (user/password for AWS user)

### Add and commit code in ```git-repo/my-repo-1```
 - clone my-repo-1
   - ```cd git-repo```
   - git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/my-repo-1
 - Add terraform code to newly cloned repo:
     - scripts (user data)
     - terraform.tf (backend configuration with s3/dynamodb)
     - web-server.tf (vpc/instance)
     - .gitignore

### Go back to ```cicd``` and create codebuild stuff
- codebuild.tf (define codebuild project)
- run terraform apply
- verify role creation / codebuild project creation
- Manually update codebuild project to use branch/main in source (bug)

### Go to ```git-repo/my-repo-1``` and add build spec
- Add buildspec.yml
- commit

### Go to codebuild project in AWS and manually trigger the build
- It should succeed. If it fails check the project source properties (branch/ref)
- Check deployed resources.

### Got back to ```cicd``` and create codepipeline stuff
- codecommit.tf
- run terraform apply
- verify pipleline, S3 buckets creation

### ## Go to ```git-repo/my-repo-1``` and modify instance
- add tag to web instance, push to main branch
- it should trigger pipeline build
