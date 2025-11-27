# Use official Python 3.11 slim base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV STREAMLIT_SERVER_ENABLECORS=false
ENV STREAMLIT_SERVER_HEADLESS=true

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.app.txt .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.app.txt

# Copy application code
COPY app.py .

# Expose default Streamlit port
EXPOSE 8080

# Command to run Streamlit
CMD ["python3", "-m", "streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
