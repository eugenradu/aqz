FROM python:3.11-slim

WORKDIR /app

RUN pip install --upgrade pip

COPY pyproject.toml ./
RUN pip install fastapi uvicorn[standard] python-dotenv

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]