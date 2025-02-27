*** Settings ***
Documentation    Test suites for operations resource
Resource    ../resources/base.robot
Library    JSONLibrary
Suite Setup    Initialize

*** Variables ***
${SUITE_HEALTH_RESPONSE_SCHEMA}    ${EMPTY}
${SUITE_LOGS_RESPONSE_SCHEMA}    ${EMPTY}


*** Keywords ***
Initialize 
		Initialize Global Variables

    Log    Loading response schemas...
	  ${SUITE_HEALTH_RESPONSE_SCHEMA}=    Load Json From File    ./tests/json_schemas/health_response.json
		Set Suite Variable    ${SUITE_HEALTH_RESPONSE_SCHEMA}

	  ${SUITE_LOGS_RESPONSE_SCHEMA}=    Load Json From File    ./tests/json_schemas/logs_response.json
		Set Suite Variable    ${SUITE_LOGS_RESPONSE_SCHEMA}
		Log    Loaded response schemas.

*** Test Cases ***
Verify Health Check Returns Valid Data
		[Tags]    smoke    regression    positive
		Create Api Session

		Log    Sending health check request...
		${response}=    GET On Session    alias=api    url=/operations/health    expected_status=200
		Log    Sent health check request.

    Log    Validating response...
    Status Should Be    200
    ${response_payload}    Set Variable    ${response.json()}
    Log    ${response_payload}
    Log    ${SUITE_HEALTH_RESPONSE_SCHEMA}
    Validate Json By Schema    json_object=${response_payload}    schema=${SUITE_HEALTH_RESPONSE_SCHEMA}
    Log    Validated response.

Verify Logs Returns Valid Data
    [Tags]    smoke    regression    positive
    Create Api Session

    Log    Sending logs request...
    ${response}=    GET On Session    alias=api    url=/operations/logs    expected_status=200
    Log    Sent logs request.

    Log    Validating response...
    Status Should Be    200
    ${response_payload}    Set Variable    ${response.json()}
    Log    ${response_payload}
    Log    ${SUITE_LOGS_RESPONSE_SCHEMA}
    Validate Json By Schema    json_object=${response_payload}    schema=${SUITE_LOGS_RESPONSE_SCHEMA}
    Log    Validated response.


Verify Logs Endpoint With Query Parameters
    [Tags]    regression    positive
    Create Api Session
		
		Log    Creating request params...
    ${params}=    Create Dictionary    count=5
		Log    Created request params

    Log    Sending logs request with query params...
    ${response}=    GET On Session    alias=api    url=/operations/logs    params=${params}    expected_status=200
    Log    Sent logs request.

    Log    Validating response...
    Status Should Be    200    ${response}
    ${response_body}=    Set Variable    ${response.json()}
		Log    ${response_body}

		${response_length}=    Get Length    ${response_body}
		Should Be True    ${response_length} <= 5
    Log    Validated response.