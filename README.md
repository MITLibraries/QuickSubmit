# QuickSubmit

[![Build Status](https://travis-ci.org/MITLibraries/QuickSubmit.svg)](https://travis-ci.org/MITLibraries/QuickSubmit)
[![Dependency Status](https://gemnasium.com/MITLibraries/QuickSubmit.svg)](https://gemnasium.com/MITLibraries/QuickSubmit)
[![Code Climate](https://codeclimate.com/github/MITLibraries/QuickSubmit/badges/gpa.svg)](https://codeclimate.com/github/MITLibraries/QuickSubmit)
[![Coverage Status](https://coveralls.io/repos/github/MITLibraries/QuickSubmit/badge.svg?branch=master)](https://coveralls.io/github/MITLibraries/QuickSubmit?branch=master)
[![Documentation](https://img.shields.io/badge/documentation--blue.svg)](http://www.rubydoc.info/github/MITLibraries/QuickSubmit)

## What is this?

QuickSubmit will be a brief form where users can upload an article along with
sparse metadata. This will be transformed into METS and then SWORD and
submitted to an Institutional Repository (tested only with DSpace for now).

A `callback_uri` is included in the METS, and the IR should post back JSON to
include the status of `approved` along with a handle when the submission is
approved into the repository. If Submissions are automatically approved and
the handle is returned during the Sword deposit, this is unnecessary to
configure at the repository level.

The `callback_uri` contains a UUID for the Submission in QuickSubmit as part
of the URI so there is no need to include that in the JSON.

Example JSON:
```json
{
  "status": "approved",
  "handle": "http://handle.net/123456/789"
}
```


## Testing with FakeS3

To prevent using a real S3 service in testing (and development if
you prefer), you can use the provided rake tasks `rake fakes3:start`
and `rake fakes3:stop` to spin up a fake of the service.

## Required Environment Variables

`EMAIL_FROM`: this is the default email address messages will be sent from

`MIT_OAUTH2_API_KEY`: key provided by MIT's OAuth service

`MIT_OAUTH2_API_SECRET`: secret provided by MIT's OAuth service

`SWORD_ENDPOINT`: URI of the sword service to deposit packages to

`SWORD_USERNAME`: username for sword endpoint

`SWORD_PASSWORD`: password for the sword endpoint

`S3_BUCKET`: whatever your bucket is. With fakes3 (for dev/test) using `fakebucket` as a value is best.

`AWS_ACCESS_KEY_ID`: your Amazon S3 bucket access key id. (not required with fakes3)

`AWS_SECRET_ACCESS_KEY` your Amazon S3 bucket secret access key. (not required with fakes3)

## Optional Environment Variables

`DISABLE_ALL_EMAIL`: set to `true` to not send any emails at all. This
disables critical communication portions of the app and should not be used
in production. This option is likely to be removed in the future.

`FAKE_AUTH_ENABLED`: set to `true` to use `:devloper` mode Omniauth which
prompts for and accepts any name/email combination. This is useful in PR
testing to avoid needing to configure the OpenID provider with a fleeting
hostname of the PR site. It can also be use in development, but never in
production.
