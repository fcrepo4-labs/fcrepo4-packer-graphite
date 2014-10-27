# Packer Graphite [![Build Status](https://travis-ci.org/ksclarke/packer-graphite.png?branch=master)](https://travis-ci.org/ksclarke/packer-graphite)

A Packer.io build for Graphite.  [Packer.io](http://www.packer.io/) is a tool for creating identical machine images for multiple platforms from a single source configuration.  It supports build products for Amazon EC2, Digital Ocean, Docker, VirtualBox, VMWare, and others.  [Graphite](https://graphite.readthedocs.org/en/latest/) is an enterprise-scale monitoring (and graphing) tool that runs well on cheap hardware. 

## Introduction

Usually a [Packer.io build](http://www.packer.io/docs/command-line/build.html) would be run with something like:

    packer build -only=amazon-ebs -var-file=vars.json graphite.json

But, because I want to include comments in my JSON configuration file, I've written a simple wrapper script. To use that, run:

    ./build.sh

or

    ./build.sh amazon-ebs

This will include the variables file and strip the comments out of packer-graphite.json, creating the graphite.json file. Right now, only the EC2 AMI is generated but, in the future, supplying the builder (e.g. "amazon-ebs", "virtualbox-iso", etc.) will configure the process to only use that builder.

_Note: To have the build script use the packer-graphite.json file, you'll need to have [strip-json-comments](https://github.com/sindresorhus/strip-json-comments) installed.  If you don't have that installed, the build script will use the pre-generated graphite.json file. Any changes meant to persist between builds should be made to the packer-graphite.json file._

## Configuration

Before you run the build script, though, you'll need to configure a few important variables.  To get you started, the project has an `example-vars.json` file which can be copied to `vars.json` and edited.  The build script will then inject these variables into the build.  There are some variables that are general and some that are specific to a particular builder (which will only need to be supplied if you intend to use that builder).

_Note: When running the build script, any variable in the vars.json file that ends with `_password` will get an automatically generated value. To have the build script regenerate the `_password` values with a new build, delete the `.passwords_generated` file before re-running the build script._

### General Build Variables

<dl>
  <dt>server_admin_email</dt>
  <dd>The email address that should be configured as the Apache admin and as the graphiteAdmin user's email address.</dd>
  <dt>packer_build_name</dt>
  <dd>A name that will distinguish your build products from someone else's. It can be a simple string like "fedora" or "ucla".</dd>
  <dt>graphite_admin_password</dt>
  <dd>The password for the graphiteAdmin user. If not supplied, the build.sh script will supply an automatically generated password in the graphite.json file each time the build.sh script is run.</dd>
  <dt>graphite_secret_key_password</dt>
  <dd>Not really a password, but a secret key for the Graphite installation. If not supplied, the build.sh script will supply an automatically generated value in the graphite.json file each time the build.sh script is run.</dd>
</dl>

### Amazon-EBS Variables

<dl>
  <dt>aws_access_key</dt>
  <dd>A valid AWS_ACCESS_KEY that will be used to interact with Amazon Web Services (AWS).</dd>
  <dt>aws_secret_key</dt>
  <dd>The AWS_SECRET_KEY that corresponds to the supplied AWS_ACCESS_KEY.</dd>
  <dt>aws_security_group_id</dt>
  <dd>A pre-configured AWS Security Group that will allow SSH and HTTP access to the EC2 build.</dd>
  <dt>aws_region</dt>
  <dd>The AWS region to use. For instance: <span style="font-weight: bold">us-east-1</span> or <span style="font-weight: bold">us-west-2a</span>.</dd>
  <dt>aws_instance_type</dt>
  <dd>The AWS instance type to use. For instance: <span style="font-weight: bold">t2.small</span> or <span style="font-weight: bold">t2.medium</span>.</dd>
  <dt>aws_virtualization_type</dt>
  <dd>The AWS virtualization type to use. For instance: <span style="font-weight: bold">hvm</span> or <span style="font-weight: bold">pv</span>.</dd>
  <dt>aws_source_ami</dt>
  <dd>The source AWS AMI to use to as a base. Make sure the source AMI and virtualization type are compatible.</dd>
  <dt>default_ssh_user</dt>
  <dd>The default SSH user to use for the EC2 image (Ubuntu uses 'ubuntu' and CentOS / RHEL uses 'ec2-user').</dd>
</dl>

## Deployment

How you deploy the Graphite server will depend on which builder you've selected (at the moment only the Amazon-EBS builder is supported).

To deploy an AWS AMI image, you'll need to launch a new EC2 instance using the Packer.io generated AMI (selecting an instance type, security group, and key pair in the process).  These steps might be automated in the future with the assistance of the AWS CLI.

## License

[Apache Software License, version 2.0](LICENSE)

## Contact

If you have questions about [packer-graphite](http://github.com/ksclarke/packer-graphite) feel free to ask them on the FreeLibrary Projects [mailing list](https://groups.google.com/forum/#!forum/freelibrary-projects); or, if you encounter a problem, please feel free to [open an issue](https://github.com/ksclarke/packer-graphite/issues "GitHub Issue Queue") in the project's issue queue.
