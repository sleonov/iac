output "repo_url" {
  value = aws_codecommit_repository.repo.clone_url_http
  description = "Repo HTTP URL"
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
  description = "Codebuild deployment role arn"
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.build_project.arn
  description = "Codebuild project arn"
}

output "codepipeline_arn" {
  value = aws_codepipeline.codepipeline.arn
  description = "Codepipeline arn"
}

