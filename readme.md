# Flutter Notes - Server

This is the server for my notes application. It is built using ExpressJS and uses MongoDB for persistence.


## Setup
### 1. Pull the latest Docker image
```angular2html
docker pull ghcr.io/singaltanmay/flutter-notes:latest
```

### 2. Start the container
```angular2html
docker run -p 3000:3000 -d --name flutter-notes ghcr.io/singaltanmay/flutter-notes:latest
```
You can change the port on which the application is exposed by modifying the `-p` flag as `-p <HOST_PORT>:3000`
