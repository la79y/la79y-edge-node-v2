## Use Node.js 20 image based on Alpine Linux as the base image
#FROM node:20-alpine
#
## Set the working directory in the image
#WORKDIR /usr/src/app
#
## Install dependencies
#RUN apk add --no-cache python3 make gcc g++ git bash patch tcl pkgconfig cmake openssl-dev linux-headers alpine-sdk
#
## Upgrade npm to version 9.6 and install node-gyp globally
#RUN npm install -g npm@9.6 && \
#    npm install -g node-gyp
#
## Copy required files from the host to the working directory in the image
#COPY node-srt /usr/src/app/node-srt
#COPY package.json /usr/src/app
#
## Install npm dependencies
#RUN npm install
#
## Copy the rest of the application code from the host to the working directory in the image
#COPY . /usr/src/app
#
## Set the command to run the application
#CMD ["npm", "start"]

# Build Stage
FROM node:20-alpine3.17 as build

# Set the working directory
WORKDIR /usr/src/app

# Install system dependencies required for npm install
RUN apk add --no-cache python3 make gcc g++ git bash patch tcl pkgconfig cmake openssl-dev linux-headers alpine-sdk

# Upgrade npm and install node-gyp globally
RUN npm install -g npm@9.6 node-gyp

# Copy package.json
COPY node-srt /usr/src/app/node-srt
COPY package.json /usr/src/app

# Install npm dependencies
RUN npm install

# Copy the application source code
COPY . /usr/src/app

# Final Stage
FROM node:20-alpine3.17

# Set working directory
WORKDIR /usr/src/app

# Copy built node modules and binaries without including the build tools
COPY --from=build /usr/src/app /usr/src/app

# Expose the port the app runs on
EXPOSE 3000

# Set the command to run your app
CMD ["npm", "start"]
