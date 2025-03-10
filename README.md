# Recipe Suggester API Tests

## Description

This project is the `api-tests` repository for the Recipe Suggester API. It contains automated tests for the API, written in Robot Framework.

## Getting Started

### Prerequisites

*   Docker
*   Python
*   uv

### Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/hyoaru/recipe-suggester-ai-agent-api-tests.git
    cd recipe-suggester-api-tests
    ```

2.  Install the dependencies using uv:

    ```bash
    uv sync
    ```

4.  Copy `.env.example` to `.env` and configure the environment variables:

    ```bash
    cat .env.example >> .env
    ```

### Running Tests

1.  Run the tests using the following command:

    ```bash
    uv run pabot --outputdir ./results --testlevelsplit ./tests/suites
    ```

2.  View the test results in the `results/` directory.

## CI

The project includes a `Jenkinsfile` for automated CI using Jenkins.

### Jenkins Setup

1.  Install the required Jenkins plugins.
2.  Configure a Jenkins pipeline using the `Jenkinsfile`.
3.  Set up environment variables in Jenkins.

## License

[MIT](LICENSE)

## Project Structure

```
.
├── .dockerignore
├── .env.example
├── .gitignore
├── .python-version
├── docker-compose.yaml
├── Dockerfile
├── entrypoint.sh
├── Jenkinsfile
├── pyproject.toml
├── README.md
├── uv.lock
├── results
│   └── ...
├── tests
│   ├── load_env.py
│   ├── json_schemas
│   │   ├── health_response.json
│   │   ├── logs_response.json
│   │   └── recipe_suggestions_response.json
│   ├── resources
│   │   └── base.robot
│   ├── suites
│   │   ├── operations.robot
│   │   └── recipe_suggestions.robot
│   └── variables
│       └── base.robot