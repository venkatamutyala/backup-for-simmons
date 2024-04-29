# Use an official Ubuntu runtime as a parent image
FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

#ENV SYNC_USERNAME
#ENV SYNC_PASSWORD

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y curl cifs-utils inetutils-ping
    rm -rf /var/lib/apt/lists/*



#mount.cifs //192.168.6.161/PlexData /mnt/qnap/ -o user=$SYNC_USERNAME,password=$SYNC_PASSWORD,vers=2.1
