*** Settings ***
Documentation    Base variables for the entire project
Library    OperatingSystem
Library    ../load_env.py

*** Variables ***
${GLOBAL_API_BASE_URL}    ${EMPTY}

*** Keywords ***
Initialize Global Variables
    Log    Setting up suite...
    ${api_base_url}=    Get Environment Variable    API_BASE_URL
    Set Suite Variable    ${GLOBAL_API_BASE_URL}    ${api_base_url}
