#cloud-config
#
# package update and upgrade
package_update: true
package_upgrade: true
#
# install packages
packages:
  - docker
  - docker.io
  - docker-compose
#
# users
users:
  - default
  - name: odm
    sudo:  ALL=(ALL) NOPASSWD:ALL
    groups: docker
    ssh_authorized_keys:
      - ${ssh_key}
#
# run commands
runcmd:
  - cd /home/ubuntu
  # install blobfuse to access Azure Storage
  - wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
  - sudo dpkg -i packages-microsoft-prod.deb
  - sudo apt-get update
  - sudo apt-get -y install blobfuse
  # install rclone
  - curl https://rclone.org/install.sh | sudo bash
  - sudo mkdir -p /mnt/resource/blobfusetmp
  - sudo mkdir -p /odm/data
  #- git clone https://github.com/OpenDroneMap/WebODM --config core.autocrlf=input --depth 1 /odm/WebODM
  - sudo chown -R odm:odm /mnt/resource/blobfusetmp
  - sudo chown -R odm:odm /odm
  # create blobfuse connection config file
  - sudo echo -e "accountName ${fuse_accountname}\naccountKey ${fuse_accountkey}\ncontainerName ${container}" > /home/odm/fuse_connection.cfg
  - sudo chown odm:odm /home/odm/fuse_connection.cfg
  - sudo chmod 600 /home/odm/fuse_connection.cfg
  - sudo --set-home --user=odm chmod 0600 /home/odm/fuse_connection.cfg
  # create rclone config file
  - sudo --set-home --user=odm mkdir -p /home/odm/.config/rclone
  - sudo --set-home --user=odm touch /home/odm/.config/rclone/rclone.conf
  - sudo echo -e "[azure-odm]\ntype = azureblob\naccount = ${rclone_azblob_account}\nkey = ${rclone_azblob_key}" >> /home/odm/.config/rclone/rclone.conf
  - sudo echo -e "[GDrive-ckp]\ntype = drive\nclient_id = ${rclone_gdrive_client_id}\nscope = drive\nclient_secret = ${rclone_gdrive_client_secret}
token = {"access_token":"ya29.A0ARrdaM_nCRv0TcnPPB7L9ijHdvoRX8HWf32phhqPxj8GpKj4d-r-AYBhrgjDHfeawKUFR6TcCSlsmQ6aeDybLCL6MOqiSJTT1q9Xf-tTSZK3kJXklF9ORTsm68dJPVQf7oIs_wpCe6u7xG09kzs2MS1f-_Oy","token_type":"Bearer","refresh_token":"1//04o7EG0AKxtzuCgYIARAAGAQSNwF-L9IrK8dAMfhA9DG3bPIZzXXCpgWys7ZfPUp4sragWKA9Fibv61EBh_AvH4uH0ZeWG3g1lDI","expiry":"2022-03-15T15:07:12.158286-05:00"}
team_drive = "
  #- sudo --set-home --user=odm blobfuse /odm/data --tmp-path=/mnt/resource/blobfusetmp  --config-file=/home/odm/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120
  #- sudo --set-home --user=odm docker network create --subnet=172.20.0.0/16 odmnetwork
  - sudo --set-home --user=odm docker run --detach --rm --tty --publish 3000:3000 --publish 8001:10000 --publish 8080:8080 opendronemap/clusterodm
  - sudo --set-home --user=odm docker run --detach --rm --publish 3001:3000 opendronemap/nodeodm
  #- sudo --set-home --user=odm /odm/WebODM/webodm.sh start --detached --default-nodes 0 --media-dir /odm/data
#
# end of config