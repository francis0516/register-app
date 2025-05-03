pipeline {
         agent { label 'Jenkins-Agent' }
         tools {
            jdk 'Java17'
            maven 'Maven3'
         }

         environment {
                    APP_NAME = "register-app-pipeline"
                    RELEASE = "1.0.0"
                    DOCKER_USER =  "francis0516"
                    DOCKER_PASS = 'dockerhub'
                    IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
                    IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
         }

         stages {
             stage("Cleanup Workspace"){
                      steps {
                      cleanWs()
                      }
             }

             stage("Checkout from SCM"){
                      steps {
                           git branch: 'main', credentialsId: 'github', url: 'https://github.com/francis0516/register-app'
                      }
             }

             stage('Generate pom.xml') {
                      steps {
                           writeFile file: 'pom.xml', text: '''
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0-SNAPSHOT</version>
</project>
'''
                      }
             }

             stage("Build Application"){
                      steps {
                           sh "mvn clean package"      
                      }
             }
 
             stage("Test Application"){
                      steps {
                           sh "mvn test"
                      }
             }

             stage("SonarQube Analysis"){
                      steps {
                           script {
                                 withSonarQubeEnv(credentialId: 'jenkins-sonarqube-token') {
                                 sh "mvn sonar:sonar"
                                 }
                           }
                      }
             }

             stage("Quality Gates"){
                      steps {
                           script {
                                 waitForQualityGate abortPipeline: false, credentailsId: 'jenkins-sonarqube-token'
                           }
                      }
             }

             stage("Build and Push Docker Image"){
                      steps {
                           script {
                                 docker.withRegistry('',DOCKER_PASS) {
                                      docker_image = docker.build "${IMAGE_NAME}"
                                 }

                                 docker.withRegistry('',DOCKER_PASS) {
                                      docker_image.push("${IMAGE_TAG}")
                                      docker_image.push('latest')
                                 }
                           }
                      }
             }

             stage("Trivy Scan") {
                       steps {
                            script {
	                         sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image francis0516/register-app-pipeline:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')
                            }
                       }
             }

             stage ('Cleanup Artifacts') {
                       steps {
                            script {
                                  sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                                  sh "docker rmi ${IMAGE_NAME}:latest"
                            }
                       }
             }     
         }
}
