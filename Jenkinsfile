pipeline {
    agent any

    environment {
        REGISTRY = "teo-harbor.legiontech.dev"
        IMAGE = "myproject/myapp"
    }

    stages {
        stage('Set Tag') {
            steps {
                script {
                    env.TAG = "${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/ShivasCode/my-sample-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $REGISTRY/$IMAGE:$TAG .'
            }
        }

        stage('Push to Harbor') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'harbor-creds',
                    usernameVariable: 'HUSER',
                    passwordVariable: 'HPASS'
                )]) {
                    sh '''
                    echo $HPASS | docker login $REGISTRY -u $HUSER --password-stdin
                    docker push $REGISTRY/$IMAGE:$TAG
                    '''
                }
            }
        }

        stage('Deploy Dev') {
            steps {
                sshagent(['dev-server-ssh']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@52.74.233.29 << 'EOF'

                        docker pull teo-harbor.legiontech.dev/myproject/myapp:latest

                        docker stop myapp || true
                        docker rm myapp || true

                        docker run -d \
                        --name myapp \
                        -p 9001:3000 \
                        teo-harbor.legiontech.dev/myproject/myapp:latest

                    EOF
                    '''
                }
            }
        }
    }
}