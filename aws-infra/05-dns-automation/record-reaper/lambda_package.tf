# Packages handler.py into a zip for deployment. Defined once — both regions
# share the same archive since the code is identical.
data "archive_file" "record_reaper" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/record-reaper/handler.py"
  output_path = "${path.module}/../../lambda/record-reaper/record-reaper.zip"
}
