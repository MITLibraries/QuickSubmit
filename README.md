# QuickSubmit

[![Build Status](https://travis-ci.org/MITLibraries/QuickSubmit.svg)](https://travis-ci.org/MITLibraries/QuickSubmit)
[![Dependency Status](https://gemnasium.com/MITLibraries/QuickSubmit.svg)](https://gemnasium.com/MITLibraries/QuickSubmit)
[![Code Climate](https://codeclimate.com/github/MITLibraries/QuickSubmit/badges/gpa.svg)](https://codeclimate.com/github/MITLibraries/QuickSubmit)
[![Coverage Status](https://coveralls.io/repos/github/MITLibraries/QuickSubmit/badge.svg?branch=master)](https://coveralls.io/github/MITLibraries/QuickSubmit?branch=master)
[![Documentation](https://img.shields.io/badge/documentation--blue.svg)](http://www.rubydoc.info/github/MITLibraries/QuickSubmit)

## What is this?

QuickSubmit is a brief web form where users can upload an article along with
sparse metadata. This will be transformed into METS and then SWORD and
submitted to an Institutional Repository (tested only with DSpace). The
primary purpose is to provide a simple upload experience with an end result of
providing a persistent URL to the submitter that they can use to show compliance
with any federal funder mandates.

The Sword packages are submitted asynchronously to provide a better user
experience. However, deploying on Heroku does not provide access to the
filesystem of the web worker from the background job worker, therefore the
attached files are stored temporarily on AWS S3. They are removed when the
QuickSubmit record is deleted. This can be scheduled or performed manually.

When the Sword package is received by DSpace, QuickSubmit will update the status
as appropriate. If there is no workflow enabled, QuickSubmit will receive a
Handle immediately and send it to the submitter. If workflow is enabled,
QuickSubmit will email the user explaining that our staff needs to approve the
submission and they will receive a follow up email after it is approved with the
persistent URL.

```
NOTE: Anything that happens in workflow, such as embargo setting, is not
dependent on any QuickSubmit logic and should be treated as DSpace itself.
Two exceptions (crosswalk and install event) follow that were added specifically
to support QuickSubmit's needs. However, even these should be thought of as
DSpace and not QuickSubmit.
```

### Crosswalk

Logic was added to our DSpace crosswalk that sets the funders to appropriate fields metadata fields.

### Install Event

A feature was added to DSpace to post some JSON to the `callback_uri` as part
of the `dspace install event`.

The `callback_uri` is included in the METS, and DSpace should post back JSON to
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

### DSpace Cleanup tasks

The `callback_uri` should be removed from the DSpace record metadata after the
record live. This does not have to be removed immediately, but there is no value
in retaining the `callback_uri` as part of our permanent record as it was only
necessary to allow QuickSubmit and DSpace to communicate.


## Developing this Application

### Testing with FakeS3

To prevent using a real S3 service in testing (and development if
you prefer), you can use the provided rake tasks `rake fakes3:start`
and `rake fakes3:stop` to spin up a fake of the service.

### Minimum Environment Variables for development

You can copy these into a .env file and use `heroku local` (included with the
   [Heroku Toolbelt](https://toolbelt.heroku.com)) to launch the application.
   You may want to remove the second line of Profile to disable processing of
   the job queue depending on what portions of the application you are working
   on.

`FAKE_AUTH_ENABLED=true` see Optional Environment Variables

`S3_BUCKET=fakebucket` see Environment Variables

`AWS_ACCESS_KEY_ID=12345` see Environment Variables

`AWS_SECRET_ACCESS_KEY=12345` see Environment Variables

NOTE: You'll need to add the 3 SWORD_* variables if you want to deliver packages in development

### Environment Variables

`EMAIL_FROM`: this is the default email address messages will be sent from

`MIT_OAUTH2_API_KEY`: key provided by MIT's OAuth service

`MIT_OAUTH2_API_SECRET`: secret provided by MIT's OAuth service

`SWORD_ENDPOINT`: URI of the sword service to deposit packages to

`SWORD_USERNAME`: username for sword endpoint

`SWORD_PASSWORD`: password for the sword endpoint

`S3_BUCKET`: whatever your bucket is. With fakes3 (for dev/test) using `fakebucket` as a value is best.

`AWS_ACCESS_KEY_ID`: your Amazon S3 bucket access key id. (not required with fakes3)

`AWS_SECRET_ACCESS_KEY` your Amazon S3 bucket secret access key. (not required with fakes3)

### Optional Environment Variables

`DISABLE_ALL_EMAIL`: set to `true` to not send any emails at all. This
disables critical communication portions of the app and should not be used
in production. This option is likely to be removed in the future.

`FAKE_AUTH_ENABLED`: set to `true` to use `:devloper` mode Omniauth which
prompts for and accepts any name/email combination. This is useful in PR
testing to avoid needing to configure the OpenID provider with a fleeting
hostname of the PR site. It can also be use in development, but never in
production.
