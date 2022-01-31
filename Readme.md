# darkflameserver-docker
A Docker Container for the [Darkflame LEGO Universe server](https://github.com/DarkflameUniverse/DarkflameServer)

## How to build
Because the Darkflame Universe server requires proprietary client files to function, distributing a pre-built image is not possible. The build process is mostly automated though.

### Cloning the repository
```bash
git clone https://github.com/tom300z/darkflameserver-docker.git
cd darkflameserver-docker
```

### Finding a client

For optimal compatibility you will need a game client version 1.10.64 or above.

Hosting a client or a Link to one is unfortunately not allowed but clients with the following hashes should work:
```
# SHA256 
8f6c7e84eca3bab93232132a88c4ae6f8367227d7eafeaa0ef9c40e86c14edf5 (packed client, rar compressed)
c1531bf9401426042e8bab2de04ba1b723042dc01d9907c2635033d417de9e05 (packed client, includes extra locales, rar compressed)
0d862f71eedcadc4494c4358261669721b40b2131101cbd6ef476c5a6ec6775b (unpacked client, includes extra locales, rar compressed)
  
# SHA1
91498e09b83ce69f46baf9e521d48f23fe502985 (packed client, zip compressed)
```

You'll have to use your googling skills to find one.


### Gather client files
#### Setup resource directory
* In the `client-files` directory create a `res` directory if it does not already exist.
* Copy over or create symlinks from `macros`, `BrickModels`, `chatplus_en_us.txt`, `names`, `cdclient.fdb`, and `maps` in your client `res` directory to the server `client-files/res` directory
* Unzip the navmeshes [here](https://github.com/DarkflameUniverse/DarkflameServer/blob/main/resources/navmeshes.zip) and place them in `client-files/res/maps/navmeshes`

#### Setup locale
* In the `client-files` directory create a `locale` directory if it does not already exist
* Copy over or create symlinks from `locale.xml` in your client `locale` directory to the `client-files/locale` directory

Your work directory structure should now look like this:
```
Dockerfile
start.sh
client-files/
    locale/
        locale.xml
    res/
        cdclient.fdb
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
Now cou can build the container using docker and assign it a tag:
```bash
docker build -t darkflameserver .
```
After that the container should now be ready to use.

## Usage Examples
The database you specify to the containers will automatically be initialized. The credentials will also be configured automatically.
### Starting a Server (shell/bash)
```bash
# Create a network for the Containers
docker network create -d bridge docker_darkflameserver-net  

# Start a mariadb detached container
docker run \
  --name darkflameserver-db \
  --network docker_darkflameserver-net \
  -v "${MY_DATABASE_FOLDER}:/var/lib/mysql" \
  -e "MYSQL_ROOT_PASSWORD=MySecretRootPW" \
  -p 3306:3306/tcp \
  -d \
  mariadb \
  --default-authentication-plugin=mysql_native_password

# Start a detached DLU Container
docker run \
  --name darkflameserver \
  --network docker_darkflameserver-net \
  -v "${MY_CONFIG_FOLDER}:/config" \
  -e "MYSQL_HOST=darkflameserver-db" \
  -e "MYSQL_DATABASE=darkflameserver" \
  -e "MYSQL_USERNAME=root" \
  -e "MYSQL_PASSWORD=MySecretRootPW" \
  -p 1001:1001/udp \
  -p 2000-2200:2000-2200/udp \
  -p 3000-3200:3000-3200/udp \
  -t \
  -d \
  darkflameserver
```
### Starting a Server (Docker compose)
```
version: "2.2"
services:
# Darkflame LEGO Universe server
# Database
  darkflameserver-db:
    image: mariadb
    container_name: darkflameserver-db
    command: --default-authentication-plugin=mysql_native_password
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: "MySecretRootPW"
    volumes:
      -  ${MY_DATABASE_FOLDER}:/var/lib/mysql
    networks:
      darkflameserver-net:
    ports:
      - 3306:3306/tcp

# Server
  darkflameserver:
    image: darkflameserver
    container_name: darkflameserver
    restart: unless-stopped
    tty: true
    stop_grace_period: 2m
    depends_on:
      - darkflameserver-db
    environment:
      MYSQL_HOST: darkflameserver-db
      MYSQL_DATABASE: luniserver_net
      MYSQL_USERNAME: root
      MYSQL_PASSWORD: MySecretRootPW
    volumes:
      -  ${MY_CONFIG_FOLDER}:/config
    networks:
      darkflameserver-net:
    ports:
      - 1001:1001/udp
      - 2000-2200:2000-2200/udp
      - 3000-3200:3000-3200/udp
networks:
  darkflameserver-net:
    driver: bridge
```
### Checking logs
```bash
docker logs darkflameserver
```
### Creating an Admin account
```bash
docker exec -it darkflameserver ./MasterServer -a
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

## Problems?
Feel free to open an issue or a pull request.
