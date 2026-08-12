# Packages handler.py into a zip for deployment. Defined once — both regions
# share the same archive since the code is identical.
data "archive_file" "record_manager" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/record-manager/handler.py"
  output_path = "${path.module}/../../lambda/record-manager/record-manager.zip"
}
