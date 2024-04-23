pipeline {
    agent {
        node { label 'jenkinsworker00' }
    }
    
    environment {
        HARBOR_CREDENTIALS = 'harbor-paas-credentials'
        BASE_LAB_IMAGE_NAME = 'datacloud-templates/snj-base-lab'
        JHUB_IMAGE_NAME = 'datacloud-templates/snj-base-jhub'
        BASE_LAB_PERSISTENCE_IMAGE_NAME = 'datacloud-templates/snj-base-lab-persistence'
        SANITIZED_BRANCH_NAME = env.BRANCH_NAME.replace('/', '_')
    }
    
    stages {
        stage('Build Hub Image') {
            steps {
                script {
                    // Build the base Docker image
                    docker.build("${JHUB_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}", "--no-cache -f docker/single-node-jupyterhub/jupyterhub/Dockerfile docker/single-node-jupyterhub/jupyterhub")
                }
            }
        }
        
        
        stage('Build Base Lab Image') {
            steps {
                script {
                    // Build the base Docker image
                    def baseLabImage = docker.build("${BASE_LAB_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}", "--no-cache -f docker/single-node-jupyterhub/lab/Dockerfile docker/single-node-jupyterhub/lab")
                }
            }
        }

        stage('Build Derived Lab Image') {
            steps {
                script {
                    // Build the derived Docker image using the base image
                    def derivedLabImage = docker.build(
                        "${BASE_LAB_PERSISTENCE_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}",
                        "--build-arg BASE_IMAGE=${BASE_LAB_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME} --no-cache -f docker/single-node-jupyterhub/lab/base-persistence/Dockerfile docker/single-node-jupyterhub/lab/base-persistence"
                    )
                }
            }
        }

        stage('Push Hub Image to Harbor') {
            steps {
                script {
                    def jhubImage = docker.image("${JHUB_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}")
                    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
                        jhubImage.push()
                    }
                }
            }
        }

        stage('Push Base Image to Harbor') {
            steps {
                script {
                    def baseLabImage = docker.image("${BASE_LAB_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}")
                    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
                        baseLabImage.push()
                    }
                }
            }
        }

        stage('Push Derived Image to Harbor') {
            steps {
                script {
                    def derivedLabImage = docker.image("${BASE_LAB_PERSISTENCE_IMAGE_NAME}:${env.SANITIZED_BRANCH_NAME}")
                    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
                        derivedLabImage.push()
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Docker image build and push successful!'
        }
        failure {
            echo 'Docker image build and push failed!'
            // Optionally, you can add a notification or other failure-handling logic here.
        }
    }
}
