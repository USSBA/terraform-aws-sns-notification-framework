# Releases

## v5.0.0

- **BREAKING CHANGES**
  - Bump lambda submodule to `~> 3.1` will re-create lambdas
  - Bump notify_slack module to `~> 5.0`
  - AWS Provider is now `>= 4.8`

## v4.0.0

- **BREAKING CHANGES**
  - Bump lambda submodule to `~> 2.0` which will re-create lambdas
  - Flag webhook url variables as sensitive (tf 0.14+)
  - Call `nonsensitive` while iterating over a list (tf 0.15+)
- Bump sub-modules for Terraform 0.15 support

## v3.1.0

- Fancy formatting for CloudWatch Notifications to Teams

## v3.0.1

- BUGFIX: Apply cloudwatch_log_group_retention_in_days to notify-teams module as well

## v3.0.0

- Supporting Microsoft Teams for notifications
- **BREAKING CHANGES**
  - Basically all variables have been reworked
  - Default variables are prefixed with `default_`
  - Override variables are now in maps of `<color>_overrides`
  - `slack_webhook_key` is now `default_slack_webhook_url`, and requires the full `https://<blah>`
- Bump notify-slack module to ~> 4.11

## v2.1.0

- Bump notify-slack module to ~> 4.5 to support Terraform 0.14
- Add configurable cloudwatch_log_group_retention_in_days

## v2.0.0

- **Terraform 0.13**
- Possible Breaking Change
  - Bump to v4.1.0 of `notify-slack` module
    This caused a number of resources to redeploy, but we found no
    problems applying changes

## v1.2.0

- FEATURE: Adding outputs for lambda arns

## v1.1.1

- BUG: Fix bug with override channels not being used properly

## v1.1.0

- FEATURE: Adding `enabled` var to enable/disable creation of all resources

## v1.0.0

- Initial Release
