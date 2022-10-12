# tf-module-aws-patching

Simple scanning and patching for EC2 instances using AWS System Manager

## Change Log

### 0.1.0
- Initial release

## Using the Module

```
module "scanning_patching" {
  source = "git@github.com:CU-CommunityApps/tf-module-aws-patching.git?ref=v0.1.0"
}
```

Using the module defaults:
- patching and scanning will be targeted to EC2 instances tagged with `"Patch Group" = "default"`
- patching will occur on Tuesdays at 7am in the `America/New_York` time zone
- patching allows reboot, if needed. To change this behavior, set `patching_allow_reboot` to `false`.
- scanning will occur daily at 8am in the `America/New_York` time zone

## Limitations

This module uses the default AWS patch baseline for all operating systems.
