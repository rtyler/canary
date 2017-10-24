pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'make depends'
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