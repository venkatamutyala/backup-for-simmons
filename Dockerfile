# Use an official Ubuntu runtime as a parent image
FROM --platform=linux/arm/v7 ubuntu:20.04@sha256:874aca52f79ae5f8258faff03e10ce99ae836f6e7d2df6ecd3da5c1cad3a912b

#ENV SYNC_USERNAME
#ENV SYNC_PASSWORD

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y curl cifs-utils inetutils-ping rsync && \
    rm -rf /var/lib/apt/lists/*


COPY rsync-backup.sh /usr/local/bin/simmons-backup

RUN chmod +x /usr/local/bin/simmons-backup

CMD ["simmons-backup"]
