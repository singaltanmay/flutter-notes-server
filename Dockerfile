# Dockerfile to generate the Docker image to run this project
# Instructions -
# docker build -t singaltanmay/flutter-notes-server .
# docker run -p 3000:3000 -d singaltanmay/flutter-notes-server

#
# MongoDB Dockerfile
#
# https://github.com/dockerfile/mongodb
#

# Pull base image.
FROM ubuntu:20.04

# Install MongoDB.
RUN apt update && apt upgrade -y
RUN apt install -y gnupg wget curl
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN apt update
RUN apt-get install -y mongodb-org

# Define mountable directories.
VOLUME ["/data/db"]

# Define working directory.
WORKDIR /data

# Expose MongoDb outside of container
#EXPOSE 27017

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

EXPOSE 3000

# Run the application
 CMD mongod & npm start
