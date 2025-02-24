# ABAP JSON API

## Why?

We know at least following ways to serialize/deserialize JSON in ABAP:

- [identity transformation](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm?file=abenabap_json.htm)
- sXML library for manual parsing/rendering
- /ui2/cl_json or open-source [Z_UI2_JSON](https://github.com/SAP/abap-to-json) version of it
- [xco_cp_json](https://help.sap.com/docs/btp/sap-business-technology-platform/json)

  Full list you can find in a separate [benchmark](https://github.com/abapify/json-benchmark): 

| Method                                                       | Features                                                                                                                                                                                                                                                         |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Identity Transformation** (`CALL TRANSFORMATION JSON`)     | ✅ Standard SAP approach <br> ✅ Very fast <br> ✅ Supports deep structures <br> ❌ Limited functionality                                                                                                                                     |
| **sXML Library** (`cl_sxml_string_writer`, `cl_sxml_parser`) | ✅ Fine-grained control over parsing/rendering <br> ✅ Handles large JSON streams efficiently <br> ✅ Supports custom serialization logic <br> ❌ Requires manual parsing and handling of JSON nodes <br> ❌ More complex to implement compared to other methods |
| **/UI2/CL_JSON** (or `Z_UI2_JSON`)                           | ✅ Easy to use, with automatic conversion <br> ✅ Supports deep and complex structures <br> ✅ Open-source alternative available (`Z_UI2_JSON`) <br> ✅ So far fastest JSON parser and rendered after identity transformation     |
| **XCO_CP_JSON** (`xco_cp_json`)                              | ✅ Modern, officially supported API for Cloud <br> ✅ Ability to apply own transformations <br> ❌ Not available in older on-premise systems  <br> ❌ Enormously slow <br> ❌ Dumps on data refs                                                                           |

Here you can find a very good [article](https://community.sap.com/t5/application-development-blog-posts/abap-fast-json-serialization/ba-p/13556816) about some of these methods

Unfortunately I was not please with any of approaches and decided to create an own library implementing following features:

- Using standard identity transformation supporting all available types mapping automatically
- Automatic `camelCase` <-> `CAMEL_CASE` conversion for property names
- Suppress initital components ( feature of identity transformation )
- Allowing to use own conversion rules

### Performance benchmark

You can find more details and data in [JSON benchmark](https://github.com/abapify/json-benchmark) project where we analyse different libs, their features and compare performance. Feel free to contribute!

## ZCL_JSON

### Render JSON

```abap
" render binary
data(json_binary) = zcl_json=>render( your_any_variable )
" or stringify (same but as string)
data(json_string) = zcl_json=>stringify( your_any_variable )
```

### Parse JSON

```abap
" Parsing requires two steps
zcl_json=>parse( json_binary_or_string )->to( ref #(  your_data_variable ) ).
```

### Support data refs
It's possible to create JSON from data references
```abap
" render binary
data(json_binary) = zcl_json=>render( value payload_type( ref_to_data = new any_type( some_values = .. ) ) )
```

### Support polymorphic arrays
By default ABAP internal tables do not support polymorphism or union types. You need to normalize type and build type including all elements. However in a modern world JSON schemas can use such constructions as `oneOf`, `anyOf` and etc. As a result of data refs support we can also support `table of ref to data` which allows us to build arrays where every line may be of a different type.

```abap
 TYPES:
   BEGIN OF abap_bool_ts,
    true TYPE abap_bool,
   END OF abap_bool_ts,
   BEGIN OF xsdboolean_ts,
    true TYPE xsdboolean,
   END OF xsdboolean_ts, 
   BEGIN OF root_ts,
     array_of_ref_to_data TYPE TABLE of REF TO data WITH EMPTY KEY,
   END OF root_ts.

TRY.   
      out->write(
        name = 'Polymorphic array'
        data = zcl_json=>stringify(
            VALUE root_ts(
                array_of_ref_to_data = value #(
                    ( new abap_bool_ts(  true = abap_true ) )
                    ( new xsdboolean_ts( true = abap_true ) )
                    ) ) ) ).

     CATCH cx_static_check.
       "handle exception
   ENDTRY.
```
will print
```json
{"arrayOfRefToData":[{"true":"X"},{"true":true}]}
```

## Dependencies
- [ZCL_ABAP_CASE](https://github.com/abapify/case)
- [ZCL_ABAP_CODEPAGE](https://github.com/abapify/codepage)

## Test Dependencies
- [assert](https://github.com/abapify/assert) (via codepage)
- [throw](https://github.com/abapify/throw) (via codepage)
