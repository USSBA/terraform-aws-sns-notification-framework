# Releases

## v10.0.0
- ** MAJOR UPDATE **
  - Support for MS Teams has been deprecated.
  - Support for color-based SNS topics has been deprecated.
  - The module will only provision a single SNS topic and the SRE will be responsible for categorizing severity in their Alarms names.
  - The TEXT/HTML templates have been updated offering a bit more detail about the Alarm that was triggered.
  - If the SRE is logged into the AWS account a URL is provided in the email directly to the Alarm.
  - The Email now provides the Date/Time in which the Alarm was triggered in EDT though we plan to make this conversion configurable in the future.
  - The variables `EMAIL_TO` and `EMAIL_FROM` are now required.
  - The variable `EMAIL_TO` now supports a comma-separated list of email addresses.
  - If the SRE has deployed v9.x or lower please decommission the module before deploying v10.x and above.
  - `~> 1.9` is now the minimal required Terraform version.
  - `~> 5.0` is now the minimal required AWS provider version.

## v9.0.0
- ** UPDATE **
  - Module no longer supports variable *kms_managed_key_id* and instead offers variable *kms_key_alias* when the variable *encrypted* is *true*.
  - Module will now create a KMS managed key with the provided *kms_key_alias* and the appropriate key policy to allow CloudWatch Alarms to send
    notifications when SNS Topics are *encrypted* at rest.

## v8.0.1
- **UPDATE**
  - Module now supports new variables for encryption at rest.
  - Terraform min version is now 1.6.

## v8.0.0
- **UPDATE**
  - Module now requires Terraform ~> 1.5 and Provider ~> 5.0

## v7.0.4
- **FIX**
  - Adding statement IDs to the SNS policy.

## v7.0.3
- **FIX**
  - Corrected the SNS policy so that Cloud Watch alarms can publish messages.

## v7.0.2
- **FIX**
  - Corrected logic causing the backup-vault-notification alerts to throw an exception when applying values to the template.

## v7.0.1
- **UPDATE**
  - Topic policies were added in support of AWS Backup Vault notifications.

## v7.0.0
- **BREAKING CHANGES**
  - Overhauled the SNS framework requiring any prior versions of the module to be destroyed before using version 7.x.
  - Refactored the Python3 and Terraform logic so that the function will only re-deploy when there is a change detected.
  - Red and Security notifications can now be configured to send and email notification along side the Microsoft Teams notification.

## v6.0.0

- **BREAKING CHANGES**
  - Removed slack notifications from the module. The module now only support Microsoft teams
  - Bumped Terraform version from `>= 0.13` to `~> 1.0`
  - Bumped AWS provider version from `>= 3.0` to `~> 4.0`

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
