from fastapi import FastAPI, status

app = FastAPI(
    title="DevOps Demo API",
    version="1.0.0"
)

@app.get("/", status_code=status.HTTP_200_OK)
def read_root():
    return {"status": "online", "message": "DevOps FastAPI Service is running"}

@app.get("/health", status_code=status.HTTP_200_OK)
def health_check():
    # AWS Application Load Balancers use this endpoint to determine target health
    return {"status": "healthy", "service": "fastapi-backend"}