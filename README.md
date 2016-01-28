# QuickSubmit

[![Build Status](https://travis-ci.org/MITLibraries/QuickSubmit.svg)](https://travis-ci.org/MITLibraries/QuickSubmit)
[![Dependency Status](https://gemnasium.com/MITLibraries/QuickSubmit.svg)](https://gemnasium.com/MITLibraries/QuickSubmit)
[![Code Climate](https://codeclimate.com/github/MITLibraries/QuickSubmit/badges/gpa.svg)](https://codeclimate.com/github/MITLibraries/QuickSubmit)

## What is this?

QuickSubmit will be a brief form where users can upload an article along with sparse metadata. This will be transformed into METS and then SWORD and submitted to an Institutional Repository (DSpace for now).

## Testing with FakeS3

To prevent using a real S3 service in testing (and development if
you prefer), you can use the provided rake tasks `rake fakes3:start`
and `rake fakes3:stop` to spin up a fake of the service. 

## Required Environment Variables

`EMAIL_FROM`: this is the default email address messages will be sent from

`MIT_OAUTH2_API_KEY`: key provided by MIT's OAuth service

`MIT_OAUTH2_API_SECRET`: secret provided by MIT's OAuth service

`SWORD_ENDPOINT`: URI of the sword service to deposit packages to

`SWORD_USERNAME`: username for sword service

`SWORD_PASSWORD`: password for the sword service

`S3_BUCKET`

`AWS_ACCESS_KEY_ID`

`AWS_SECRET_ACCESS_KEY`
