pipeline {
    agent {
        node { label 'jenkinsworker00' }
    }
    
    environment {
        
        HARBOR_CREDENTIALS = 'harbor-paas-credentials'
        BASE_LAB_IMAGE_NAME = 'datacloud-templates/snj-base-lab'
        BASE_LAB_PERSISTENCE_IMAGE_NAME = 'datacloud-templates/snj-base-lab'
    }
    
    stages {
        stage('Build snj-base-lab') {
            
            steps {
                script {
                    // Build Docker image
                    def dockerImage = docker.build("${BASE_LAB_IMAGE_NAME}:${env.BRANCH_NAME}", "-f docker/single-node-jupyterhub/lab/Dockerfile .")
                }
            }
        }

        stage('Build snj-base-lab') {
            
            steps {
                script {
                    // Build Docker image
                    def dockerImage = docker.build("${BASE_LAB_PERSISTENCE_IMAGE_NAME}:${env.BRANCH_NAME}", "--build-arg BASE_IMAGE=harbor.cloud.infn.it/${BASE_LAB_IMAGE_NAME}:${env.BRANCH_NAME}",  "-f ./docker/single-node-jupyterhub/lab/base-persistence/Dockerfile .")
                }
            }
        }
 
        
        stage('Push base image to Harbor') {
            steps {
                script {
                    // Retrieve the Docker image object from the previous stage
                    def baseLabImage = docker.image("${BASE_LAB_IMAGE_NAME}:${env.BRANCH_NAME}")
                    
                    // Login to Harbor
                    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
                        // Push the Docker image to Harbor
                        baseLabImage.push()
                    }
                }
            }
        }

        stage('Push derived image to Harbor') {
            steps {
                script {
                    // Retrieve the Docker image object from the previous stage
                    def labImage = docker.image("${BASE_LAB_PERSISTENCE_IMAGE_NAME}:${env.BRANCH_NAME}")
                    
                    // Login to Harbor
                    docker.withRegistry('https://harbor.cloud.infn.it', HARBOR_CREDENTIALS) {
                        // Push the Docker image to Harbor
                        labImage.push()
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
        }
    }
}