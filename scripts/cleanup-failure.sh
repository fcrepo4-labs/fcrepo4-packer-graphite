#! /bin/bash

# Fail on a non-zero exit code (leaving user to cleanup)
set -e

#
# Checks to see whether any temporary instances are still hanging around
#
INSTANCES=`aws ec2 describe-instances --region ${AWS_REGION} --filters Name=owner-id,Values=${AWS_OWNER_ID} Name=instance-state-name,Values=running Name=key-name,Values=packer* | grep INSTANCES | cut -f 8`

for INSTANCE in $INSTANCES
do
  echo "Cleaning up Packer created temporary instance: $INSTANCE"
  aws ec2 terminate-instances --instance-ids $INSTANCE
done
