#! /bin/bash

# Fail on a non-zero exit code (leaving user to cleanup)
set -e

#
# Cleanup script used by Travis, not the packer-graphite build
#
AMI=`cat ec2.ami`
INSTANCE=`cat ec2.instance`
SNAPSHOT=`aws ec2 describe-snapshots --filters Name=owner-id,Values=${AWS_OWNER_ID} Name=description,Values=*${AMI}* | cut -f 6`

echo "Deregistering Travis AMI image: $AMI"
aws ec2 deregister-image --image-id $AMI

echo "Deleting Travis test instance: $INSTANCE"
aws ec2 stop-instances --instance-ids $INSTANCE
aws ec2 terminate-instances --instance-ids $INSTANCE

echo "Deleting Travis image snapshot: $SNAPSHOT"
aws ec2 delete-snapshot --snapshot-id $SNAPSHOT
