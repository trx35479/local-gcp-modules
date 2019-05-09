# data sources

data "google_project" "service_project" {
  project_id = "${var.service_project_id}"
}
