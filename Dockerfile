FROM python:3.12-alpine

WORKDIR /app

RUN apk add curl bash

COPY pyproject.toml uv.lock .python-version ./

RUN pip install uv && uv sync

COPY . .
RUN mkdir -p /results