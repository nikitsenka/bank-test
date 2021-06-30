#!/bin/bash -xe
USER=ec2-user

if ! test "$1"
then
	echo Please name test run
	exit
fi

if ! test "$2"
then
	echo Please specify stack name
	exit
fi


IP=$(aws --profile dev cloudformation describe-stacks --stack-name $2 \
	| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicIP") | .OutputValue')

echo Copying test scripts to $USER@$IP
scp bank-test.jmx jmeter.sh $USER@${IP}:

ssh $USER@${IP} curl localhost:80

if test $? != 0
then
	echo Service is not ready to test
	exit
fi

ssh $USER@${IP} /home/$USER/jmeter.sh $1

scp -qr $USER@$IP:/home/$USER/$1 $1

URL=s.natalian.org/$(date -u +%Y-%m-%d)/$1
aws s3 --profile mine sync --quiet --acl public-read $1 s3://$URL
echo https://$URL/index.html
