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

#TODO: default 
host_project_id = "arched-inkwell-368821"
network         = "default"
user_domain     = "google.com"

notebooks = [
  {
    user                = "andrewchasin"
    machine_type        = "n1-standard-4"
    zone                = "us-east4-b"
    image_family        = "common-cpu-notebooks-debian-10"
    post_startup_script = ""
  },
  {
    user                = "rawanbadawi"
    machine_type        = "n1-standard-4"
    zone                = "us-east4-b"
    image_family        = "common-cpu-notebooks-debian-10"
    post_startup_script = ""
  }
]

buckets = [
  {
    bucket_name          = "amc-bucket-s"
    sa_name              = "bucekt-sa"
    notebook_obj_admin   = true
    notebook_obj_viewer  = false
    notebook_obj_creator = false
  },
  {
    bucket_name = "amc-bucket-t"
  }
]

datasets = [
  {
    dataset_id           = "dataset_one"
    user_group           = ["group:test_priv_read@andrewchasin.joonix.net"]
    admin_group          = ["group:test_priv_read@andrewchasin.joonix.net"]
    ml_group             = ["group:test_priv_read@andrewchasin.joonix.net"]
    notebook_data_editor = true
    notebook_data_viewer = true
  },
  {
    dataset_id  = "dataset_two"
    user_group  = ["group:test_priv_read@andrewchasin.joonix.net"]
    admin_group = ["group:test_priv_read@andrewchasin.joonix.net"]
    ml_group    = ["group:test_priv_read@andrewchasin.joonix.net"]

  }
]


secrets = [
  {
    secret_id                     = "secret_one"
    secret_accessor_group         = ["group:test_priv_read@andrewchasin.joonix.net"] # who can access the secret
    secret_manager_admin_group    = []                                               # project level secret manager admins
    secret_manager_accessor_group = []                                               # project level iam to access secrets
    notebook_secret_accessor      = true                                             # specify if notebooks can access the secrets 

  }
]

