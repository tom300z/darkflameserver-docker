# darkflameserver-docker
A Docker Container for the Darkflame LEGO Universe server

## How to build
Because the Darkflame Universe server requires proprietary client files to run, distributing a pre-built image is not possible. The build process is pretty straightforward though.

### Finding a client
For optimal compatibility you will need a game client version 1.10.64 or above.

Hosting a client unfortunately is not allowed but the "nexus2" client from here should work: http://web.archive.org/web/20170706210206/http://luniserver.com/download/

You'll need a torrennt client like [WebTorrent](https://webtorrent.io/desktop/) to download torrents.



### Gather client files
Place your client data in the "client-files" directory

#### Setup resource directory
* In the `build` directory create a `res` directory if it does not already exist.
* Copy over or create symlinks from `macros`, `BrickModels`, `chatplus_en_us.txt`, `names`, and `maps` in your client `res` directory to the server `build/res` directory
* Unzip the navmeshes [here](./resources/navmeshes.zip) and place them in `build/res/maps/navmeshes`

#### Setup locale
* In the `build` directory create a `locale` directory if it does not already exist
* Copy over or create symlinks from `locale.xml` in your client `locale` directory to the `build/locale` directory

Your work directory structure should look like this:
```
Dockerfile
start.sh
client-files/
    locale/
        locale.xml
    res/
        CDServer.sqlite
        chatplus_en_us.txt
        macros/
            ...
        BrickModels/
            ...
        maps/
            navmeshes/
                ...
            ...
...
```
Now build the container using docker and assign it a tag:
```bash
docker build -t darkflameserver .
```
The container should now be ready to use.

## Usage Examples
### Shell (bash)
```bash
# Create a network for the Containers
docker network create -d bridge docker_darkflameserver-net  
# Start a mariadb container
docker run \
  --name darkflameserver-db
  --network docker_darkflameserver-net \
  -v "/host/folder:/var/lib/mysql" \
  -e "MYSQL_ROOT_PASSWORD=MySecretRootPW" \
  mariadb \
  --default-authentication-plugin=mysql_native_password

# Start the DLU Container
docker run \
  --name darkflameserver
  --network docker_darkflameserver-net \
  -v "/host/folder:/config" \ 
  -e "MYSQL_HOST=darkflameserver-db" \
  -e "MYSQL_DATABASE=darkflameserver" \ 
  -e "MYSQL_USERNAME=root" \
  -e "MYSQL_PASSWORD=secret" \
  -t \ 
  darkflameserver-server
```
### Docker compose
```
version: "2.2"
services:
# Darkflame LEGO Universe server
# Database
  darkflameserver-db:
    image: mariadb
    container_name: darkflameserver-db
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "MySecretRootPW"
    volumes:
      -  ${MASS_STORAGE_PATH}/services/luniserver.net/database:/var/lib/mysql
    networks:
      luni-net:
# Server
  darkflameserver:
    image: luni-server
    container_name: darkflameserver
    restart: always
    tty: true
    stop_grace_period: 2s
    depends_on:
      - luni-db
    environment:
      MYSQL_HOST: luni-db
      MYSQL_DATABASE: luniserver_net
      MYSQL_USERNAME: root
      MYSQL_PASSWORD: MySecretRootPW
    volumes:
      -  ${MASS_STORAGE_PATH}/services/luniserver.net/config:/config
    networks:
      luni-net:
    ports:
      - 1001:1001/udp
      - 2001-2200:2001-2200/udp
      - 3000-3200:3000-3200/udp
```

### Allow external access through firewalld
Use the following commands to configure firewalld to allow external access to the server:
```bash
# Create service
firewall-cmd --permanent --new-service=darkflameserver
firewall-cmd --permanent --service=darkflameserver --add-port=1001/udp
firewall-cmd --permanent --service=darkflameserver --add-port=2001-2200/udp
firewall-cmd --permanent --service=darkflameserver --add-port=3000-3200/udp

# Reload firewall to discover new service
firewall-cmd --reload

# Add service
firewall-cmd --add-service=darkflameserver
firewall-cmd --permanent --add-service=darkflameserver


```

