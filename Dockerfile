# Stage 1: Build virtual environment and install dependencies
FROM python:3.12-slim AS builder

WORKDIR /app

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Minimal runtime image with non-root security context
FROM python:3.12-slim AS runner

WORKDIR /app

RUN useradd -u 8888 appuser && chown -R appuser:appuser /app

COPY --from=builder /opt/venv /opt/venv
COPY app/ ./app

ENV PATH="/opt/venv/bin:$PATH"
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]