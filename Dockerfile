# Use Python 3.10 slim image for a lightweight container
FROM python:3.10-slim

# Set working directory to /app
WORKDIR /app

# Install system dependencies
# build-essential: for compiling some python packages
# curl: for healthchecks or downloading tools
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository
COPY . .

# Set PYTHONPATH to /app so that 'core' and other root modules 
# can be imported by the MCP server code if needed.
ENV PYTHONPATH=/app

# Install dependencies for the MCP server.
# We trust the MCP/requirements.txt is sufficient for the server logic.
# If you need local LLM support, you might need to install the root requirements.txt
# but be warned it is very large (several GBs).
WORKDIR /app/MCP
RUN pip install --no-cache-dir -r requirements.txt

# Railway provides the PORT environment variable.
# The run.py script accepts --port argument.
ENV PORT=8000
ENV HOST=0.0.0.0

# Expose the port (informative only for Railway)
EXPOSE $PORT

# Start the server
# We use shell form to ensure environment variables like $PORT are expanded.
CMD ["sh", "-c", "python run.py --host $HOST --port $PORT"]
