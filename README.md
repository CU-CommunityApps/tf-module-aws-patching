# tf-module-aws-patching

Simple scanning and patching for EC2 instances using AWS System Manager

## Change Log

### 1.0.0
- Add `base_name` variable to use in naming resources to avoid name clashes.
- Create maintenance window resources only if the task they implement is enabled.
- Fix bug where scanning maintenance window was incorrectly enabled if patching was enabled.

### 0.3.0
- Add optional maintenance window to run patching cleanup commands. By default this is not enabled. By default, this runs `apt-get --yes autoremove` the the set of commands can be customized.
- add auto-release Github workflow

### 0.2.0
- add CloudWatch Log Insights query definitions for errors in stdout and stderr, for both patching and scanning

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

## Auto-Release

This repository is configured with a Github workflow to automatically created releases.
```
$ git add .
$ git commit -m "blah, blah"
$ git tag -a v1.0.0 -m "v1.0.0"
$ git push origin --follow-tags

# OR, if you have set the global push.followTags settings to true
$ git push origin
```

## Limitations

This module uses the default AWS patch baseline for all operating systems.
