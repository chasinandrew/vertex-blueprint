# Vertex AI Template

This template provides a reference architecture for the training environment to be used as a template for data science initiatives. 

The goal of the module is to have a pre-built architecture and suite of GCP services deployed as a base environment across all Data Science & Analytics projects. The resources included as part of the deployment are the following:
  - A single BigQuery Dataset shared with all initiative team members. Each data scientist will have their own table inside the dataset.
  - A single GCS Bucket shared with all initiative team members. Each data scientist will have their own sub-folder inside the bucket.
  - An Artifact Registry repository to host Docker images with all initiative team members.
  - A Vertex AI Feature Store to store ML features with all initiative team members and workflows/pipelines.
  - Vertex AI Workbench User-managed Notebooks for each team member (one notebook per data scientist per initiative).


The following variables need to be defined within the tfvars before running a plan or apply.

  - notebooks
    ```hcl
    [{
      user                = string
      image_family        = string
      machine_type        = string, optional
      zone                = string, optional
      gpu_type            = string, optional
      gpu_count           = string, optional
      post_startup_script = string, optional
    }, ...]
    ```
