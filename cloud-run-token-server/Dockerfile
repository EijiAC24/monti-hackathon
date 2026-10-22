FROM python:3.12-slim

WORKDIR /app

# eMudhra/emSign CA incident (2026-10-21): the base image ships pip and certifi from before the fix.
RUN pip install --no-cache-dir --upgrade "pip>=26.2.2" "certifi>=2026.10.19"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 2 --timeout 30 main:app
