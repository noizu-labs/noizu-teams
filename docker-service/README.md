# Terminal Service

A Python service using FastAPI and WebSockets to execute terminal commands and return the output via RPC or WebSocket calls. The service can be containerized using Docker.

## Prerequisites

- Docker
- Python 3.8 or higher

## How to build and run the Docker container

1. Navigate to the `terminal-service` directory.
2. Build the Docker image:

```

docker build -t terminal-service .

```markdown

3. Run the Docker container:

```

docker run -d -p 8000:8000 --name terminal-service terminal-service

```arduino

4. Access the service in your browser or using a WebSocket client at `ws://localhost:8000/ws`.

5. To stop and remove the container, run:

```

docker stop terminal-service docker rm terminal-service

```bash

## Usage

1. Connect to the WebSocket endpoint at `ws://localhost:8000/ws`.
2. Send a message containing the terminal command you want to execute.
3. The service will broadcast the output of the command to all connected clients.
```

This is a brief overview of the Terminal Service, including prerequisites, building, and running the Docker container, and basic usage instructions.