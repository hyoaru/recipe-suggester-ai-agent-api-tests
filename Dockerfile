FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


# Use a final image without uv
FROM python:3.12-alpine AS runtime

RUN apk add curl bash && apk cache clean

# Create group with GID 1000 and user with UID 1000
RUN addgroup -g 1000 nonroot \
    && adduser -u 1000 -G nonroot -S nonroot

# Copy the application from the builder
COPY --from=builder --chown=nonroot:nonroot /app /app

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nonroot

ENTRYPOINT ["/entrypoint.sh"]

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"