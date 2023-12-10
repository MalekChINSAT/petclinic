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
        stage('Run Unit and Integration Tests') {
            steps{
                sh "mvn test -Dcheckstyle.skip=true"
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('Run Load Test') {
            steps{
                jmeter "./src/test/jmeter/petclinic_test_plan.jmx"
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
                    //we need SSH into the actual machine running the master node of the cluster
                    try{
                        sh "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no Malek@192.168.137.78 /usr/local/bin/kubectl apply -f /Users/Malek/app-deployment.yml"
                    }catch(error){
                        // if resource does not exist in the first place
                        sh "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no Malek@192.168.137.78 /usr/local/bin/kubectl create -f /Users/Malek/app-deployment.yml"
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
