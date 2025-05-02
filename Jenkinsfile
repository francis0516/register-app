pipeline {
         agent { label 'Jenkins-Agent' }
         tools {
            jdk 'Java17'
            maven 'Maven3'
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
                                 withForQulaityGate abortPipeline: false, credentailsId: 'jenkins-sonarqube-token'
                           }
                      }
             }              
                  
         }
}
