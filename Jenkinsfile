pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'make depends'
        sh 'ls -lah'
      }
    }
    stage('Test') {
      steps {
        sh 'make check'
      }
    }
    stage('Produce Container') {
      steps {
        sh 'make container'
      }
    }
  }
}