from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="FastAPI DevOps Demo")

# Automatically expose HTTP metrics at /metrics
Instrumentator().instrument(app).expose(app)


@app.get("/")
def read_root():
    return {"status": "online", "message": "FastAPI on AWS EKS"}


@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "fastapi-backend"}