from fastapi import FastAPI, WebSocket
from app.websocket_manager import WebSocketManager
from app.terminal import Terminal

app = FastAPI()
terminal = Terminal()
websocket_manager = WebSocketManager()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket_manager.connect(websocket)
    try:
        while True:
            command = await websocket.receive_text()
            output = terminal.run_command(command)
            await websocket_manager.broadcast(output)
    finally:
        await websocket_manager.disconnect(websocket)

