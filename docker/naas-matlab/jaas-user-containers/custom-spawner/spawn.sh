#!/bin/bash

# Configure oidc-agent for user token management
echo "eval \`oidc-keychain\`" >> ~/.bashrc
eval `OIDC_CONFIG_DIR=$HOME/.config/oidc-agent oidc-keychain`
oidc-gen infncloud --issuer $IAM_SERVER \
 --client-id $IAM_CLIENT_ID \
 --client-secret $IAM_CLIENT_SECRET \
 --rt $REFRESH_TOKEN \
 --audience=object \
 --confirm-yes \
 --scope "openid profile email" \
 --redirect-uri http://localhost:8843 \
 --pw-cmd "echo \"DUMMY PWD\""

kill `ps faux | grep "sts-wire ${USERNAME}" | awk '{ print $2 }'`
kill `ps faux | grep ".${USERNAME}" | awk '{ print $2 }'`
kill `ps faux | grep "sts-wire scratch" | awk '{ print $2 }'`
kill `ps faux | grep ".scratch" | awk '{ print $2 }'`

mkdir -p /s3/${USERNAME}
mkdir -p /s3/scratch
mkdir -p /opt/user_data/cache/${USERNAME}
mkdir -p /opt/user_data/cache/scratch

cd /.init/

./sts-wire https://iam.cloud.infn.it/  ${USERNAME} https://rgw.cloud.infn.it/ IAMaccess object /${USERNAME} ../s3/${USERNAME}  \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "/opt/user_data/cache/${USERNAME}" > .mount_log_${USERNAME}.txt &

./sts-wire https://iam.cloud.infn.it/ scratch https://rgw.cloud.infn.it/ IAMaccess object  /scratch ../s3/scratch  \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "/opt/user_data/cache/scratch" > .mount_log_scratch.txt &
