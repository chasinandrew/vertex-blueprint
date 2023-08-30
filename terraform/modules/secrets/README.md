- [HCA Cloud Module](#hca-cloud-module)
  - [Overview](#overview)
  - [Data Protection Requirements/Considerations](#data-protection-requirementsconsiderations)
  - [High Availability Requirements/Considerations](#high-availability-requirementsconsiderations)
  - [Disaster Recovery Requirements/Considerations](#disaster-recovery-requirementsconsiderations)
  - [Cloud Platform Organization Policies](#cloud-platform-organization-policies)
  - [Hashicorp Sentinel Policies](#hashicorp-sentinel-policies)
  - [Permissions Required](#permissions-required)
  - [Apis Required](#apis-required)
  - [How to Use this Module](#how-to-use-this-module)
    - [Example Name](#example-name)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

# HCA Cloud Module

Summary of module.

<br/> <!-- End HCA Cloud Module -->

## Overview

Details about the accomplishments of the module. What operations does it perform and what resources does it create?

<br/> <!-- End Overview -->

## Data Protection Requirements/Considerations
<u><font size="+1">Global Names and Replication Policies</font></u> 

 
Secret names you assign are project global resources. They are globally addressable by a single name but the underlying secret material is still stored in particular regions chosen during deployment. An application code can pin to a secret name or a specific version of that secret. 

Replication policies offer control over where your secret payloads are stored. With automatic replication, Google Cloud chooses the best regions to replicate your secret payload.  

HCA should leverage user-managed replication to gain full control over where the secrets are stored. Once the regions are chosen, Secret Manager automatically handles the replication between the regions. 

While replicating the secret payload to every region improves the reliability of accessing a secret, it may decrease the reliability of adding a secret version. In order to add a secret version, all of the regions you select must be operational. As a general recommendation, you should choose two but no more than five regions. 
 

<u><font size="+1">Secret Versioning</font></u> 

 
Versioning is a core tenant of reliable systems to support gradual rollout, emergency rollback, and auditing.  

A secret is a logical collection of secret versions. Secret Manager automatically versions secret data using secret versions, and most operations like access, destroy, disable and enable all take place on secret versions. While the parent secret holds the metadata information like name and replication policy, the secret version stores the actual secret payload.  

Once a secret version is created, its payload is immutable, which means a specific version of a secret will always contain the same payload. When the new secret version is added, it automatically becomes the latest version. 

Secrets are configuration resources, hence should be versioned with deployable artifacts. If your application is pinned to a specific secret version, and you want to update the secret used by that application, the application will be packaged, re-bundled and re-deployed. That way rollbacks are possible in case of a bug or problem and the application is then bundled in a known previously working version.  

HCA should pin the applications to specific versions in the production environment to make rollbacks possible and prevent system-wide downtime. The “latest” alias or pinning directly to the secret name should only be preferred in non-prod environments. 
<br/> <!-- End Data Protection Requirements/Considerations -->

## High Availability Requirements/Considerations

<br/> <!-- End High Availability Requirements/Considerations -->

## Disaster Recovery Requirements/Considerations

<br/> <!-- End Disaster Recovery Requirements/Considerations -->

## Cloud Platform Organization Policies

<br/> <!-- End Cloud Platform Organization Policies -->

## Hashicorp Sentinel Policies

<br/> <!-- End Hashicorp Sentinel Policies -->

## Permissions Required

<br/> <!-- End Permissions Required -->

## Apis Required

<br/> <!-- End APIs Required -->

## How to Use this Module

### Example Name

```hcl
module "module-name" {
    name = ""
    source = ""
    version = ""

    arguments = { ... }
}
```

<br /> <!-- How to Use this Module -->


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.57 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.57 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.sm_sa](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_project_iam_member.accessor_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.admin_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.version_adder_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.version_manager_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.viewer_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.secret_basic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |
| [google_secret_manager_secret_version.secret_version_basic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_pubsub_topic.topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/pubsub_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expire_time"></a> [expire\_time](#input\_expire\_time) | Timestamp in UTC when the Secret is scheduled to expire. | `string` | n/a | yes |
| <a name="input_ignore_secret_change"></a> [ignore\_secret\_change](#input\_ignore\_secret\_change) | If set to true, we will not change/reset the secret value back to the code | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | IAC-REQ-07 IAC-REQ-08 Create a global tagging and label strategy and attach tags and labels as appropriate. Must be one of restricted, phi, internal, public. Follow https://cloud.google.com/compute/docs/labeling-resources#requirements for labeling requirements. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location to replicate secret data | `string` | n/a | yes |
| <a name="input_next_rotation_time"></a> [next\_rotation\_time](#input\_next\_rotation\_time) | Timestamp in UTC at which the Secret is scheduled to rotate. Secret Manager will send a Pub/Sub notification to the topics configured on the Secret. If var.rotation\_period is set, then var.next\_rotation\_time must be set. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project where resources will be deployed | `string` | n/a | yes |
| <a name="input_pub_sub_topic"></a> [pub\_sub\_topic](#input\_pub\_sub\_topic) | Name of pub-sub topic where the secret rotation notifications should be published. Use '../pubsub' module for creating these topics | `string` | n/a | yes |
| <a name="input_rotation_period"></a> [rotation\_period](#input\_rotation\_period) | The Duration between rotation notifications. next\_rotation\_time will be advanced by this period when the service automatically sends rotation notifications. Must be in seconds and at least 3600s (1h) and at most 3153600000s (100 years).  If var.rotation\_period is set, then var.next\_rotation\_time must be set. | `string` | n/a | yes |
| <a name="input_secret_accessor_group"></a> [secret\_accessor\_group](#input\_secret\_accessor\_group) | List of users/groups with role roles/secretmanager.secretAccessor | `list(any)` | n/a | yes |
| <a name="input_secret_data"></a> [secret\_data](#input\_secret\_data) | The secret data. Must be no larger than 64KiB. Note: This property is sensitive and will not be displayed in the plan. | `string` | n/a | yes |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | ID of the secret. This must be unique within the project. | `string` | n/a | yes |
| <a name="input_secret_manager_accessor_group"></a> [secret\_manager\_accessor\_group](#input\_secret\_manager\_accessor\_group) | List of users to assign roles/secretmanager.secretAccessor role | `list(string)` | n/a | yes |
| <a name="input_secret_manager_admin_group"></a> [secret\_manager\_admin\_group](#input\_secret\_manager\_admin\_group) | List of users to assign roles/secretmanager.admin role | `list(string)` | n/a | yes |
| <a name="input_secret_manager_version_adder_group"></a> [secret\_manager\_version\_adder\_group](#input\_secret\_manager\_version\_adder\_group) | List of users to assign roles/secretmanager.secretVersionAdder role | `list(string)` | n/a | yes |
| <a name="input_secret_manager_version_manager_group"></a> [secret\_manager\_version\_manager\_group](#input\_secret\_manager\_version\_manager\_group) | List of users to assign roles/secretmanager.secretVersionManager role | `list(string)` | n/a | yes |
| <a name="input_secret_manager_viewer_group"></a> [secret\_manager\_viewer\_group](#input\_secret\_manager\_viewer\_group) | List of users to assign roles/secretmanager.viewer role | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ pub-sub-topic-storage-policy"></a> [ pub-sub-topic-storage-policy](#output\_ pub-sub-topic-storage-policy) | n/a |
| <a name="output_id"></a> [id](#output\_id) | An identifier for the resource with format `projects/{{project}}/secrets/{{secret_id}}` |
| <a name="output_pub-sub-topic"></a> [pub-sub-topic](#output\_pub-sub-topic) | n/a |
| <a name="output_pub-sub-topic-id"></a> [pub-sub-topic-id](#output\_pub-sub-topic-id) | n/a |
| <a name="output_pub-sub-topic-retention"></a> [pub-sub-topic-retention](#output\_pub-sub-topic-retention) | n/a |
| <a name="output_secret"></a> [secret](#output\_secret) | n/a |
| <a name="output_secret-id"></a> [secret-id](#output\_secret-id) | Secret ID |
| <a name="output_secret-version"></a> [secret-version](#output\_secret-version) | Version of the secret. |
| <a name="output_secret_expire_time"></a> [secret\_expire\_time](#output\_secret\_expire\_time) | n/a |
| <a name="output_secret_next_rotation"></a> [secret\_next\_rotation](#output\_secret\_next\_rotation) | n/a |
<!-- END_TF_DOCS -->