# Use an official Ubuntu runtime as a parent image
FROM --platform=linux/arm/v7 ubuntu:20.04@sha256:fa17826afb526a9fc7250e0fbcbfd18d03fe7a54849472f86879d8bf562c629e

#ENV SYNC_USERNAME
#ENV SYNC_PASSWORD

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y curl cifs-utils inetutils-ping rsync && \
    rm -rf /var/lib/apt/lists/*


COPY rsync-backup.sh /usr/local/bin/simmons-backup

RUN chmod +x /usr/local/bin/simmons-backup

CMD ["simmons-backup"]
