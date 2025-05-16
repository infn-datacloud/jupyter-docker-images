#!/usr/bin/env bash

source /usr/local/share/dodasts/script/oidc_agent_init.sh

BASE_CACHE_DIR="/usr/local/share/dodasts/sts-wire/cache"

mkdir -p "${BASE_CACHE_DIR}"
mkdir -p /var/log/sts-wire/
mkdir -p /s3/"${USERNAME}"
mkdir -p /s3/scratch
mkdir -p /s3/cygno-analysis
mkdir -p /s3/cygno-sim
mkdir -p /s3/cygno-data

sleep 1s && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
    "${USERNAME}" https://rgw.cloud.infn.it/ IAMaccess object \
    "/${USERNAME}" "/s3/${USERNAME}" \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "${BASE_CACHE_DIR}/${USERNAME}" \
    &>"/var/log/sts-wire/mount_log_${USERNAME}.txt" &
sleep 2s && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
    scratch https://rgw.cloud.infn.it/ IAMaccess object \
    /scratch /s3/scratch \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "${BASE_CACHE_DIR}/scratch" \
    &>/var/log/sts-wire/mount_log_scratch.txt &
sleep 3s && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
    cygno_analysis https://rgw.cloud.infn.it/ IAMaccess object/ \
    /cygno-analysis /s3/cygno-analysis \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "${BASE_CACHE_DIR}/cygno_analysis" \
    &>/var/log/sts-wire/mount_log_cygnoalanysis.txt &
sleep 4s && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
    cygno_sim https://rgw.cloud.infn.it/ IAMaccess object \
    /cygno-sim /s3/cygno-sim \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "${BASE_CACHE_DIR}/cygno_sim" \
    &>/var/log/sts-wire/mount_log_cygnosim.txt &
sleep 5s && nice -n 19 sts-wire https://iam.cloud.infn.it/ \
    cygno_data https://rgw.cloud.infn.it/ IAMaccess object \
    /cygno-data /s3/cygno-data \
    --localCache full --tryRemount --noDummyFileCheck \
    --localCacheDir "${BASE_CACHE_DIR}/cygno_data" \
    &>/var/log/sts-wire/mount_log_cygnodata.txt &

# Start crond
crond
# automatic backup. To be check.
# crontab -l | { cat; echo "* * * * * /bin/rsync -a --delete /jupyter-workspace/private/ /jupyter-workspace/cloud-storage/${USERNAME}/private/${IAM_CLIENT_ID} 2>&1"; } | crontab -
