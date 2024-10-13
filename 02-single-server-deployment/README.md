# Jenkins Project - Custom Pipeline

This repository was forked from the original [KodeKloud Jenkins Project](https://github.com/kodekloudhub/course-jenkins-project). Below is a documentation of the changes made to the Jenkinsfile to adapt it for deploying to an EC2 instance and working with Python environments.

## Changes Made to Jenkinsfile

### 1. **Setting up a Virtual Environment**
   - A `python3 -m venv venv` command was added to create a virtual environment within the deployment directory.
   - The environment is activated with `source venv/bin/activate` to ensure that the required Python packages are installed within the isolated environment.
   - The `requirements.txt` file is used to install dependencies using `pip install -r requirements.txt`.

### 2. **Packaging and Zipping Code for Deployment**
   - The code from the `02-single-server-deployment/` directory is zipped using the command:
     ```bash
     zip -r myapp.zip ./* -x '*.git*'
     ```
   - This step ensures that the relevant project files are bundled for deployment to the EC2 instance.

### 3. **Deploying to EC2 Instance**
   - The Jenkins pipeline uses `scp` to securely copy the zipped package to the EC2 instance:
     ```bash
     scp -i $MY_SSH_KEY -o StrictHostKeyChecking=no myapp.zip ${username}@${SERVER_IP}:/home/ec2-user/
     ```
   - After copying, it connects to the EC2 instance and unzips the package, recreates the virtual environment, and installs the necessary dependencies:
     ```bash
     ssh -i $MY_SSH_KEY -o StrictHostKeyChecking=no ${username}@${SERVER_IP} << EOF
       cd /home/ec2-user/
       unzip -o myapp.zip -d /home/ec2-user/app/
       cd /home/ec2-user/app/

       # Recreate the virtual environment
       rm -rf venv
       python3 -m venv venv
       source venv/bin/activate
       pip install -r requirements.txt
     EOF
     ```

### 4. **Restarting the Flask Service**
   - The `flask.service` is restarted on the EC2 instance after deploying the changes using:
     ```bash
     sudo systemctl restart flask.service
     ```

### 5. **Testing and Verification**
   - The pipeline includes a test stage where `pytest` is run to ensure the application is working as expected:
     ```bash
     pytest
     ```

## Conclusion
These changes streamline the deployment process by using Python virtual environments and ensuring the EC2 instance is properly set up with the required dependencies. The pipeline automates the packaging, deployment, and application restart for continuous integration and deployment.
