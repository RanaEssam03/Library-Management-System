# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Install curl and other necessary packages
RUN apt-get update && apt-get install -y curl && apt-get clean

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Expose the port that the Flask app runs on
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "main.py"]
