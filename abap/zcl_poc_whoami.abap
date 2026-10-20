"! ICF handler that answers with the user the request runs as.
"! SICF node /default_host/sap/bc/zpoc_whoami, handler list: this class.
"! No logon data on the node, so every caller has to authenticate.
CLASS zcl_poc_whoami DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_poc_whoami IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    server->response->set_content_type( 'application/json' ).
    server->response->set_cdata(
      |\{ "abapUser": "{ sy-uname }", "client": "{ sy-mandt }", | &&
      |"system": "{ sy-sysid }", "time": "{ sy-datum } { sy-uzeit }" \}| ).
    server->response->set_status( code = 200 reason = 'OK' ).
  ENDMETHOD.
ENDCLASS.
