pipeline {
    agent any

    environment {
        REGISTRY = "teo-harbor.legiontech.dev"
        IMAGE = "myproject/myapp"
        DEV_SERVER_IP = "52.74.233.29"
    }

    stages {

        stage('Set Tag') {
            steps {
                script {
                    env.TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
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
                sh 'echo "Building $REGISTRY/$IMAGE:$TAG"'
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

                    # optional: also tag latest for convenience
                    docker tag $REGISTRY/$IMAGE:$TAG $REGISTRY/$IMAGE:latest
                    docker push $REGISTRY/$IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy Dev') {
            steps {
                sshagent(['dev-server-ssh']) {
                    withCredentials([usernamePassword(
                        credentialsId: 'harbor-creds',
                        usernameVariable: 'HUSER',
                        passwordVariable: 'HPASS'
                    )]) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@$DEV_SERVER_IP << EOF

                        echo "$HPASS" | docker login teo-harbor.legiontech.dev -u "$HUSER" --password-stdin

                        docker pull teo-harbor.legiontech.dev/myproject/myapp:$TAG

                        docker stop myapp || true
                        docker rm -f myapp || true

                        docker run -d \
                        --name myapp \
                        -p 9001:3000 \
                        teo-harbor.legiontech.dev/myproject/myapp:$TAG

                        EOF
                        '''
                    }
                }
            }
}
    }
}