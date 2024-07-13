# Use the official Node.js image from the Docker Hub, the latest LTS version
FROM node:22

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json .

# # Install the dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

EXPOSE 5173

# Command to start the React app in production mode
CMD ["npm", "run", "dev"]