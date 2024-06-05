docker build --no-cache \
             --build-arg MATLAB_RELEASE=r2023b \
             --build-arg MATLAB_PRODUCT_LIST="MATLAB" \
             --build-arg LICENSE_SERVER="" \
             -f persistence.Dockerfile \
             -t harbor.cloud.infn.it/datacloud-templates/jupyter_matlab:1.2.0 .
