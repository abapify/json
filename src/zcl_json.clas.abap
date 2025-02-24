class zcl_json definition
  public
  final
  create public abstract.

  public section.

    class-methods parse
      importing
                json          type any
                value(case)   type ref to zif_abap_case optional
      returning value(result) type ref to zif_parser
      raising   cx_static_check.

    " renders json as a text
    class-methods stringify
      importing
      data type any
      value(case)          type ref to zif_abap_case optional
      initial_components type string default 'suppress'
      returning value(result) type string
      raising   cx_static_check.

    " renders json in binary mode
    class-methods render
      importing
      data type any
      value(case)          type ref to zif_abap_case optional
      initial_components type string default 'suppress'
      returning value(result) type xstring
      raising   cx_static_check.


ENDCLASS.



CLASS ZCL_JSON IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_JSON=>PARSE
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        ANY
* | [--->] CASE                           TYPE REF TO ZIF_ABAP_CASE(optional)
* | [<-()] RESULT                         TYPE REF TO ZIF_JSON_PARSER_RESULT
* | [!CX!] CX_STATIC_CHECK
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method parse.


    if case is not bound.
      case = zcl_abap_case=>camel( ).
    endif.

    try.


        " normalize JSON (prepare for identity)
        " we're doing so because at least in ABAP 7.40 it's not possible to run XSLT json to ABAP
        " with any other transformation rather than identity transformation
        " so as we use identity to generate json, then let's just convert JSON to asJSON
        data(lo_json_out) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).
        call transformation zjson_to_abap
        parameters
            case = case
          source xml json
          result xml lo_json_out.

        data(lo_parser) = new lcl_parser_result( ).
        " perfromance wise one more copying less ( in a constructor )
        lo_parser->json = lo_json_out->get_output( ).

        result = lo_parser.


      catch cx_transformation_error into data(lo_cx).
        raise exception type lcx_parse_error exporting previous = lo_cx.
    endtry.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_JSON=>RENDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA                           TYPE        ANY
* | [--->] CASE                           TYPE REF TO ZIF_ABAP_CASE(optional)
* | [--->] INITIAL_COMPONENTS             TYPE        STRING (default ='suppress')
* | [<-()] RESULT                         TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method render.

    " 1) transform data to JSON (initial transformation)
    data(lo_json_abap) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).

    call transformation id
      source data = data
      options
        initial_components = initial_components
        data_refs = 'embedded'
      result xml lo_json_abap.

    data(lv_json) = lo_json_abap->get_output( ).

    if case is not bound.
      case = zcl_abap_case=>camel( ).
    endif.

    if 1 eq 2.
        call transformation zjson_from_abap
            parameters
                case = case
              source xml lv_json
              result xml data(lv_xml_debug).
    endif.

    " 2) normalize JSON
    data(lo_json_out) = cl_sxml_string_writer=>create( if_sxml=>co_xt_json ).
    call transformation zjson_from_abap
    parameters
        case = case
      source xml lv_json
      result xml lo_json_out.



     result = cond #(
      LET lv_json_out = lo_json_out->get_output( ) IN
      WHEN xstrlen( lv_json_out ) = 0 THEN zcl_abap_codepage=>to( `{}` )
      ELSE lv_json_out ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_JSON=>STRINGIFY
* +-------------------------------------------------------------------------------------------------+
* | [--->] DATA                           TYPE        ANY
* | [--->] CASE                           TYPE REF TO ZIF_ABAP_CASE(optional)
* | [--->] INITIAL_COMPONENTS             TYPE        STRING (default ='suppress')
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method stringify.

    data(json) = render(
        data = data
        case = case
        initial_components = initial_components
    ).

    result = zcl_abap_codepage=>from( json ).

  endmethod.
ENDCLASS.
