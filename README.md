# Packer Graphite

A Packer.io build for Graphite.  [Packer.io](http://www.packer.io/) is a tool for creating identical machine images for multiple platforms from a single source configuration.  It supports build products for Amazon EC2, Digital Ocean, Docker, VirtualBox, VMWare, and others.  [Graphite](https://graphite.readthedocs.org/en/latest/) is an enterprise-scale monitoring (and graphing) tool that runs well on cheap hardware. 

## Introduction

Usually a [Packer.io build](http://www.packer.io/docs/command-line/build.html) would be run with something like:

    packer build -only=amazon-ebs -var-file=vars.json graphite.json

But this project includes a wrapper script to automate some of the related build processes. To run it, type:

    ./build.sh

or

    ./build.sh amazon-ebs

This will include the variables file and strip the comments out of packer-graphite.json, creating the graphite.json file. Right now, only the EC2 AMI is generated but, in the future, supplying the builder (e.g. "amazon-ebs", "virtualbox-iso", etc.) will configure the process to only use that builder.

_Note: To have the build script use the packer-graphite.json file, you'll need to have [strip-json-comments](https://github.com/sindresorhus/strip-json-comments) installed.  If you don't have that installed, the build script will use the pre-generated graphite.json file. Any changes meant to persist between builds should be made to the packer-graphite.json file._

## Configuration

Before you run the build script, though, you'll need to configure a few important variables.  To get you started, the project has an `example-vars.json` file which can be copied to `vars.json` and edited.  The build script will then inject these variables into the build.  There are some variables that are general and some that are specific to a particular builder (which will only need to be supplied if you intend to use that builder).

_Note: When running the build script, any variable in the vars.json file that ends with `_password` will get an automatically generated value. To have the build script regenerate the `_password` values with a new build, delete the `.passwords` file before re-running the build script._

### General Build Variables

<dl>
  <dt>server_admin_email</dt>
  <dd>The email address that should be configured as the Apache admin and as the graphiteAdmin user's email address.</dd>
  <dt>packer_build_name</dt>
  <dd>A name that will distinguish your build products from someone else's. It can be a simple string like "fedora" or "ucla".</dd>
  <dt>graphite_admin_password</dt>
  <dd>The password for the graphiteAdmin user. If not supplied, the build.sh script will supply an automatically generated password in the graphite.json file.</dd>
  <dt>graphite_secret_key_password</dt>
  <dd>Not really a password, but a secret key for the Graphite installation. If not supplied, the build.sh script will supply an automatically generated value in the graphite.json file.</dd>
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
  <dd>The AWS region to use. For instance: <span style="font-weight: bold">us-east-1</span> or <span style="font-weight: bold">us-west-2</span>.</dd>
  <dt>aws_instance_type</dt>
  <dd>The AWS instance type to use. For instance: <span style="font-weight: bold">t2.medium</span> or <span style="font-weight: bold">m3.medium</span>.</dd>
  <dt>aws_virtualization_type</dt>
  <dd>The AWS virtualization type to use. For instance: <span style="font-weight: bold">hvm</span> or <span style="font-weight: bold">pv</span>.</dd>
  <dt>aws_source_ami</dt>
  <dd>The source AMI to use as a base. Note that the source AMI, virtualization type, and instance type must be <a href="http://aws.amazon.com/amazon-linux-ami/instance-type-matrix/">compatible</a>. The two tested AMIs (from 'us-east-1') are <span style="font-weight: bold">ami-0870c460</span> (with 'pv' virtualization) and <span style="font-weight: bold">ami-0070c468</span> (with 'hvm' virtualization). If you select another, make sure it's an Ubuntu image (as that's what the Packer.io build expects).</dd>
</dl>

## Deployment

How you deploy the Graphite server will depend on which builder you've selected (at the moment only the Amazon-EBS builder is supported).

**To deploy a Packer.io generated AWS AMI image:**

1. Login into the AWS console and go to the [AMI image page](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:)
2. Select the newly created AMI image (named "fcrepo4-graphite-[TIMESTAMP]" if you didn't change the `packer_build_name` variable)
3. Click the _Launch_ button at the top of the screen
4. Select the Instance Type you want to launch with (for instance: "m1.small", "m3.medium", etc.)
5. Click _Review and Launch_
6. Select the security group you want to use by clicking the _Edit Security Groups_ link
7. Click _Review and Launch_
8. Review the launch summary page
9. Click _Launch_
10. Select an existing key pair or create a new key pair that can be used to login to the Graphite server
11. Click _Launch Instances_ to launch your Graphite server

Once this is done, you'll have a Graphite server running in the AWS cloud.

To connect Fedora 4 to it, first click the AWS "instance ID" link to learn the public IP address that has been assigned to the machine.  Once you've done that, you can clone the fcrepo4 GitHub repo and start Fedora 4 with its metrics directed to your Graphite server:

    git clone https://github.com/fcrepo4/fcrepo4.git
    cd fcrepo4/fcrepo-webapp
    MAVEN_OPTS="-Xmx512m -Dspring.profiles.active=metrics.graphite -Dfcrepo.metrics.host=[AWS_IP_ADDRESS] -Dfcrepo.metrics.port=2003" mvn jetty:run

You can then open the Graphite web interface in your browser (at the AWS_IP_ADDRESS your Graphite server uses) and browse through the Graphite metrics tree.

## License

[Apache Software License, version 2.0](LICENSE)
