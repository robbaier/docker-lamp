### Building the image
`docker build -t docker-lamp .`

### Running the image
`docker run -d -p "4200:80" docker-lamp:latest`

### SSH to the running container
`docker exec -it docker-lamp /bin/zsh`
