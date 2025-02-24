FROM python:3.11-buster AS builder

# Set working directory
WORKDIR /app

# Install Poetry and upgrade pip
RUN pip install --upgrade pip && pip install poetry

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Configure Poetry and install dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Copy application code and entrypoint script
COPY . .  
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Final stage
FROM python:3.11-buster AS app

# Set working directory
WORKDIR /app



# Copy installed dependencies and application code from builder
COPY --from=builder /app /app

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Expose the required port
EXPOSE 8000

# Set entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]



# Run the FastAPI application
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]

