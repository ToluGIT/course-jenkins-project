#!/bin/bash

# Step 1: Create the application directory if it doesn't exist
echo "Creating the app directory..."
mkdir -p /home/ec2-user/app

# Step 2: Create flask.service on the EC2 instance
echo "Creating the flask.service file..."
sudo tee /usr/lib/systemd/system/flask.service > /dev/null <<EOL
[Unit]
Description=flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/app/
Environment="PATH=/home/ec2-user/app/venv/bin"
ExecStart=/home/ec2-user/app/venv/bin/python3 /home/ec2-user/app/app.py

[Install]
WantedBy=multi-user.target
EOL

# Step 3: Reload systemd, enable and start the flask service
echo "Reloading systemd and starting the flask service..."
sudo systemctl daemon-reload
sudo systemctl enable flask.service
sudo systemctl start flask.service

# Step 4: Unzip the uploaded code into the application directory
echo "Unzipping the application code..."
unzip -o /home/ec2-user/myapp.zip -d /home/ec2-user/app/

# Step 5: Navigate to the application directory
cd /home/ec2-user/app

# Step 6: Create a virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Step 7: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 8: Install required dependencies
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Step 9: Restart the Flask service after deployment
echo "Restarting the Flask service..."
sudo systemctl restart flask.service

# Step 10: Print completion message
echo "Deployment completed successfully."
