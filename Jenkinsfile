def buildAndPushImage(String imageName, String dockerBuildOptions) {
    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
    def dockerImage = docker.build(imageName, dockerBuildOptions)
    dockerImage.push()
    }
}
 
def getReleaseVersion(String tagName) {
    if (tagName) {
        return tagName.replaceAll(/^v/, '')
    } else {
        return null
    }
}
 
pipeline {
 
    agent {
        node { label 'jenkinsworker00' }
    }
    
    environment {
        HARBOR_CREDENTIALS = 'harbor-paas-credentials'
        JHUB_IMAGE_NAME = 'datacloud-templates/snj-base-jhub'
        BASE_LAB_IMAGE_NAME = 'datacloud-templates/snj-base-lab'
        BASE_LAB_GPU_IMAGE_NAME = 'datacloud-templates/snj-base-lab-gpu'
        LAB_PERSISTENCE_IMAGE_NAME = 'datacloud-templates/snj-base-lab-persistence'
        LAB_COLLABORATIVE_IMAGE_NAME = 'datacloud-templates/snj-base-labc'
        LAB_COLLABORATIVE_GPU_IMAGE_NAME = 'datacloud-templates/snj-base-jlabc-gpu'
        COLLABORATIVE_PROXY_IMAGE_NAME = 'datacloud-templates/snj-base-jlabc-proxy'
        NOTEBOOK_IMAGE_NAME = 'datacloud-templates/snj-base-notebook'
        ML_INFN_BASE_LAB_IMAGE_NAME = 'datacloud-templates/ml-infn-lab'
        ML_INFN_LAB_COLLABORATIVE_IMAGE_NAME = 'datacloud-templates/ml-infn-jlabc'
        BASE_LAB_CC7_IMAGE_NAME = 'datacloud-templates/snj-base-lab-cc7'
        CYGNO_LAB_IMAGE_NAME = 'datacloud-templates/cygno-lab'
        CYGNO_LAB_WN_IMAGE_NAME = 'datacloud-templates/cygno-lab-wn'
        JUP_MATLAB_IMAGE_NAME = 'datacloud-templates/jupyter_matlab'
        COLL_MATLAB_IMAGE_NAME = 'datacloud-templates/collaborative_matlab'
        PARAL_MATLAB_IMAGE_NAME = 'datacloud-templates/jupyter_matlab_parallel'
        JAAS_USER_IMAGE_NAME = 'datacloud-templates/jaas_user_containers'
        NAAS_MATLAB_IMAGE_NAME = 'datacloud-templates/naas_matlab'
        NAAS_PARALLEL_IMAGE_NAME = 'datacloud-templates/naas_matlab_parallel'
        SPARK_IMAGE_NAME = 'datacloud-templates/spark'
        JHUB_SPARK_IMAGE_NAME = 'datacloud-templates/jhub-spark'
        TAG_NAME = "test"
        RELEASE_VERSION = getReleaseVersion(TAG_NAME)
        SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        stage('Build and Push JHUB Image') {
            environment {
                IMAGE_NAME = "${JHUB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/jupyterhub/Dockerfile docker/single-node-jupyterhub/jupyterhub"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
        
        stage('Build and Push Base Lab Image') {
            environment {
                IMAGE_NAME = "${BASE_LAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/lab/Dockerfile docker/single-node-jupyterhub/lab"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
 
        stage('Build and Push Persistence Image') {
            environment {
                IMAGE_NAME = "${LAB_PERSISTENCE_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_LAB_IMAGE_NAME}:${env.RELEASE_VERSION} --no-cache -f docker/single-node-jupyterhub/lab/base-persistence/Dockerfile docker/single-node-jupyterhub/lab/base-persistence"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Collaborative Image') {
            environment {
                IMAGE_NAME = "${LAB_COLLABORATIVE_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_LAB_IMAGE_NAME}:${env.RELEASE_VERSION} --no-cache -f docker/single-node-jupyterhub/jupyterlab-collaborative/Dockerfile docker/single-node-jupyterhub/jupyterlab-collaborative"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        // stage('Build and Push Collaborative Proxy Image') {
        //     environment {
        //         IMAGE_NAME = "${COLLABORATIVE_PROXY_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/jupyterlab-collaborative-proxy/Dockerfile docker/single-node-jupyterhub/jupyterlab-collaborative-proxy"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push Notebook Image') {
        //     environment {
        //         IMAGE_NAME = "${NOTEBOOK_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/notebook/Dockerfile docker/single-node-jupyterhub/notebook"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        stage('Build and Push Lab GPU Image') {
            environment {
                IMAGE_NAME = "${BASE_LAB_GPU_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/lab/Dockerfile.gpu docker/single-node-jupyterhub/lab"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Collaborative GPU Image') {
            environment {
                IMAGE_NAME = "${LAB_COLLABORATIVE_GPU_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/jupyterlab-collaborative/Dockerfile.gpu docker/single-node-jupyterhub/jupyterlab-collaborative"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push ML_INFN Image') {
            environment {
                IMAGE_NAME = "${ML_INFN_BASE_LAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_LAB_GPU_IMAGE_NAME}:${env.RELEASE_VERSION} --no-cache -f docker/ML-INFN/lab/Dockerfile docker/ML-INFN/lab"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push ML INFN Collaborative Image') {
            environment {
                IMAGE_NAME = "${ML_INFN_LAB_COLLABORATIVE_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${LAB_COLLABORATIVE_GPU_IMAGE_NAME}:${env.RELEASE_VERSION} --no-cache -f docker/ML-INFN/jupyterlab-collaborative/Dockerfile docker/ML-INFN/jupyterlab-collaborative"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        // stage('Build and Push Base Lab CC7 Image') {
        //     environment {
        //         IMAGE_NAME = "${BASE_LAB_CC7_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f docker/single-node-jupyterhub/lab/Dockerfile.cc7 docker/single-node-jupyterhub/lab"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push Cygno Image') {
        //     environment {
        //         IMAGE_NAME = "${CYGNO_LAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${BASE_LAB_CC7_IMAGE_NAME}:${env.RELEASE_VERSION} --no-cache -f docker/CYGNO/lab/Dockerfile docker/CYGNO"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }
        
        // stage('Build and Push Cygno WN Image') {
        //     environment {
        //         IMAGE_NAME = "${CYGNO_LAB_WN_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--no-cache -f docker/CYGNO/wn/Dockerfile docker/CYGNO"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }
 
        stage('Build and Push Jupyter Matlab Image') {
            environment {
                IMAGE_NAME = "${JUP_MATLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${LAB_PERSISTENCE_IMAGE_NAME}:${env.RELEASE_VERSION} --build-arg MATLAB_RELEASE=r2023b --build-arg MATLAB_PRODUCT_LIST='MATLAB' --build-arg LICENSE_SERVER='' --no-cache -f docker/jupyter-matlab/persistence.Dockerfile docker/jupyter-matlab"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Collaboration Matlab Image') {
            environment {
                IMAGE_NAME = "${COLL_MATLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${LAB_COLLABORATIVE_IMAGE_NAME}:${env.RELEASE_VERSION} --build-arg MATLAB_RELEASE=r2023b --build-arg MATLAB_PRODUCT_LIST='MATLAB' --build-arg LICENSE_SERVER='' --no-cache -f docker/jupyter-matlab/collaborative.Dockerfile docker/jupyter-matlab"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push Parallel Matlab Image') {
            environment {
                IMAGE_NAME = "${PARAL_MATLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${LAB_PERSISTENCE_IMAGE_NAME}:${env.RELEASE_VERSION} --build-arg MATLAB_RELEASE=r2023b --build-arg MATLAB_PRODUCT_LIST='MATLAB MATLAB_Parallel_Server Parallel_Computing_Toolbox' --build-arg LICENSE_SERVER='' --no-cache -f docker/jupyter-matlab-parallel/persistence-parallel.Dockerfile docker/jupyter-matlab-parallel"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push JaaS User Image') {
            environment {
                IMAGE_NAME = "${JAAS_USER_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/naas-matlab/jaas-user-containers/jaas_user_containers.Dockerfile docker/naas-matlab/jaas-user-containers"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        // stage('Build and Push NaaS Matlab Image') {
        //     environment {
        //         IMAGE_NAME = "${NAAS_MATLAB_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${JAAS_USER_IMAGE_NAME}:${env.RELEASE_VERSION} --build-arg MATLAB_RELEASE=r2023b --build-arg MATLAB_PRODUCT_LIST='MATLAB' --build-arg LICENSE_SERVER='' --no-cache -f docker/naas-matlab/naas.Dockerfile docker/naas-matlab"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // }

        // stage('Build and Push NaaS Parallel Matlab Image') {
        //     environment {
        //         IMAGE_NAME = "${NAAS_PARALLEL_IMAGE_NAME}:${env.RELEASE_VERSION}"
        //         DOCKER_BUILD_OPTIONS = "--build-arg BASE_IMAGE=${JAAS_USER_IMAGE_NAME}:${env.RELEASE_VERSION} --build-arg MATLAB_RELEASE=r2023b --build-arg MATLAB_PRODUCT_LIST='MATLAB MATLAB_Parallel_Server Parallel_Computing_Toolbox' --build-arg LICENSE_SERVER='' --no-cache -f docker/naas-matlab-parallel/naas-parallel.Dockerfile docker/naas-matlab-parallel"
        //     }
        //     steps {
        //         script {
        //             buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
        //         }
        //     }
        // } 

        stage('Build and Push Spark Image') {
            environment {
                IMAGE_NAME = "${SPARK_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/spark/Dockerfile docker/spark"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }

        stage('Build and Push JHUB Spark Image') {
            environment {
                IMAGE_NAME = "${JHUB_SPARK_IMAGE_NAME}:${env.RELEASE_VERSION}"
                DOCKER_BUILD_OPTIONS = "--no-cache -f docker/jupyter-hub/Dockerfile docker/jupyter-hub"
            }
            steps {
                script {
                    buildAndPushImage(IMAGE_NAME, DOCKER_BUILD_OPTIONS)
                }
            }
        }
    }
    
    post {
        success { echo 'Docker image build and push successful!' }
        failure { echo 'Docker image build and push failed!' }
    }
}
 