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
                sh 'mvn clean package -Dcheckstyle.skip=true'
            }
        }
        stage('Run Unit Test') {
            steps{
                sh "mvn test -Dcheckstyle.skip=true"
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('SonarQube Analysis') {
            steps{
                withSonarQubeEnv('sonarqube') {
                    sh "mvn clean verify -Dcheckstyle.skip=true sonar:sonar -Dsonar.projectKey=petclinic-pipeline -Dsonar.projectName='petclinic-pipeline' -Dsonar.host.url=http://sonarqube:9000 -Dsonar.token=sqp_70c7f627d541990c129b7f95cc965a1d14f51ca3"
                }
            }
        }
//        stage('Snyk Security Scan') {
//            steps{
//                echo "Scanning the application for security smells..."
//                snykSecurity(
//                    snykInstallation: 'snyk@latest',
//                    snykTokenId: 'snyk-api-token',
//                )
//            }
//        }
        stage('Build docker image'){
            steps{
                script{
                    echo "building the docker image..."
                    sh 'docker build -t malekinsat/pet-clinic:latest .'
                }
            }
        }
        stage('Push image to Docker Hub'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'malek-dockerhub', passwordVariable: 'pass', usernameVariable: 'username')]) {
                        sh 'docker login -u ${username} -p ${pass}'
                        sh 'docker push malekinsat/pet-clinic:latest'
                    }
                }
            }
        }
        stage('Deploying App to Kubernetes') {
            steps {
                script {
                    echo 'deploying the application to Kubernetes'
                    sshagent(['k8s']) {
                        //we need SSH into the actual machine running the master node of the cluster
                        // will copy our deployment.yml file into the kubernetes cluster
                        sh "scp -o StrictHostKeyChecking=no app-deployment.yml Malek@https://127.0.0.1:60610:/home"
                        script {
                            try{
                                sh "ssh Malek@https://127.0.0.1:60610 kubectl apply -f ."
                            }catch(error){
                                sh "ssh Malek@https://127.0.0.1:60610 kubectl create -f ."
                            }
                        }
                    }
            }
        }
    }
    post{
        always {
            sh 'docker logout'
        }
    }
}
