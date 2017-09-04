#!/usr/bin/env groovy

pipeline {
    agent { label 'docker' }
    stages {
        stage('Prepare') {
            steps {
                sh 'make depends'
            }
        }
        stage('Test') {
            steps {
                sh 'make check'
            }
            post {
                always {
                    archiveArtifacts 'rspec.html'
                }
            }
        }
        stage('Build container') {
            steps {
                sh 'make container'
            }
        }
    }
}
