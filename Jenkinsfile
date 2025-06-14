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
		    JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
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
	                         sh ('trivy image docker.io/francis0516/register-app-pipeline:latest --format table --severity HIGH,CRITICAL')
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

             stage("Trigger CD Pipeline") {
                   steps {
                       script {
                            sh "curl -v -k --user clouduser:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' '10.0.0.44:8080/job/gitops-register-app-cd/buildWithParameters?token=gitops-token'"
                       }
                   }
             }		 
         }

	 post {
            failure {
                  emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                           subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Failed", 
                           mimeType: 'text/html',to: "henogez@gmail.com"
            }
            success {
                  emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                           subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Successful", 
                           mimeType: 'text/html',to: "henogez@gmail.com"
            }      
         }
}
