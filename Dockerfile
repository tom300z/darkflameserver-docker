FROM ubuntu

# Install required packages
RUN apt-get update
RUN apt-get -y install mysql-client

# Install build packages
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y gcc cmake git make g++ zlib1g-dev python3 python3-pip sqlite
RUN pip3 install git+https://github.com/lcdr/utils

# Build the DLU Server
RUN git clone --recursive https://github.com/DarkflameUniverse/DarkflameServer.git
RUN mkdir -p /server; 
WORKDIR /server
RUN cmake /DarkflameServer/
RUN make -j$(grep -c '^processor' /proc/cpuinfo)

# Copy client files&dirs into the container (need to be in client-files/ dir next to Dockerfile)
COPY client-files/ ./

# Copy aside database initialization scripts for automatic database initialization
RUN cp -r /DarkflameServer/migrations/dlu /db-init


# Set up CDServer DB
RUN python3 -m utils.fdb_to_sqlite res/cdclient.fdb --sqlite_path res/CDServer.sqlite
RUN for file in /DarkflameServer/migrations/cdserver/*; do cat $file | sqlite3 res/CDServer.sqlite ; done
RUN rm -f res/cdclient.fdb

# Clean up the image
RUN apt-get -y remove zlib1g-dev python3 python3-pip sqlite gcc cmake git make g++
RUN apt-get -y autoremove
RUN rm -rdf /DarkflameServer

# Create the default config files and link to the config folder. start.sh will copy the default configs to the config folder if they don't exist already
RUN mkdir /config
RUN mkdir /default-config
RUN mv *.ini  /default-config/
RUN for file in /default-config/*.ini; do ln -s /config/$(basename $file) . ; done
# Disable unnecessary sudo auth 
RUN sed -i "s/use_sudo_auth.*/use_sudo_auth=0/g" /default-config/masterconfig.ini

# Set default env vars
ENV MYSQL_DATABASE=luniserver_net

RUN mkdir -p /server/logs

# Set the start script as entrypoint
COPY start.sh start.sh
ENTRYPOINT [ "/bin/bash", "/server/start.sh" ]

