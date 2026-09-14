import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    # Context manager ensures FastAPI lifespan startup/shutdown events run
    with TestClient(app) as c:
        yield c


def test_read_root(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "online"


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "service": "fastapi-backend"}
