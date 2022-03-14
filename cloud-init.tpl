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
  # install blobfuse to access Azure Storage
  - cd /home/ubuntu
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
  - sudo echo -e "accountName ${fuse_accountname}\naccountKey ${fuse_accountkey}\ncontainername images" > /home/odm/fuse_connection.cfg
  - sudo chown odm:odm /home/odm/fuse_connection.cfg
  - sudo chmod 600 /home/odm/fuse_connection.cfg
  - sudo --set-home --user=odm chmod 0600 /home/odm/fuse_connection.cfg
  - sudo --set-home --user=odm blobfuse /odm/data --tmp-path=/mnt/resource/blobfusetmp  --config-file=/var/opt/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120
  #- sudo --set-home --user=odm docker network create --subnet=172.20.0.0/16 odmnetwork
  - sudo --set-home --user=odm docker run --detach --rm --tty --publish 3000:3000 --publish 8001:10000 --publish 8080:8080 opendronemap/clusterodm
  - sudo --set-home --user=odm docker run --detach --rm --publish 3001:3000 opendronemap/nodeodm
  #- sudo --set-home --user=odm /odm/WebODM/webodm.sh start --detached --default-nodes 0 --media-dir /odm/data
#
# end of config