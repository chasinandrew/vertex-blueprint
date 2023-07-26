gcp_project_id = "hca-demo-dev"
gcp_region     = "us-east4"

labels = {
  cost_id         = "14203"
  classification  = "sensitive"
  department_id   = "12651"
  hca_project_id  = "it-nc00a102"
  tco_id          = "cog"
  app_code        = "dsa"
  app_environment = "dev"
}

dsa_services = {
  dataset_id_prefix               = "hin_dsa"
  artifact_registry_naming_prefix = "docker-repo"
  bucket_suffix                   = "4dd3aa"
}
notebooks = [
  {
    user                = "plo4860"
    machine_type        = "n1-standard-4"
    zone                = "us-east4-b"
    image_family        = "tf-ent-2-8-cpu-ubuntu-2004"
    post_startup_script = "gs://dsa-dev-notebook-startup/deb-notebook-test-bucket/startuplab2.sh"
  },
  {
    user                = "otw4939"
    machine_type        = "n1-standard-1"
    zone                = "us-east4-a"
    image_family        = "common-cpu-notebooks-debian-10"
    post_startup_script = "gs://dsa-dev-notebook-startup/deb-notebook-test-bucket/startuplab2.sh"
  },
  {
    user                = "cax4817"
    machine_type        = "n1-standard-4"
    image_family        = "tf-ent-2-8-cpu-ubuntu-2004"
    post_startup_script = "gs://dsa-dev-notebook-startup/deb-notebook-test-bucket/startuplab2.sh"
  }
]
