*"* use this source file for your ABAP unit test classes
*"* use this source file for your ABAP unit test classes
class test definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      parse_string for testing raising cx_static_check,
      parse_array for testing raising cx_static_check,
      parse_boolean for testing raising cx_static_check,
      stringify for testing raising cx_static_check.
endclass.


class test implementation.

  method parse_string.

    data(json) =
    `{` &&
    `"stringValue":"String value"` &&
    `}`.

    types:
      begin of abap_type,
        string_value type string,
      end of abap_type.

    data(exp) = value abap_type(
        string_value = 'String value'
    ).

    data act type abap_type.

    zcl_json=>parse( json )->to( ref #( act ) ).

    cl_abap_unit_assert=>assert_equals(
      exporting
        act                  = act
        exp                  = exp
        msg                  = 'Parse string value'
    ).


  endmethod.

  method parse_boolean.

    data(json) =
      `{` &&
      `"trueValue":true,` &&
      `"falseValue":false` &&
      `}`.

    types:
      begin of abap_type,
        true_value  type xsdboolean,
        false_value type xsdboolean,
        null        type xsdboolean,
      end of abap_type.

    data(exp) = value abap_type(
        true_value = abap_true
    ).

    data act type abap_type.

    zcl_json=>parse( json )->to( ref #( act ) ).

    cl_abap_unit_assert=>assert_equals(
      exporting
        act                  = act
        exp                  = exp
        msg                  = 'Parse boolean value'
    ).

  endmethod.

  method parse_array.

    data(lv_json) = `[{ "test":true }]`.

    types:
      begin of result_ts,
        test type xsdboolean,
      end of result_ts,
      result_tt type table of result_ts with empty key.

    data(lt_result) = value result_tt( ).

    zcl_json=>parse( lv_json )->to( ref #( lt_result ) ).

    CL_ABAP_UNIT_ASSERT=>assert_equals(
      exporting
        exp                  = 1    " Data Object with Expected Type
        act                  = lines( lt_result )
    ).

    CL_ABAP_UNIT_ASSERT=>assert_equals(
      exporting
        exp                  = abap_true   " Data Object with Expected Type
        act                  = lt_result[ 1 ]-test
    ).

  endmethod.

  method stringify.

    types:
      begin of flags_ts,
        flag1 type xsdboolean,
      end of flags_ts,
      begin of test_ts,
        test        type xsdboolean,
        fake        type string,
        flags       type flags_ts,
        flags_boxed type flags_ts boxed,
      end of test_ts.

    CL_ABAP_UNIT_ASSERT=>assert_equals(
        exporting
          exp                  =  '{}'     " Data Object with Current Value
          msg                  = 'Stringify without initial components'
          act                  = zcl_json=>stringify( value test_ts( )  )    " Data Object with Expected Type
        ).


    CL_ABAP_UNIT_ASSERT=>assert_equals(
      exporting
        exp                  =  '{"test":false,"flags":{"flag1":false}}'     " Data Object with Current Value
        msg                  = 'Stringify without initial boxed components'
        act                  = zcl_json=>stringify(
            data = value test_ts( )      " Data Object with Expected Type
            initial_components = 'suppress_boxed' )
    ).

    CL_ABAP_UNIT_ASSERT=>assert_equals(
      exporting
        msg                  = 'Stringify with initial components'
        exp                  =  '{"test":false,"flags":{"flag1":false},"flagsBoxed":{"flag1":false}}'     " Data Object with Current Value
        act                  = zcl_json=>stringify(
            data = value test_ts( )
            initial_components = 'include' ) )    " Data Object with Expected Type
    .


  endmethod.



endclass.
