*** Settings ***
Documentation    Test suites for recipe suggestion functionality
Resource    ../resources/base.robot
Library    JSONLibrary
Suite Setup    Initialize

*** Variables ***
${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}    ${EMPTY}

*** Keywords ***
Initialize 
    Initialize Global Variables

    Log    Loading response schemas...
    ${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}=    Load Json From File    ./tests/json_schemas/recipe_suggestions_response.json
    Set Suite Variable    ${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}
    Log    Loaded response schemas.

*** Test Cases ***
Suggest Recipes With Valid Ingredients
    [Tags]    smoke    regression    positive
    Create Api Session

    Log    Creating request payload...
    ${ingredients}    Create List    egg    butter
    ${request_payload}    Create Dictionary    ingredients=${ingredients}
    Log    Created request payload.

    Log    Sending post request...
    ${response}    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=200
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    200
    ${response_payload}    Set Variable    ${response.json()}
    Log    ${response_payload}
    Log    ${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}
    Validate Json By Schema    json_object=${response_payload}    schema=${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}
    Log    Validated response.


Suggest Recipes With Empty Ingredients
    [Tags]    negative    regression
    Create Api Session

    Log    Creating request payload...
    ${request_payload}    Create Dictionary    ingredients=[]
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.

Suggest Recipes With Non String Ingredients
    [Tags]    negative
    Create Api Session

    Log    Creating request payload...
    ${request_payload}    Create Dictionary    ingredients=[42, {"name": "butter"}]
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.


Suggest Recipes Without Ingredients Key
    [Tags]    negative
    Create Api Session

    Log    Creating request payload...
    ${request_payload}    Create Dictionary
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.


Suggest Recipes With Special Characters As Ingredient
    [Tags]    edge    regression    negative
    Create Api Session

    Log    Creating request payload...
    ${ingredients}    Create List    egg    @butter!
    ${request_payload}    Create Dictionary    ingredients=${ingredients}
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.


Suggest Recipes With Unicode Characters In Ingredients
    [Tags]    edge    regression    negative
    Create Api Session

    Log    Creating request payload...
    ${ingredients}    Create List    🥚    バター    汤
    ${request_payload}    Create Dictionary    ingredients=${ingredients}
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.


Suggest Recipes With Duplicate Ingredients
    [Tags]    edge    positive
    Create Api Session

    Log    Creating request payload...
    ${ingredients}    Create List    egg    egg    butter    butter
    ${request_payload}    Create Dictionary    ingredients=${ingredients}
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=200
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    200    response=${response}
    ${response_payload}    Set Variable    ${response.json()}
    Validate Json By Schema    json_object=${response_payload}    schema=${SUITE_RECIPE_SUGGESTIONS_RESPONSE_SCHEMA}
    Log    Validated response.


Suggest Recipes With Whitespace Only Ingredients
    [Tags]    negative
    Create Api Session
    
    Log    Creating request payload...
    ${ingredients}    Create List    ${SPACE}    ${SPACE}${SPACE}
    ${request_payload}    Create Dictionary    ingredients=${ingredients}
    Log    Created request payload.

    Log    Sending post request...
    ${response}=    POST On Session    alias=api    url=/recipes/suggest    json=${request_payload}    expected_status=422
    Log    Sent post request.

    Log    Validating response...
    Status Should Be    422    response=${response}
    Log    ${response.json()}
    Log    Validated response.
