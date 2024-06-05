# Image name: snj-base-lab-persistence
ARG BASE_IMAGE="harbor.cloud.infn.it/datacloud-templates/snj-base-lab:1.2.0"

FROM ${BASE_IMAGE}

ARG JUPYTER_ROOT=/jupyter-workspace

COPY post_script.sh /usr/local/share/dodasts/script/
RUN chmod +x /usr/local/share/dodasts/script/post_script.sh

# Link folders
RUN mkdir -p ${JUPYTER_ROOT} \
    && ln -s /s3 ${JUPYTER_ROOT}/cloud-storage \
    && ln -s /shared ${JUPYTER_ROOT}/shared \
    && ln -s /private ${JUPYTER_ROOT}/private

WORKDIR ${JUPYTER_ROOT}
