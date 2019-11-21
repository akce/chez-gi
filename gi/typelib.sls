;; Higher level (non-C) interface for gobject introspection types.
;;
;; Includes repository loading, and record creation.
;;
;; https://developer.gnome.org/gi/stable/gi-struct-hierarchy.html
;;
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense

(library (gi typelib)
  (export
   load-typelib typelib-version typelib-dependencies typelib-records
   type-filter
   )
  (import
   (chezscheme)
   (gi c))

  (define load-typelib
    (lambda (n v)
      (g-irepository-require n v)))

  ;;;; Type records and their builders etc.

  (define typelib-version
    (lambda (lib-name)
      (g-irepository-get-version lib-name)))

  (define typelib-dependencies
    (lambda (lib-name)
      (g-irepository-get-dependencies lib-name)))

  (define typelib-records
    (lambda (lib-name)
      (map build (get-ptrs lib-name))))

  (define-record-type base
    (fields
     type
     name))

  (define base-fields
    (lambda (ptr)
      (list
       (g-base-info-get-type ptr)
       (g-base-info-get-name ptr))))

  (define-record-type callable
    (parent base)
    (fields
     args
     caller-owns
     instance-ownership-transfer
     return-type
     method
     may-return-null
     skip-return))

  (define callable-fields
    (lambda (ptr)
      (list
       (get-n ptr g-callable-info-get-n-args g-callable-info-get-arg)
       (g-callable-info-get-caller-owns ptr)
       (g-callable-info-get-instance-ownership-transfer ptr)
       (build (g-callable-info-get-return-type ptr))
       (g-callable-info-method? ptr)
       (g-callable-info-may-return-null? ptr)
       (g-callable-info-skip-return? ptr))))

  (define-record-type arg
    (parent base)
    (fields
     type
     closure
     destroy
     direction
     ownership-transfer
     scope
     may-be-null
     caller-allocates
     optional
     return-value
     skip))

  (define build-arg
    (lambda (ptr)
      (assert (eq? 'ARG (g-base-info-get-type ptr)))
      (apply
       make-arg
       (append
        (base-fields ptr)
        (arg-fields ptr)))))

  (define arg-fields
    (lambda (ptr)
      (list
       (build (g-arg-info-get-type ptr))
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

  (define-record-type callback
    (parent callable))

  (define build-callback
    (lambda (ptr)
      (assert (eq? 'CALLBACK (g-base-info-get-type ptr)))
      (apply
       make-callback
       (append
        (base-fields ptr)
        (callable-fields ptr)))))

  (define-record-type const
    (parent base)
    (fields
     value))

  (define build-const
    (lambda (ptr)
      (assert (eq? 'CONSTANT (g-base-info-get-type ptr)))
      (apply
       make-const
       (append
        (base-fields ptr)
        (const-fields ptr)))))

  (define const-fields
    (lambda (ptr)
      (list
       (g-constant-get-value ptr))))

  ;; Flags are enums, but the value is the left shift amount. ie, 1 << value.
  (define-record-type enum-flags
    (parent base)
    (fields
     values
     methods
     storage-type))

  (define build-enum-flags
    (lambda (ptr)
      (assert (or (eq? 'FLAGS (g-base-info-get-type ptr)) (eq? 'ENUM (g-base-info-get-type ptr))))
      (apply
       make-enum-flags
       (append
        (base-fields ptr)
        (get-n ptr g-enum-info-get-n-values g-enum-info-get-value)
        (get-n ptr g-enum-info-get-n-methods g-enum-info-get-method)
        (list
         (g-enum-info-get-storage-type ptr))))))

  (define-record-type field
    (parent base)
    (fields
     flags
     offset
     size
     type))

  (define build-field
    (lambda (ptr)
      (assert (eq? 'FIELD (g-base-info-get-type ptr)))
      (apply
       make-field
       (append
        (base-fields ptr)
        (field-fields ptr)))))

  (define field-fields
    (lambda (ptr)
      (list
       (g-field-info-get-flags ptr)
       (g-field-info-get-offset ptr)
       (g-field-info-get-size ptr)
       (build (g-field-info-get-type ptr)))))

  (define-record-type function
    (parent callable)
    (fields
     flags
     property
     symbol
     vfunc))

  (define function-fields
    (lambda (ptr)
      (let ([flags (g-function-info-get-flags ptr)])
        (list
         flags
         (cond
          [(or (memq 'GETTER flags) (memq 'SETTER flags))
           (build-unhandled (g-function-info-get-property ptr))]
          [else
           '()])
         (g-function-info-get-symbol ptr)	; Exported C symbol name.
         (cond
          [(memq 'WRAPS_VFUNC flags)
           (build (g-function-info-get-vfunc ptr))]
          [else
           '()])))))

  (define build-function
    (lambda (ptr)
      (assert (eq? 'FUNCTION (g-base-info-get-type ptr)))
      (apply
       make-function
       (append
        (base-fields ptr)
        (callable-fields ptr)
        (function-fields ptr)))))

  (define-record-type interface
    (parent base)
    (fields
     prerequisites
     properties
     methods
     signals
     vfuncs
     constants
     iface-struct))

  (define build-interface
    (lambda (ptr)
      (assert (eq? 'INTERFACE (g-base-info-get-type ptr)))
      (apply
       make-interface
       (append
        (base-fields ptr)
        (interface-fields ptr)))))

  (define interface-fields
    (lambda (ptr)
      (list
       (get-n ptr g-interface-info-get-n-prerequisites g-interface-info-get-prerequisite)
       (get-n ptr g-interface-info-get-n-properties g-interface-info-get-property)
       (get-n ptr g-interface-info-get-n-methods g-interface-info-get-method)
       (get-n ptr g-interface-info-get-n-signals g-interface-info-get-signal)
       (get-n ptr g-interface-info-get-n-vfuncs g-interface-info-get-vfunc)
       (get-n ptr g-interface-info-get-n-constants g-interface-info-get-constant)
       (build (g-interface-info-get-iface-struct ptr)))))

  (define-record-type object
    (parent base)
    (fields
     abstract
     fundamental
     parent
     type-name
     type-init
     constants
     fields
     interfaces
     methods
     properties
     signals
     vfuncs
     class-struct))

  (define build-object
    (lambda (ptr)
      (assert (eq? 'OBJECT (g-base-info-get-type ptr)))
      (apply
       make-object
       (append
        (base-fields ptr)
        (build-object-fields ptr)))))

  (define build-object-fields
    (lambda (ptr)
      (list
       (g-object-info-get-abstract ptr)
       (g-object-info-get-fundamental ptr)
       (build (g-object-info-get-parent ptr))
       (g-object-info-get-type-name ptr)	; Includes lib prefix. eg, VBox -> GtkVBox.
       (g-object-info-get-type-init ptr)
       (get-n ptr g-object-info-get-n-constants g-object-info-get-constant)
       (get-n ptr g-object-info-get-n-fields g-object-info-get-field)
       (get-n ptr g-object-info-get-n-interfaces g-object-info-get-interface)
       (get-n ptr g-object-info-get-n-methods g-object-info-get-method)
       (get-n ptr g-object-info-get-n-properties g-object-info-get-property)
       (get-n ptr g-object-info-get-n-signals g-object-info-get-signal)
       (get-n ptr g-object-info-get-n-vfuncs g-object-info-get-vfunc)
       (build (g-object-info-get-class-struct ptr)))))

  (define-record-type property
    (parent base)
    (fields
     flags
     ownership-transfer
     type))

  (define build-property
    (lambda (ptr)
      (assert (eq? 'PROPERTY (g-base-info-get-type ptr)))
      (apply
       make-property
       (append
        (base-fields ptr)
        (property-fields ptr)))))

  (define property-fields
    (lambda (ptr)
      (list
       (g-property-info-get-flags ptr)
       (g-property-info-get-ownership-transfer ptr)
       (build (g-property-info-get-type ptr)))))

  (define-record-type signal
    (parent base)
    (fields
     flags
     class-closure
     true-stops-emit))

  (define build-signal
    (lambda (ptr)
      (assert (eq? 'SIGNAL (g-base-info-get-type ptr)))
      (apply
       make-signal
       (append
        (base-fields ptr)
        (signal-fields ptr)))))

  (define signal-fields
    (lambda (ptr)
      (list
       (g-signal-info-get-flags ptr)
       (build (g-signal-info-get-class-closure ptr))
       (g-signal-info-true-stops-emit? ptr))))

  (define-record-type struct
    (parent base)
    (fields
     size
     alignment
     is-gtype-struct
     fields
     methods))

  (define build-struct
    (lambda (ptr)
      (assert (eq? 'STRUCT (g-base-info-get-type ptr)))
      (apply
       make-struct
       (append
        (base-fields ptr)
        (build-struct-fields ptr)))))

  (define build-struct-fields
    (lambda (ptr)
      (list
       (g-struct-info-get-size ptr)
       (g-struct-info-get-alignment ptr)
       (g-struct-info-is-gtype-struct ptr)
       (get-n ptr g-struct-info-get-n-fields g-struct-info-get-field)
       (get-n ptr g-struct-info-get-n-methods g-struct-info-get-method))))

  (define-record-type type
    (parent base)
    (fields
     tag	; The underlying type that this TYPE record contains.
     pointer
     interface
     array))

  (define-record-type subtype-array
    (fields
     type
     length
     fixed-size
     zero-terminated))

  (define build-type
    (lambda (ptr)
      (assert (eq? 'TYPE (g-base-info-get-type ptr)))
      (let ([tag (g-type-info-get-tag ptr)])
        (apply
         make-type
         (append
          (base-fields ptr)
          (list
           tag
           (g-type-info-pointer? ptr)
           (type-interface-field ptr tag)
           (subtype-array-field ptr tag)))))))

  (define type-interface-field
    (lambda (ptr tag)
      (case tag
        [INTERFACE
         ;; TODO "build" -> build-interface
         ;; TODO using build exhausts memory (cyclic ref?) so leave till i understand what an interface is..
         (build-unhandled (g-type-info-get-interface ptr))]
        [else
         #f])))

  (define subtype-array-field
    (lambda (ptr tag)
      (case tag
        [ARRAY
         (let ([array-tag (g-type-info-get-array-type ptr)])
           (case array-tag
             [(C ARRAY PTR_ARRAY BYTE_ARRAY)
              (make-subtype-array
               array-tag
               (g-type-info-get-array-length ptr)
               (g-type-info-get-array-fixed-size ptr)
               (g-type-info-zero-terminated? ptr))]
             [else
              #f]))]
        [else
         #f])))

  (define-record-type value
    (parent base)
    (fields
     value))

  (define build-value
    (lambda (ptr)
      (assert (eq? 'VALUE (g-base-info-get-type ptr)))
      (apply
       make-value
       (append
        (base-fields ptr)
        (value-fields ptr)))))

  (define value-fields
    (lambda (ptr)
      (list
       (g-value-info-get-value ptr))))

  (define-record-type vfunc
    (parent callable)
    (fields
     flags
     offset
     signal
     invoker))

  (define build-vfunc
    (lambda (ptr)
      (assert (eq? 'VFUNC (g-base-info-get-type ptr)))
      (apply
       make-vfunc
       (append
        (base-fields ptr)
        (callable-fields ptr)
        (vfunc-fields ptr)))))

  (define vfunc-fields
    (lambda (ptr)
      (list
       (g-vfunc-info-get-flags ptr)
       (g-vfunc-info-get-offset ptr)
       (g-vfunc-info-get-signal ptr)
       (build (g-vfunc-info-get-invoker ptr)))))

  ;; Builder functions.

  (define build-unhandled
    (lambda (ptr)
      (list
       'TODO
       (g-base-info-get-type ptr)
       (g-base-info-get-name ptr)
       ptr)))

  (define build
    (lambda (ptr)
      (if (fx=? ptr 0)
          'NULL
          (let ([x ((get-build-func ptr) ptr)])
            #;(pretty-print x)
            ;; Only TODO (unhandled) items keep the ptr so that they can be experimented on.
            ;; All other types are freed.
            (unless (eq? 'TODO (base-type x))
              (g-base-info-unref ptr))
            x))))

  (define get-build-func
    (lambda (ptr)
      (case (g-base-info-get-type ptr)
        [ARG		build-arg]
        [CALLBACK	build-callback]
        [CONSTANT	build-const]
        [(ENUM FLAGS)	build-enum-flags]
        [FIELD		build-field]
        [FUNCTION	build-function]
        [INTERFACE	build-interface]
        [OBJECT		build-object]
        [PROPERTY	build-property]
        [SIGNAL		build-signal]
        [STRUCT		build-struct]
        [TYPE		build-type]
        [VALUE		build-value]
        [VFUNC		build-vfunc]
        [else		build-unhandled])))

  ;; Utility functions.

  ;; Get all the gibase data pointers for lib-name.
  (define get-ptrs
    (lambda (name)
      (map
       (lambda (i)
         (g-irepository-get-info name i))
       (iota (g-irepository-get-n-infos name)))))

  (define get-n
    (lambda (ptr n-func get-func)
      (list
       (map
        (lambda (i)
          (build (get-func ptr i)))
        (iota (n-func ptr))))))

  (define type-filter
    (lambda (sym records)
      (filter (lambda (x) (eq? sym (base-type x))) records)))
)
