FROM python:3.11-slim

# install dependencies  
RUN apt-get update && \
    apt-get install -y fuse libfuse2 flac && \
    rm -rf /var/lib/apt/lists/*

# copy the trackfs package
COPY . /app
WORKDIR /app

# install the trackfs package
RUN pip install --upgrade pip && \
    pip install .


# enable non-root users to make FUSE fs non-private
RUN echo "user_allow_other" >> /etc/fuse.conf 

# FUSE requires that the user that mounts the FUSE filesystem
# has an entry in /etc/passwd
# Since we want to allow (and encourage) the usage of docker's
# --user option to run the container as non-root user, 
# and with that don't know the uid of the user at build time
# we can't create the entry for that user at build time
# and also can't use adduser command during runtime as this would
# require root privileges.
# Instead we open /etc/passwd for writing. 
# As /ets/shadow is still protected this should not cause harm,
# even if some attacker finds a way to take over the container

RUN chmod 666 /etc/passwd 

# source directory containing flac+cue files
VOLUME /src

# mount point where to generate the tracks from the flac+cue files
VOLUME /dst

COPY launcher.sh /usr/local/bin/
RUN chmod 555 /usr/local/bin/launcher.sh

ENTRYPOINT ["/usr/local/bin/launcher.sh", "/src", "/dst"]


