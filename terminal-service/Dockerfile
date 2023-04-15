# Usexir an official Python runtime as a parent image
FROM elixir:1.14.4

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN apt update && apt install python3 -y && apt install pip -y
RUN pip3 install --trusted-host pypi.python.org -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000
EXPOSE 4000

# Define environment variable
ENV NAME terminal-service

# Run the command to start the server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
