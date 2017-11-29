pipeline{
  agent{
    label 'master'
  }
  
  triggers{
    cron('@weekly')
  }
 
  stages{
    stage('Close and delete indices'){
      steps{
        sh 'chmod +x ./elasticsearch-close-delete-indices.sh'
        sh './elasticsearch-close-delete-indices.sh'
      }
    }
  }
 
  post {
    always {
      deleteDir()
    }
  }
}
