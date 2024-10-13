pipeline {
    agent any

    environment {
        SERVER_IP = credentials('prod-server-ip')
    }
    stages {
        stage('Setup') {
            steps {
                sh '''
                    cd  02-single-server-deployment/
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }
        stage('verify installation') {
                steps {
                    sh '''
                        cd 02-single-server-deployment/
                        pip freeze
                    '''
                }
        }
        stage('Test') {
                steps {
                    sh '''
                        cd 02-single-server-deployment/
                        echo "test complete"
                        . venv/bin/activate
                        pytest test_app.py
                    '''
                }
        }

        stage('Package code') {
            steps {
                sh '''
                    cd 02-single-server-deployment/
                    zip -r myapp.zip ./* -x '*.git*'
                    ls -lart
                '''
            }
        }

        stage('Deploy to Prod') {
                steps {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'MY_SSH_KEY', usernameVariable: 'username')]) {
                        sh '''
                        # Copy the application zip file and the deployment script to the EC2 instance
                        scp -i $MY_SSH_KEY -o StrictHostKeyChecking=no 02-single-server-deployment/myapp.zip  ${username}@${SERVER_IP}:/home/ec2-user/
                        scp -i $MY_SSH_KEY -o StrictHostKeyChecking=no 02-single-server-deployment/script.sh  ${username}@${SERVER_IP}:/home/ec2-user/

                        # Execute the deployment script on the EC2 instance
                        ssh -i $MY_SSH_KEY -o StrictHostKeyChecking=no ${username}@${SERVER_IP} << EOF
                            chmod +x /home/ec2-user/script.sh
                            /home/ec2-user/script.sh
                        '''
                    }
                }

        }
        
    }
}