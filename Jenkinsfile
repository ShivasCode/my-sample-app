pipeline {
    agent any

    environment {
        REGISTRY = "teo-harbor.legiontech.dev"
        IMAGE = "myproject/myapp"
        TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'staging', url: 'https://github.com/ShivasCode/my-sample-app.git'
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

        stage('Update K8s Manifest') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-creds',
                    usernameVariable: 'GUSER',
                    passwordVariable: 'GPASS'
                )]) {
                    sh '''
                    git config user.email "jenkins@local"
                    git config user.name "jenkins"

                    cd k8s

                    sed -i "s|image:.*|image: $REGISTRY/$IMAGE:$TAG|" deployment.yaml

                    git add deployment.yaml
                    git commit -m "staging: update image to $TAG"
                    git push https://$GUSER:$GPASS@github.com/ShivasCode/my-sample-app.git HEAD:staging
                    '''
                }
            }
        }
    }
}