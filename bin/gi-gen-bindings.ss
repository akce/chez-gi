#! /usr/bin/chez-scheme --script

;; Generate Chez scheme bindings for libraries that support gobject introspection.

(suppress-greeting #t)

(import
 (chezscheme)
 (gi c))

(define lib-name
  (make-parameter #f))

(define lib-version
  (make-parameter #f))

(define print-usage
  (lambda ()
    (format #t "Usage: ~a lib-name [lib-version]~n" (car (command-line)))))

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

(define get-callable-info
  (lambda (ptr)
    (list
     (get-n ptr g-callable-info-get-n-args g-callable-info-get-arg)
     (g-callable-info-get-caller-owns ptr)
     (g-callable-info-get-instance-ownership-transfer ptr)
     (make (g-callable-info-get-return-type ptr))
     (g-callable-info-method? ptr)
     (g-callable-info-may-return-null? ptr)
     (g-callable-info-skip-return? ptr))))

(define make-arg
  (lambda (ptr)
    (assert (eq? 'ARG (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (make (g-arg-info-get-type ptr))
     (g-arg-info-get-closure ptr)	; CALLBACK only
     (g-arg-info-get-destroy ptr)	; CALLBACK only
     (g-arg-info-get-direction ptr)
     (g-arg-info-get-ownership-transfer ptr)
     (g-arg-info-get-scope ptr)
     (g-arg-info-may-be-null? ptr)
     (g-arg-info-caller-allocates? ptr)
     (g-arg-info-optional? ptr)
     (g-arg-info-return-value? ptr)
     (g-arg-info-skip? ptr))))

(define make-callback
  (lambda (ptr)
    (assert (eq? 'CALLBACK (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (get-callable-info ptr))))

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
     (get-n ptr g-enum-info-get-n-methods g-enum-info-get-method)
     (g-enum-info-get-storage-type ptr))))

(define make-signal
  (lambda (ptr)
    (assert (eq? 'SIGNAL (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-signal-info-get-flags ptr)
     (make (g-signal-info-get-class-closure ptr))
     (g-signal-info-true-stops-emit? ptr))))

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
     (get-n ptr g-struct-info-get-n-methods g-struct-info-get-method))))

(define make-value
  (lambda (ptr)
    (assert (eq? 'VALUE (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-value-info-get-value ptr))))

(define make-vfunc
  (lambda (ptr)
    (assert (eq? 'VFUNC (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (get-callable-info ptr)
     (g-vfunc-info-get-flags ptr)
     (g-vfunc-info-get-offset ptr)
     (g-vfunc-info-get-signal ptr)
     (make (g-vfunc-info-get-invoker ptr))
     #;(g-vfunc-info-get-address ptr))))

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

(define make-function
  (lambda (ptr)
    (assert (eq? 'FUNCTION (g-base-info-get-type ptr)))
    (let ([flags (g-function-info-get-flags ptr)])
      (list
       (g-base-info-get-type ptr)
       (g-base-info-get-name ptr)
       (get-callable-info ptr)
       flags
       (cond
        [(or (memq 'GETTER flags) (memq 'SETTER flags))
         (make-unhandled (g-function-info-get-property ptr))]
        [else
         '()])
       (g-function-info-get-symbol ptr)	; Exported C symbol name.
       (cond
        [(memq 'WRAPS_VFUNC flags)
         (make (g-function-info-get-vfunc ptr))]
        [else
         '()])))))

(define make-interface
  (lambda (ptr)
    (assert (eq? 'INTERFACE (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (get-n ptr g-interface-info-get-n-prerequisites g-interface-info-get-prerequisite)
     (get-n ptr g-interface-info-get-n-properties g-interface-info-get-property)
     (get-n ptr g-interface-info-get-n-methods g-interface-info-get-method)
     (get-n ptr g-interface-info-get-n-signals g-interface-info-get-signal)
     (get-n ptr g-interface-info-get-n-vfuncs g-interface-info-get-vfunc)
     (get-n ptr g-interface-info-get-n-constants g-interface-info-get-constant)
     (make (g-interface-info-get-iface-struct ptr)))))

(define make-object
  (lambda (ptr)
    (assert (eq? 'OBJECT (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-object-info-get-abstract ptr)
     (g-object-info-get-fundamental ptr)
     (make (g-object-info-get-parent ptr))
     (g-object-info-get-type-name ptr)	; Includes lib prefix. eg, VBox -> GtkVBox.
     (g-object-info-get-type-init ptr)
     (get-n ptr g-object-info-get-n-constants g-object-info-get-constant)
     (get-n ptr g-object-info-get-n-fields g-object-info-get-field)
     (get-n ptr g-object-info-get-n-interfaces g-object-info-get-interface)
     (get-n ptr g-object-info-get-n-methods g-object-info-get-method)
     (get-n ptr g-object-info-get-n-properties g-object-info-get-property)
     (get-n ptr g-object-info-get-n-signals g-object-info-get-signal)
     (get-n ptr g-object-info-get-n-vfuncs g-object-info-get-vfunc)
     (make (g-object-info-get-class-struct ptr)))))

(define make-property
  (lambda (ptr)
    (assert (eq? 'PROPERTY (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-property-info-get-flags ptr)
     (g-property-info-get-ownership-transfer ptr)
     (make (g-property-info-get-type ptr)))))

(define make-type
  (lambda (ptr)
    (assert (eq? 'TYPE (g-base-info-get-type ptr)))
    (list
     (g-base-info-get-type ptr)
     (g-base-info-get-name ptr)
     (g-type-info-get-tag ptr)		; The actual type that this TYPE record contains.
     (g-type-info-pointer? ptr)
     (case (g-type-info-get-tag ptr)
       [INTERFACE
        ;; TODO "make" -> make-interface
        ;; TODO using make exhausts memory (cyclic ref?) so leave till i understand what an interface is..
        (make-unhandled (g-type-info-get-interface ptr))]
       [ARRAY
        (append
         (list (g-type-info-get-array-type ptr))
         (case (g-type-info-get-array-type ptr)
           [(C ARRAY PTR_ARRAY BYTE_ARRAY)
            (list
             (g-type-info-get-array-type ptr)
             (g-type-info-get-array-length ptr)
             (g-type-info-get-array-fixed-size ptr)
             (g-type-info-zero-terminated? ptr))]
           [else
            '()]))]
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
     (g-base-info-get-name ptr)
     ptr)))

(define make
  (lambda (ptr)
    (if (fx=? ptr 0)
      'NULL
      (let ([x ((get-factory-func ptr) ptr)])
        #;(pretty-print x)
        ;; Only TODO (unhandled) items keep the ptr so that they can be experimented on.
        ;; All other types are freed.
        (unless (eq? 'TODO (car x))
          (g-base-info-unref ptr))
        x))))

(define get-factory-func
  (lambda (ptr)
    (case (g-base-info-get-type ptr)
      [ARG		make-arg]
      [CALLBACK		make-callback]
      [CONSTANT		make-const]
      [(ENUM FLAGS)	make-enum-flags]
      [FIELD		make-field]
      [FUNCTION		make-function]
      [INTERFACE	make-interface]
      [OBJECT		make-object]
      [PROPERTY		make-property]
      [SIGNAL		make-signal]
      [STRUCT		make-struct]
      [TYPE		make-type]
      [VALUE		make-value]
      [VFUNC		make-vfunc]
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
#;(define records (map (lambda (x) (display "TOPLEVEL")(newline)(make x)) (get-ptrs)))
(define records (map make (get-ptrs)))
(define callbacks (type-filter 'CALLBACK records))
(define consts (type-filter 'CONSTANT records))
(define enums (type-filter 'ENUM records))
(define flags (type-filter 'FLAGS records))
(define funcs (type-filter 'FUNCTION records))
(define interfaces (type-filter 'INTERFACE records))
(define objects (type-filter 'OBJECT records))
(define structs (type-filter 'STRUCT records))
(define todos (type-filter 'TODO records))
(new-cafe)
