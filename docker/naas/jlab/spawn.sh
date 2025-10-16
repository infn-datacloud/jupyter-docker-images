#!/bin/bash

# Configure oidc-agent for user token management
#echo "eval \`oidc-keychain\`" >> ~/.bashrc
#eval `OIDC_CONFIG_DIR=$HOME/.config/oidc-agent oidc-keychain`
#oidc-gen infncloud --issuer $IAM_SERVER \
# --client-id $IAM_CLIENT_ID \
# --client-secret $IAM_CLIENT_SECRET \
# --rt $REFRESH_TOKEN \
# --confirm-yes \
# --scope "openid profile email" \
# --redirect-uri http://localhost:8843 \
# --pw-cmd "echo \"DUMMY PWD\""

# kill `ps faux | grep "sts-wire ${USERNAME}" | awk '{ print $2 }'`
kill `ps faux | grep rclone | grep ".${USERNAME}" | awk '{ print $2 }'`
# kill `ps faux | grep "sts-wire scratch" | awk '{ print $2 }'`
kill `ps faux | grep rclone | grep ".scratch" | awk '{ print $2 }'`

mkdir -p /jupyterlab-workspace/s3/
mkdir -p /jupyterlab-workspace/local/
mkdir -p /jupyterlab-workspace/s3/${USERNAME}
mkdir -p /jupyterlab-workspace/s3/scratch
# mkdir -p /opt/user_data/cache/${USERNAME}
# mkdir -p /opt/user_data/cache/scratch

/jupyterlab-workspace/.init/rclone-cmd.sh

# sleep 1 && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
# 	${USERNAME} https://rgw.cloud.infn.it/ IAMaccess object \
# 	/${USERNAME} /jupyterlab-workspace/s3/${USERNAME}  \
#     --localCache full --tryRemount --noDummyFileCheck \
#     --localCacheDir "/opt/user_data/cache/${USERNAME}" > .mount_log_${USERNAME}.txt &

# sleep 2 && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
# 	scratch https://rgw.cloud.infn.it/ IAMaccess object  \
# 	/scratch /jupyterlab-workspace/s3/scratch  \
#     --localCache full --tryRemount --noDummyFileCheck \
#     --localCacheDir "/opt/user_data/cache/scratch" > .mount_log_scratch.txt &