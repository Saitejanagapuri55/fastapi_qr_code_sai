# Use an official lightweight Python image.
# 3.12-slim-bullseye variant is chosen for a balance between size and utility.
FROM python:3.12-slim-bullseye AS base

# Set environment variables:
# PYTHONUNBUFFERED: Prevents Python from buffering stdout and stderr
# PYTHONFAULTHANDLER: Enables the fault handler for segfaults
# PIP_NO_CACHE_DIR: Disables the pip cache for smaller image size
# PIP_DEFAULT_TIMEOUT: Avoids hanging during install
# PIP_DISABLE_PIP_VERSION_CHECK: Suppresses the "new version" message
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Set the working directory inside the container
WORKDIR /myapp

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker layer caching
COPY requirements.txt /myapp/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /myapp

# Copy the startup script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Add a non-root user and switch to it for security
RUN useradd -m -s /bin/bash myuser
USER myuser

# Expose the application port
EXPOSE 8000

# Define the default command to run the application
CMD ["/start.sh"]
