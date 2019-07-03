*** Settings ***
Library  Collections
Library  RoboZap  http://127.0.0.1:8090/  8090
Library  OperatingSystem
Library  REST  http://localhost:5050  proxies={"http": "http://127.0.0.1:8090", "https": "http://127.0.0.1:8090"}

*** Variables ***
${TARGET_NAME}  Flask
${TARGET_URI}  localhost:5050
${TARGET_HOST}  localhost
${TARGET_IP}  localhost
#CONFIG
${RESULTS_PATH}  /robozapresults/

${ZAP_PATH}  /zap/ZAP_2.8.0/
${APPNAME}  Flask
${CONTEXT}  Flask
${REPORT_TITLE}  Flask Test Report - ZAP
${REPORT_FORMAT}  json
${ZAP_REPORT_FILE}  Flask.json
${REPORT_AUTHOR}  Abhay
${SCANPOLICY}  Default Policy

*** Test Cases ***

Setup directories
    Create Directory  ${RESULTS_PATH}

Initialize ZAP
    [Tags]  zap_init
    start gui zap  ${ZAP_PATH}
    sleep  30
    zap open url  http://${TARGET_URI}

Authenticate to Web Service
    &{res}=  POST  /login  {"username": "admin", "password": "admin123"}
    Integer  response status  200
    set suite variable  ${TOKEN}  ${res.headers["Authorization"]}

Get Customer by ID
    [Setup]  Set Headers  { "Authorization": "${TOKEN}" }
    GET  /get/2
    Integer  response status  200

Post Fetch Customer
    [Setup]  Set Headers  { "Authorization": "${TOKEN}" }
    POST  /fetch/customer  { "id": 3 }
    Integer  response status  200

Search Customer by Username
    [Setup]  Set Headers  { "Authorization": "${TOKEN}" }
    POST  /search  { "search": "dleon" }
    Integer  response status  200

ZAP Contextualize
    [Tags]  zap_context
    ${contextid}=  zap define context  ${CONTEXT}  http://${TARGET_URI}
    set suite variable  ${CONTEXT_ID}  ${contextid}

ZAP Active Scan
    [Tags]  zap_scan
    ${scan_id}=  zap start ascan  ${CONTEXT_ID}  http://${TARGET_URI}  ${SCANPOLICY}
    set suite variable  ${SCAN_ID}  ${scan_id}
    zap scan status  ${scan_id}
    zap write to json file  http://${TARGET_URI}

ZAP Generate Report
    [Tags]  zap_generate_report
    zap export report  ${RESULTS_PATH}/${ZAP_REPORT_FILE}  ${REPORT_FORMAT}  ${REPORT_TITLE}  ${REPORT_AUTHOR}

ZAP Die
    zap shutdown

