*** Settings ***
Documentation    Resource for recipe suggestion test suite
Library    RequestsLibrary
Resource    ../variables/base.robot

*** Keywords ***
Create Api Session
    ${headers}    Create Dictionary    Content-Type=application/json    accept=application/json
    Create Session    alias=api    url=${GLOBAL_API_BASE_URL}/api    headers=${headers}
