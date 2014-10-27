#! /bin/bash

# Fail on a non-zero exit code (leaving user to cleanup)
set -e

#
# Cleanup script used by Travis, not the packer-graphite build
#
AMIS=`aws ec2 describe-images --region ${AWS_REGION} --filters Name=owner-id,Values=${AWS_OWNER_ID} Name=name,Values=${PACKER_GRAPHITE_BUILD_NAME}* | grep IMAGE | cut -f 5`
SNAPSHOTS=`aws ec2 describe-images --region ${AWS_REGION} --filters Name=owner-id,Values=${AWS_OWNER_ID} Name=name,Values=${PACKER_GRAPHITE_BUILD_NAME}* | grep snap- | cut -f 4`
INSTANCE=`cat ec2.instance`

for AMI in $AMIS
do
  echo "Deregistering Travis AMI image: $AMI"
  aws ec2 deregister-image --image-id $AMI
done

for SNAPSHOT in $SNAPSHOTS
do
  echo "Deleting Travis image snapshot: $SNAPSHOT"
  aws ec2 delete-snapshot --snapshot-id $SNAPSHOT
done

echo "Deleting Travis test instance: $INSTANCE"
aws ec2 stop-instances --instance-ids $INSTANCE
aws ec2 terminate-instances --instance-ids $INSTANCE
