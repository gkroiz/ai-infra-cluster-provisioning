<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_instance_group_manager.mig](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_instance_group_manager) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_template_id"></a> [instance\_template\_id](#input\_instance\_template\_id) | The full URL to an instance template from which all new instances of this version will be created.<br><br>Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager#instance_template). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs.<br><br>Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#project). | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Arbitrary string with which all names of newly created resources will be prefixed. | `string` | n/a | yes |
| <a name="input_target_size"></a> [target\_size](#input\_target\_size) | The number of running instances for this managed instance group.<br><br>Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager#target_size), [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups/managed/create#--size). | `number` | n/a | yes |
| <a name="input_wait_for_instance"></a> [wait\_for\_instance](#input\_wait\_for\_instance) | Whether to wait for all instances to be created/updated before returning. Note that if this is set to true and the operation does not succeed, Terraform will continue trying until it times out.<br><br>Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager#wait_for_instances). | `bool` | `true` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone that instances in this group should be created in.<br><br>Related docs: [terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager#zone), [gcloud](https://cloud.google.com/sdk/gcloud/reference/compute/instance-groups/managed/create#--zone). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | `id` output of the google\_compute\_instance\_group\_manager resource created. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | `self_link` output of the google\_compute\_instance\_group\_manager resource created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->