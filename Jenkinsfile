pipeline {
    agent any
    tools{
        maven 'maven_3.9.5'
    }
    stages{
        stage('Build Artifact'){
            steps{
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/MalekChINSAT/petclinic']]])
                echo "building the application..."
                sh 'mvn clean package'
            }
        }
        stage('Build docker image'){
            steps{
                script{
                    echo "building the docker image..."
                    sh 'docker build -t malek/pet-clinic:latest .'
                }
            }
        }
        stage('Push image to Docker Hub'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'malek-dockerhub', variable: 'dockerhubpwd')]) {
                        sh 'docker login -u malekinsat -p ${dockerhubpwd}'

                    }
                    sh 'docker push malek/pet-clinic:latest'
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    echo 'deploying the application...'
                }
            }
        }
    }
}
