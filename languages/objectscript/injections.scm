; SQL and HTML Injections

(embedded_html
  (angled_bracket_fenced_text) @injection.content
  (#set! injection.language "html")
  ;; TODO: Investigate if we can use html as the fallback grammar
  ;; We REALLY need to make it easy for users to bundle all of these
  ;; grammars
  )

(embedded_sql
  (_
    (paren_fenced_text) @injection.content
    )
  (#set! injection.language "sql")
  )

(embedded_js
  (angled_bracket_fenced_text) @injection.content
  (#set! injection.language "javascript")
  )

(embedded_xml
  (angled_bracket_fenced_text) @injection.content
  (#set! injection.language "xml")
  )

([
   (line_comment_1)
   (line_comment_2)
   (line_comment_3)
   (block_comment)
   ] @injection.content
  (#set! injection.language "comment"))

; Target method_body_content and reparse it using
; objectscript_core
;

((documatic_line) @injection.content
  (#set! injection.language "comment")
  )

;; Keywords, one of type language = "python", none of type codemode
; External method body injection based on [ Language = ... ]
(method_definition
  keywords: (external_method_keywords
              (method_keyword_language
                (rhs) @lang))
  body: (external_method_body_content) @injection.content
  (#set! injection.include-children "true")
  (#match? @lang "(?i)^python$")
  (#set! injection.language "python"))

(method_definition
  keywords: (external_method_keywords
              (method_keyword_language
                (rhs) @lang))
  body: (external_method_body_content) @injection.content
  (#set! injection.include-children "true")
  (#match? @lang "(?i)^tsql$")
  (#set! injection.language "tsql"))

(method_definition
  keywords: (external_method_keywords
              (method_keyword_language
                (rhs) @lang))
  body: (external_method_body_content) @injection.content
  (#set! injection.include-children "true")
  (#match? @lang "(?i)^javascript$")
  (#set! injection.language "ispl"))



;; External trigger with python body
(
  (trigger
    (trigger_keywords
      (method_keyword_language) @lang)
    (external_method_body_content) @injection.content)
  (#match? @lang "python")
  (#set! injection.language "python")
  )

;; External trigger with TSQL body
(
  (trigger
    (trigger_keywords
      (method_keyword_language) @lang)
    (external_method_body_content) @injection.content)
  (#match? @lang "tsql")
  (#set! injection.language "tsql")
  )

; A query must be of type %SQLQuery to have an SQL body, otherwise the body
; is empty
(query
  type: (_ (typename (identifier) @_querytype (#eq? @_querytype "%SQLQuery")))
  (_ (query_body_content) @injection.content)
  (#set! injection.language "sql")
  (#set! injection.include-children "true")
  )

; XDATA blocks.  There's a MimeType keyword that defines the content-type
; To prevent overlapping matches, we use a different body for the case where
; no MimeType is given and default to XML, otherwise we extract the language
; from the mimetype.

; ----------------------------
; XDATA injections (MimeType)
; ----------------------------

; text/markdown
(xdata
  keywords: (xdata_keywords
              (xdata_keyword_mimetype (rhs) @mt))
  body: (xdata_body_content_any) @injection.content
  (#set! injection.include-children "true")
  (#match? @mt "^\"text/markdown\"$")
  (#set! injection.language "markdown"))

; text/xml
(xdata
  keywords: (xdata_keywords
              (xdata_keyword_mimetype (rhs) @mt))
  body: (xdata_body_content_any) @injection.content
  (#set! injection.include-children "true")
  (#match? @mt "^\"text/xml\"$")
  (#set! injection.language "xml"))

; text/html
(xdata
  keywords: (xdata_keywords
              (xdata_keyword_mimetype (rhs) @mt))
  body: (xdata_body_content_any) @injection.content
  (#set! injection.include-children "true")
  (#match? @mt "^\"text/html\"$")
  (#set! injection.language "html"))

; application/json
(xdata
  keywords: (xdata_keywords
              (xdata_keyword_mimetype (rhs) @mt))
  body: (xdata_body_content_any) @injection.content
  (#set! injection.include-children "true")
  (#match? @mt "^\"application/json\"$")
  (#set! injection.language "json"))

; text/css
(xdata
  keywords: (xdata_keywords
              (xdata_keyword_mimetype (rhs) @mt))
  body: (xdata_body_content_any) @injection.content
  (#set! injection.include-children "true")
  (#match? @mt "^\"text/css\"$")
  (#set! injection.language "css"))

; -----------------------------------------
; XDATA default (no MimeType): XML fallback
; -----------------------------------------
(xdata
  body: (xdata_body_content_xml) @injection.content
  (#set! injection.include-children "true")
  (#set! injection.language "xml"))

; Storage definition is XML
(storage
  body: (_) @injection.content
  (#set! injection.language "xml")
  (#set! injection.include-children "true")
  )
