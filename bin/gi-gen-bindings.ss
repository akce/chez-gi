#! /usr/bin/chez-scheme --script

;; Generate Chez scheme bindings for libraries that support gobject introspection.

(suppress-greeting #t)

(import
 (chezscheme)
 (gi))

(define lib-name
  (make-parameter #f))

(define lib-version
  (make-parameter #f))

(define print-usage
  (lambda ()
    (format #t "Usage: ~a <path-to-typelib>~n" (car (command-line)))))

(define print-deps
  (lambda ()
    (format #t "~a-~a depends on: ~a~n"
            (lib-name)
            (if (lib-version) (lib-version) (g-irepository-get-version (lib-name)))
            (sort string<? (g-irepository-get-dependencies (lib-name))))))

;; Get all the gibase data pointers for lib-name.
(define get-ptrs
  (lambda ()
    (let* ([name (lib-name)]
           [nums (g-irepository-get-n-infos name)])
      (map
       (lambda (i)
         (g-irepository-get-info name i))
       (iota nums)))))

(define args-version
  (lambda (args)
    (cond
     [(fx>? (length args) 1)
      (list-ref args 1)]
     [else
      #f])))

(define type-filter
  (lambda (sym records)
    (filter (lambda (x) (eq? sym (car x))) records)))

;; consts: (list '(name-string value) ...)
(define make-const
  (lambda (ptr)
    (assert (eq? 'CONSTANT (g-base-info-get-type ptr)))
    (list (g-base-info-get-type ptr) (g-base-info-get-name ptr) (g-constant-get-value ptr))))

;; enums/flags: (list name-str '(value-name-str . value-int) ...)
(define make-enum-flags
  (lambda (ptr)
    ;; Flags are enums, but the value is the left shift amount. ie, 1 << value.
    (assert (or (eq? 'FLAGS (g-base-info-get-type ptr)) (eq? 'ENUM (g-base-info-get-type ptr))))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (get-n ptr g-enum-info-get-n-values g-enum-info-get-value)
     ;; TODO methods
     ;; TODO storage type
     ;; TODO error domain
     ;; TODO get value
     )))

(define make-struct
  (lambda (ptr)
    (assert (eq? 'STRUCT (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-struct-info-get-size ptr)
     (g-struct-info-get-alignment ptr)
     (g-struct-info-is-gtype-struct ptr)
     (get-n ptr g-struct-info-get-n-fields g-struct-info-get-field)
     ;; TODO methods
     #;(struct-methods ptr))))

(define make-value
  (lambda (ptr)
    (assert (eq? 'VALUE (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-value-info-get-value ptr))))

(define make-field
  (lambda (ptr)
    (assert (eq? 'FIELD (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-field-info-get-flags ptr)
     (g-field-info-get-offset ptr)
     (g-field-info-get-size ptr)
     (make (g-field-info-get-type ptr)))))

(define make-type
  (lambda (ptr)
    (assert (eq? 'TYPE (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-type-info-get-tag ptr)		; Does this differ from the base type tag?
     (g-type-info-pointer? ptr)
     (case (g-type-info-get-tag ptr)
       [(INTERFACE)
        ;; TODO "make" -> make-interface
        (list (g-type-info-get-interface ptr))]
       [ARRAY
        (append
         (list (g-type-info-get-array-type ptr))
         ;; TODO integrate these into "make"?
         (case (g-type-info-get-array-type ptr)
           [(C ARRAY PTR_ARRAY BYTE_ARRAY)
            (list
             (g-type-info-get-array-type ptr)
             (g-type-info-get-array-length ptr)
             (g-type-info-get-array-fixed-size ptr)
             (g-type-info-zero-terminated? ptr))]
           [else
            (list ptr)]))]
       [else
        'ATOM]))))

(define get-n
  (lambda (ptr n-func get-func)
    (map (lambda (i)
           (make (get-func ptr i)))
         (iota (n-func ptr)))))

(define make-unhandled
  (lambda (ptr)
    (list
     'TODO
     (g-base-info-get-type ptr)
     ptr)))

(define make
  (lambda (ptr)
    ((get-factory-func ptr) ptr)))

(define get-factory-func
  (lambda (ptr)
    (case (g-base-info-get-type ptr)
      [(CONSTANT)	make-const]
      [(ENUM FLAGS)	make-enum-flags]
      [(FIELD)		make-field]
      [(STRUCT)		make-struct]
      [(TYPE)		make-type]
      [(VALUE)		make-value]
      [else		make-unhandled])))

(let ([args (command-line-arguments)])
  (when (null? args)
    (print-usage)
    (exit 1))
  (lib-name (car args))
  (lib-version (args-version args)))

(g-irepository-require (lib-name) (lib-version))
(print-deps)
;; Create some debug test vars here.
(define records (map make (get-ptrs)))
(define consts (type-filter 'CONSTANT records))
(define enums (type-filter 'ENUM records))
(define flags (type-filter 'FLAGS records))
(define structs (type-filter 'STRUCT records))
(define todos (type-filter 'TODO records))
(new-cafe)
