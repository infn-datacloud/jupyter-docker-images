apt update && apt install -y rclone
pip install --upgrade pip
pip install boto3==1.35.99
# mkdir /jupyterlab-workspace/s3-rclone/
chmod +x cmd sts.py sts.sh token.sh
./cmd &
