CLASS lcl_parser_result DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_parser.
    METHODS constructor IMPORTING json TYPE xstring.
  PRIVATE SECTION.
    DATA json TYPE xstring.
ENDCLASS.

CLASS lcx_parse_error DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

" this class expects to have json coming in asJSON format
CLASS lcl_parser_result IMPLEMENTATION.
  METHOD constructor.
    me->json = json.
  ENDMETHOD.
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

CLASS lcl_codepage DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      from IMPORTING source TYPE xstring RETURNING VALUE(result) TYPE string RAISING cx_static_check,
      to   IMPORTING source TYPE string RETURNING VALUE(result) TYPE xstring RAISING cx_static_check.
ENDCLASS.

CLASS lcl_codepage IMPLEMENTATION.

  METHOD from.
    TRY.
        DATA codepage_new TYPE REF TO object.
        DATA(codepage_cls_new) = 'CL_ABAP_CONV_CODEPAGE'.

        " Try using the new class dynamically
        CALL METHOD (codepage_cls_new)=>create_in RECEIVING instance = codepage_new.
        CALL METHOD codepage_new->('IF_ABAP_CONV_IN~CONVERT')
          EXPORTING source = source
          RECEIVING result = result.

      CATCH cx_sy_dyn_call_illegal_class.
        " Fallback to the old class
        DATA(codepage_cls_old) = 'CL_ABAP_CODEPAGE'.
        CALL METHOD (codepage_cls_old)=>convert_from
          EXPORTING source = source
          RECEIVING result = result.
    ENDTRY.
  ENDMETHOD.

  METHOD to.
    TRY.
        DATA codepage_new TYPE REF TO object.
        DATA(codepage_cls_new) = 'CL_ABAP_CONV_CODEPAGE'.

        " Try using the new class dynamically
        CALL METHOD (codepage_cls_new)=>create_out RECEIVING instance = codepage_new.
        CALL METHOD codepage_new->('IF_ABAP_CONV_OUT~CONVERT')
          EXPORTING source = source
          RECEIVING result = result.

      CATCH cx_sy_dyn_call_illegal_class.
        " Fallback to the old class
        DATA(codepage_cls_old) = 'CL_ABAP_CODEPAGE'.
        CALL METHOD (codepage_cls_old)=>convert_to
          EXPORTING source = source
          RECEIVING result = result.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
