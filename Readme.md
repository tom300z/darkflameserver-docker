# darkflameserver-docker
A Docker Container for the Darkflame LEGO Universe server

## How to build
Because the Darkflame Universe server requires proprietary client files to run, distributing a pre-built image is not possible. The build process is pretty straightforward though.

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
### Shell
First create a bridge network:
```bash

```
```bash
docker run --network docker_darkflameserver-net -v /host/folder:/config -e "MYSQL_HOST=darkflameserver-db" -e "MYSQL_DATABASE=darkflameserver" -e "MYSQL_USERNAME=root" -e "MYSQL_PASSWORD=secret" -t darkflameserver-server
```
```bash
docker run --network docker_darkflameserver-net -v /host/folder:/config -e "MYSQL_HOST=darkflameserver-db" -e "MYSQL_DATABASE=darkflameserver" -e "MYSQL_USERNAME=root" -e "MYSQL_PASSWORD=secret" -t darkflameserver-server
```
### Docker compose
