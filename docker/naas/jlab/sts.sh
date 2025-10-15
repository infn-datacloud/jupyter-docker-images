#!/bin/bash

cd "$(dirname $0)"

export ACCESS_TOKEN=$(./token.sh)
AWS_CRED="$(./sts.py)"
echo "${AWS_CRED}"
