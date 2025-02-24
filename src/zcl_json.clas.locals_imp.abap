CLASS lcl_parser_result DEFINITION FRIENDS zcl_json.
  PUBLIC SECTION.
    INTERFACES zif_parser.
  PRIVATE SECTION.
    DATA json TYPE xstring.
ENDCLASS.

CLASS lcx_parse_error DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

" this class expects to have json coming in asJSON format
CLASS lcl_parser_result IMPLEMENTATION.
  METHOD zif_parser~to.


    ASSERT data IS BOUND.
    ASSIGN data->* TO FIELD-SYMBOL(<data>).

    TRY.

        " convert to ABAP
        CALL TRANSFORMATION id
         SOURCE XML me->json
          OPTIONS
*          clear = 'all'
          value_handling = 'accept_data_loss'
         RESULT data = <data>.

      CATCH cx_transformation_error INTO DATA(lo_cx).
        RAISE EXCEPTION TYPE lcx_parse_error.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
