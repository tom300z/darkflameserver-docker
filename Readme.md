# luni-server
## Description
Darkflame LEGO Universe server
## How to build
### Getting a client

## Usage Examples
### Shell
```
docker run --network docker_luni-net -v /host/folder:/config -e "MYSQL_HOST=luni-db" -e "MYSQL_DATABASE=luniserver_net" -e "MYSQL_USERNAME=root" -e "MYSQL_PASSWORD=secret" -it luni-server
```
### Docker compose
