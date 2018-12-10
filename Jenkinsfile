def AWS_REGION = 'us-west-1'
def AWS_CRED_NAME = 'aws-credentials'
def BUILD_DATE = new Date(currentBuild.startTimeInMillis).format("yyyy-MM-dd-HH-mm")
def AMI_IMAGE_ID

pipeline {
  agent any
  stages {
    stage('Validate Packer and Terraform configs') {
      when {
          branch 'master'
      }
      steps {
        script {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${AWS_CRED_NAME}",
            accessKeyVariable: 'AWS_ACCESS_KEY',
            secretKeyVariable: 'AWS_SECRET_KEY'
        ]]) {
                sh "packer validate packer/ami-build.json"
                sh "cd terraform && terraform init"
            }
        }
      }
    }
    stage('Build Packer image') {
      when {
          branch 'master'
      }
      steps {
        script {
          withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: "${AWS_CRED_NAME}",
              accessKeyVariable: 'AWS_ACCESS_KEY',
              secretKeyVariable: 'AWS_SECRET_KEY'
          ]]) {
              sh(
                script: """
                /usr/bin/packer build -var 'ami_uniq_id=${BUILD_DATE}' \
                                  -var 'aws_access_key=${AWS_ACCESS_KEY}' \
                                  -var 'aws_secret_key=${AWS_SECRET_KEY}' \
                                  -machine-readable packer/ami-build.json | tee build.log
                """)
              AMI_IMAGE_ID = sh(
                script: """
                  grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2
                """,
                returnStdout: true).trim()
          }
        }
      }
    }
    stage('Deploy Infrastructure') {
      when {
          branch 'master'
      }
      steps {
        script {
          withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: "${AWS_CRED_NAME}",
              accessKeyVariable: 'AWS_ACCESS_KEY',
              secretKeyVariable: 'AWS_SECRET_KEY'
          ]]) {
          sh """
            cd terraform
            terraform init
            terraform plan -var 'ami_image_id=${AMI_IMAGE_ID}' -var 'aws_access_key=${AWS_ACCESS_KEY}' -var 'aws_secret_key=${AWS_SECRET_KEY}'
            terraform apply -auto-approve \
                              -var 'ami_image_id=${AMI_IMAGE_ID}' \
                              -var 'aws_access_key=${AWS_ACCESS_KEY}' \
                              -var 'aws_secret_key=${AWS_SECRET_KEY}'
          """
          }
        }
      }
    }
  }
  post {
    always {
      deleteDir()
    }
  }
}