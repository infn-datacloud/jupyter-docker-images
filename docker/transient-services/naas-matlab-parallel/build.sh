docker build --no-cache \
             --build-arg MATLAB_RELEASE=r2023b \
             --build-arg MATLAB_PRODUCT_LIST="MATLAB MATLAB_Parallel_Server Parallel_Computing_Toolbox" \
             --build-arg LICENSE_SERVER="" \
             -f naas-parallel.Dockerfile \
             -t harbor.cloud.infn.it/datacloud-templates/naas_matlab_parallel:1.2.0 .
