FROM python:3.11-buster AS builder
WORKDIR /app

ENV POETRY_VIRTUALENVS_IN_PROJECT=true

RUN pip install --upgrade pip && pip install poetry

COPY pyproject.toml .
COPY poetry.lock .

RUN poetry install --no-root --no-interaction --no-ansi

FROM python:3.11-buster AS prod
WORKDIR /app

COPY --from=builder /app .
ENV PATH="/app/.venv/bin:$PATH"
COPY ./entrypoint.sh /app/entrypoint.sh

EXPOSE 8000


CMD [ "uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000" ]