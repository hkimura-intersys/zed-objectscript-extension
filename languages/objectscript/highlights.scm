; -------------- Expression Highlights -------------


; Variables
; ^| e.g. '^||ppg', 'do', 'D'
; -----------------------------------------
(gvn) @variable.special
(ssvn) @variable.special
(lvn) @variable
(instance_variable) @variable.special

; String literals
; e.g. "Fo345349*_)(*_)8023841-40"" "
; -----------------------------------------
(string_literal) @string
(pattern_expression) @string.regex

; Operators
(_ operator: _ @operator)

; Numeric literals
; e.g. 12345
(numeric_literal) @number

; System variable name
; e.g. $IO, $SY[SYTEM]
(system_defined_variable) @function.builtin

; System defined functions
; e.g. $ASCII(62)
(system_defined_function) @function.builtin

(dollarsf
  ; $SYSTEM.Foo.Bar()
  (dollar_system_keyword) @function.builtin
  )

(property_name) @property
(parameter_name) @constant
(parameter_name) @variable.parameter

; Method invcoations
(class_method_call
  (class_ref (class_name) @type.definition)
  (method_name) @function.method.call
  )
(oref_method (method_name) @function.method.call)

(_ preproc_keyword: (_) @keyword.directive)
(_ modifier: (_) @keyword.directive)


; User-defined functions
(extrinsic_function) @function.call

; Goto labels and locations
(_ label: (_) @label)
(_ offset: (_) @number)
(_ routine: (_) @namespace)

; JSON literals
(json_boolean_literal) @boolean
(json_null_literal) @constant.builtin
(json_number_literal) @number
(json_string_literal) @string.escape

; Macros
(macro (macro_constant)) @constant.macro
(macro (macro_function)) @function.macro

(namespace_token) @namespace
(etrap_token) @etrap
(estack_token) @estack
(roles_token) @roles
; -------------- Objectscript Core -------------
; Commands
; e.g. 'set', 'do', 'D'
; -----------------------------------------
(_ command_name: (_) @keyword)

(_ macro_name: (_) @keyword.macro)
(_ macro_arg: (_) @constant.macro)
(_ mnemonic: (_) @constant.macro)

(_ parameter: _ @variable.parameter)

; Functions that can be on the LHS of a SET
(doable_dollar_functions) @function.builtin

; non-extrinsic routine call
(routine_tag_call) @function.call

; method call
(instance_method_call) @function.method.call

;; Technically elseif and else_block are not statements,
;; so we need ot query them explicitly
;(elseif_block command_name: (_) @keyword)
;(else_block command_name: (_) @keyword)

"{" @punctuation.bracket
"}" @punctuation.bracket

; Comments
; e.g. '// fj;lkasdfj', '#; sklfjas;k', '; sklfjas','/* sdfs */'
[
  (line_comment_1)
  (line_comment_2)
  (line_comment_3)
  (block_comment)
  ] @comment

(embedded_html
  (keyword_embedded_html) @keyword.directive
  "<" @keyword.directive
  ">" @keyword.directive
  )

(embedded_html
  (keyword_embedded_html) @keyword.directive
  (html_marker) @marker
  "<" @keyword.directive
  ">" @keyword.directive
  (html_marker_reversed) @marker
  )

(embedded_sql_amp
  (keyword_embedded_sql_amp) @keyword.directive
  "(" @keyword.directive
  ")" @keyword.directive
  ) @embedded_sql

(embedded_sql_amp
  (keyword_embedded_sql_amp) @keyword.directive
  (embedded_sql_marker) @marker
  "(" @keyword.directive
  ")" @keyword.directive
  (embedded_sql_reverse_marker) @marker
  ) @embedded_sql

(embedded_sql_hash
  (keyword_embedded_sql_hash) @keyword.directive
  "(" @keyword.directive
  ")" @keyword.directive
  ) @embedded_sql
(embedded_js
  (html_marker) @marker
  "<" @keyword.directive
  (embedded_js_special_case) @js_bod
  ">" @keyword.directive
  (embedded_js_special_case_complete) @marker
  ) @embeddedJS

(embedded_js
  "<" @keyword.directive
  ">" @keyword.directive
  )@embeddedJS

(embedded_xml
  (keyword_embedded_xml) @keyword.directive
  "<" @keyword.directive
  ">" @keyword.directive
  )

(tag) @label

; Lock type specifications
(locktype) @type.qualifier
(_read_prompt) @readprompt

; ------------------ UDL -------------------

; CLASS HIGHLIGHTING
(class_definition
  class_name: (identifier) @type
  (class_extends (identifier) @type)?)
(class_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

(_ keyword: (_) @keyword)
(keyword_not) @Not

;for import, include, includegenerator
(include_clause (identifier) @import)


"{" @punctuation.bracket
"}" @punctuation.bracket

; METHOD HIGHLIGHTING
(method_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))
; codemode=expression
(method_keyword_codemode_expression
  (identifier) @key
  (rhs)? @rhs)
; external languages
(method_keyword_language
  (identifier) @key
  (rhs)? @rhs)
; call method keyword
(call_method_keyword
  (identifier) @key
  (rhs)? @rhs)
; method definition
(method_definition
  (identifier) @method_name
  (arguments)? @method_arguments
  ) @method
(expression_method_body_content) @body
(core_method_body_content) @body
(external_method_body_content) @body

; PROPERTY HIGHLIGHTING
(property (identifier) @property)
(property_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

; PARAMETER HIGHLIGHTING
(parameter (identifier) @constant)
(default_argument_value) @rhs
(parameter_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))
(parameter_type) @type

; types and comments
(typename) @type
(documatic_line) @comment.doc

; RELATIONSHIP HIGHLIGHTING
(relationship (identifier) @relationship)
(relationship_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

; FOREIGNKEY HIGHLIGHTING
(foreignkey (identifier) @type.definition)
(foreignkey_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

; QUERY HIGHLIGHTING
(query (identifier) @function)
(query_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

(query_body_content) @body

; INDEX HIGHLIGHTING
(index (identifier) @type.definition)
(index_properties) @index_properties
(index_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))
(index_keyword_extent) @key

;TRIGGER HIGHLIGHTING
(trigger (identifier) @type.definition)
(trigger_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))

; XDATA HIGHLIGHTING
(xdata (identifier) @constant)
(xdata_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))
(xdata_keyword_mimetype
  (
    (identifier) @key
    (rhs)? @rhs))
(xdata_body_content_xml) @body
(xdata_body_content_any) @body

; PROJECTION HIGHLIGHTING
(projection (identifier) @type.definition)
(projection_keyword
  (_
    (identifier) @key
    (rhs)? @rhs))
; STORAGE HIGHLIGHTING
(storage (identifier) @type.definition)
(storage_body_content) @body
