# Use official Python 3.11 base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.api.txt .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.api.txt

# Copy the rest of the code
COPY api.py .

# Expose port for FastAPI
EXPOSE 8080

# Command to run the app with uvicorn
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
