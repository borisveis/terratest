from fastapi import FastAPI, Request
from datetime import datetime
import time

app = FastAPI()

def current_millis():
    return int(time.time() * 1000)

@app.get("/")
async def get_time():
    return {"timestamp_ms": current_millis()}

@app.post("/")
async def post_time(request: Request):
    return {"timestamp_ms": current_millis()}
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)