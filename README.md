# ABAP JSON API

## Why?

We know at least following ways to serialize/deserialize JSON in ABAP:

- Using [identity transformation](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm?file=abenabap_json.htm)
- Using sXML library for manual parsing/rendering
- Using /ui2/cl_json or open-source [Z_UI2_JSON](https://github.com/SAP/abap-to-json) version of it
- Using [xco_cp_json](https://help.sap.com/docs/btp/sap-business-technology-platform/json)

| Method                                                       | Features                                                                                                                                                                                                                                                         |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Identity Transformation** (`CALL TRANSFORMATION JSON`)     | ✅ Standard SAP approach <br> ✅ Very fast <br> ✅ Supports deep structures <br> ❌ Limited flexibility for custom parsing                                                                                                                                       |
| **sXML Library** (`cl_sxml_string_writer`, `cl_sxml_parser`) | ✅ Fine-grained control over parsing/rendering <br> ✅ Handles large JSON streams efficiently <br> ✅ Supports custom serialization logic <br> ❌ Requires manual parsing and handling of JSON nodes <br> ❌ More complex to implement compared to other methods |
| **/UI2/CL_JSON** (or `Z_UI2_JSON`)                           | ✅ Easy to use, with automatic conversion <br> ✅ Supports deep and complex structures <br> ✅ Open-source alternative available (`Z_UI2_JSON`) <br> ❌ Performance overhead for large datasets <br> ❌ No built-in streaming support                            |
| **XCO_CP_JSON** (`xco_cp_json`)                              | ✅ Modern, officially supported API for Cloud <br> ✅ Supports automatic serialization/deserialization <br> ✅ Type-safe operations <br> ❌ Not available in older on-premise systems                                                                            |

Here you can find a very good [article](https://community.sap.com/t5/application-development-blog-posts/abap-fast-json-serialization/ba-p/13556816) about some of these methods

Unfortunately I was not please with any of approaches and decided to create an own library implementing following features:

- Using standard identity transformation supporting all available types mapping automatically
- Automatic `camelCase` <-> `CAMEL_CASE` conversion for property names
- Suppress initital components ( feature of identity transformation )
- Allowing to use own conversion rules

## ZCL_JSON

### Render JSON

```abap
" render binary
data(json_binary) = zcl_json=>render( your_any_variable )
" or stringify (same but as string)
data(json_string) = zcl_json=>render( your_any_variable )
```

### Parse JSON

```abap
" Parsing requires two steps
zcl_json=>parse( json_binary_or_string )->to( ref #(  your_data_variable ) ).
```

## Dependencies

- [ZCL_ABAP_CASE](https://github.com/abapify/case)
