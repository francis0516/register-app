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

             stage('Generate Maven Project') {
                       steps {
                            sh '''
                    mvn archetype:generate -DgroupId=com.example \
                    -DartifactId=.. \
                    -DarchetypeArtifactId=maven-archetype-quickstart \
                    -DinteractiveMode=false
                '''
                       }
             }
                   
             stage("Build Application"){
                      steps {
                           dir('register-app-ci') {
                              sh "mvn clean package"
                           }         
                      }
             }
 
             stage("Test Application"){
                      steps {
                           sh "mvn test"
                      }
             }
         }
}
