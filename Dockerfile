FROM python:3.12-alpine

WORKDIR /app

RUN apk add curl bash

COPY pyproject.toml uv.lock .python-version ./

RUN pip install uv && uv sync
RUN uv pip freeze > requirements.txt
RUN pip install -r requirements.txt

CMD ["bash", "run_tests.sh"]
