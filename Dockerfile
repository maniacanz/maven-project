pipeline {
    agent any
	
	tools {
		maven 'LocalMaven'
	}
	
	triggers {
		pollSCM('* * * * *')
	}
	
    stages{
        stage('Build'){
            steps {
                bat 'mvn clean package'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
		stage ('Deployments'){
			parallel {
				stage ('Deploy to staging'){
					steps {
						build job: 'deploy-to-staging'
					}
				}
				
				stage ('Checkstyle'){
					steps {
						build job: 'static-analysis'
					}
				}
			}
		}
    }
}
