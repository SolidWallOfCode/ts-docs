schema =
{
   ['$schema']= "http://trafficsever.apache.org/config/meta-schema",
   description = "Lua Configuration MetaSchema",
   global = 'schema',
   class = 'TsLuaMetaConfig',

   properties = {
      ['$schema'] = {
         type= "string",
         description= "Schema identifier."
      },
      description = {
         type= "string",
         description= "Description of the schema.",
      },
      global = {
         type = 'string',
         description = 'Lua global variable in which the schema will be stored.'
      },
      class = {
         type = 'string',
         description = 'C++ class for configuration.'
      },
      properties = {
         type = 'object',
         description = 'The members of the object.',
         additionalProperties = true,
         minProperties = 1,
         properties = {}
      },
      items = {
         type = 'object',
         description = 'The items in the array.',
         additionalItems = true,
         minItems = 1,
         items = {}
      },
      dependencies = {
         type = OBJECT,
         description = 'List of optional properties for an object.'
      },
      one_of = {
         type = OBJECT,
         description = 'Set of mutually exclusive properties, exactly one of which must be present.',
         items = STRING
      },
      definitions = {
         type = 'array',
         description = 'Sub schema definitions.',
         items = {
            type = 'object',
            description = 'Description of the definition.',
            additionalProperties = true
         }
      }
   },
   dependencies = {
      properties = {
         ['not'] = {
            required = { 'items' }
         },
      items = {
         ['not'] = {
            required = { 'properties' }
         }
      }
   },
   definitions = {
      object = {
        class = {
         type = STRING,
         description = 'C++ struct name.'
        },
        description = {
         type = STRING,
         description = 'Object description.'
        },
        properties = {
            ['$ref'] = '#/definitions/object'
        }
      },
      --[[
         It should be possible to specify how to set up an enumeration with just an array,
         filling the other values with defaults. E.g. an array of strings or an array of integers.
      ]]
      enum = {
         type = OBJECT,
         typeName = 'EnumType',
         description = 'Enumeration',
         properties = {
            typeName = {
               type = 'string',
               description = 'C++ type name.'
            },
            global = {
               type = STRING,
               description = 'Global variable that contains the enumeration values.'
            },
            kv = {
               type = ARRAY,
               description = 'Enumeration keys and values',
               items = {
                  type = 'object',
                  description = 'Enumeration value',
                  properties = {
                     key = {
                        type = 'string',
                        description = 'Enumeration key'
                     },
                     value = {
                        type = 'integer',
                        description = 'Enumeration value'
                     },
                     description = {
                        type = 'string',
                        description = 'Meaning of this value'
                     }
                  }
               }
            }
         }
      },
      ValueType = {
         type = ENUM,
         typeName = 'ValueType',
         description = 'Type of data',
         global = '.',
         kv = {
            {
               key = 'nil',
               value = 0,
               description = 'Null / invalid value.'
            },
            {
               key = 'boolean',
               value = 1,
               description = 'Boolean (true/false) value.'
            },
            {
               key = 'string',
               value = 2,
               description = 'String value.'
            },
            {
               key = 'integer',
               value = 3,
               description = 'Integral value.'
            },
            {
               key = 'number',
               value = 4,
               description = 'Numeric value.'
            },
            {
               key = 'object',
               value = 5,
               description = 'Object - collection of key / value pairs.'
            },
            {
               key = 'array',
               value = 6,
               description = 'Array of values.'
            },
            {
               key = 'enum',
               value = 7,
               description = 'Enumeration'
            }
         }
      }
   }
}
