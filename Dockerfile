# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package.json first (for better caching)
COPY package*.json ./

# Install dependencies - but does NOT include the dev dependencies, so the image is smaller. 
# dev dependencies are only needed during development and testing, not in production.
RUN npm install --only=production

# Copy all application files
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]
