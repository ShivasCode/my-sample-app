pipeline {
    agent any

    environment {
        REGISTRY = "teo-harbor.legiontech.dev"
        IMAGE = "myproject/myapp"
    }

    stages {
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
                    docker push $REGISTRY/$IMAGE:latest
                    '''
                }
            }
        }
    }
}