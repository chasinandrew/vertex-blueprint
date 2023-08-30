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
    bucket_name = "bucket-one"
  },
  {
    bucket_name = "bucket-two"
  }
]

datasets = [
  {
    dataset_id  = "dataset-one"
    user_group  = ["group:test@andrewchasin.joonix.net"]
    admin_group = ["group:test@andrewchasin.joonix.net"]
    ml_group    = ["group:test@andrewchasin.joonix.net"]
  },
  {
    dataset_id  = "dataset-two"
    user_group  = ["group:test@andrewchasin.joonix.net"]
    admin_group = ["group:test@andrewchasin.joonix.net"]
    ml_group    = ["group:test@andrewchasin.joonix.net"]
  }
]



secrets =[
  {
    secret_id = "secret1"
    secret_manager_admin_group = ["group:test@andrewchasin.joonix.net"]
    secret_accessor_group = ["group:test@andrewchasin.joonix.net"]
    secret_manager_viewer_group = ["group:test@andrewchasin.joonix.net"]
    grant_notebooks_access = true
  
  },
    {
    secret_id = "secret2"
    secret_manager_admin_group = ["group:test@andrewchasin.joonix.net"]
    secret_accessor_group = ["group:test@andrewchasin.joonix.net"]
    secret_manager_viewer_group = ["group:test@andrewchasin.joonix.net"]
    grant_notebooks_access = false
  
  }
  
]
