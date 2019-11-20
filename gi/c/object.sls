;; https://developer.gnome.org/gi/stable/gi-GIObjectInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi c object)
  (export
   giobject giobjectreffunction giobjectunreffunction giobjectsetvaluefunction giobjectgetvaluefunction
   g-object-info-get-abstract
   g-object-info-get-fundamental
   g-object-info-get-parent
   g-object-info-get-type-name
   g-object-info-get-type-init
   g-object-info-get-n-constants
   g-object-info-get-constant
   g-object-info-get-n-fields
   g-object-info-get-field
   g-object-info-get-n-interfaces
   g-object-info-get-interface
   g-object-info-get-n-methods
   g-object-info-get-method
   g-object-info-find-method
   g-object-info-find-method-using-interfaces
   g-object-info-get-n-properties
   g-object-info-get-property
   g-object-info-get-n-signals
   g-object-info-get-signal
   g-object-info-find-signal
   g-object-info-get-n-vfuncs
   g-object-info-get-vfunc
   g-object-info-find-vfunc-using-interfaces
   g-object-info-get-class-struct
   g-object-info-get-ref-function
   g-object-info-get-ref-function-pointer
   g-object-info-get-unref-function
   g-object-info-get-unref-function-pointer
   g-object-info-get-set-value-function
   g-object-info-get-set-value-function-pointer
   g-object-info-get-get-value-function
   g-object-info-get-get-value-function-pointer)
  (import
   (rnrs)
   (gi c callable)
   (gi c constant)
   (gi c field)
   (gi c interface)
   (gi c property)
   (gi c struct)
   (gi c type)
   (gi c ftypes-util))

  (define load-library
    (lso))

  (define-ftype giobject void*)
  (define-ftype giobjectreffunction void*)
  (define-ftype giobjectunreffunction void*)
  (define-ftype giobjectsetvaluefunction void*)
  (define-ftype giobjectgetvaluefunction void*)

  (c-function
   (g-object-info-get-abstract (giobject) boolean)
   (g-object-info-get-fundamental (giobject) boolean)
   (g-object-info-get-parent (giobject) giobject)
   (g-object-info-get-type-name (giobject) string)
   (g-object-info-get-type-init (giobject) string)
   (g-object-info-get-n-constants (giobject) int)
   (g-object-info-get-constant (giobject int) giconstant)
   (g-object-info-get-n-fields (giobject) int)
   (g-object-info-get-field (giobject int) gifield)
   (g-object-info-get-n-interfaces (giobject) int)
   (g-object-info-get-interface (giobject int) giinterface)
   (g-object-info-get-n-methods (giobject) int)
   (g-object-info-get-method (giobject int) gifunction)
   (g-object-info-find-method (giobject string) gifunction)
   (g-object-info-find-method-using-interfaces (giobject string (* giobject)) gifunction)
   (g-object-info-get-n-properties (giobject) int)
   (g-object-info-get-property (giobject int) giproperty)
   (g-object-info-get-n-signals (giobject) int)
   (g-object-info-get-signal (giobject int) gisignal)
   (g-object-info-find-signal (giobject string) gisignal)
   (g-object-info-get-n-vfuncs (giobject) int)
   (g-object-info-get-vfunc (giobject int) givfunc)
   (g-object-info-find-vfunc-using-interfaces (giobject string (* giobject)) givfunc)
   (g-object-info-get-class-struct (giobject) gistruct)
   (g-object-info-get-ref-function (giobject) string)
   (g-object-info-get-ref-function-pointer (giobject) giobjectreffunction)
   (g-object-info-get-unref-function (giobject) string)
   (g-object-info-get-unref-function-pointer (giobject) giobjectunreffunction)
   (g-object-info-get-set-value-function (giobject) string)
   (g-object-info-get-set-value-function-pointer (giobject) giobjectsetvaluefunction)
   (g-object-info-get-get-value-function (giobject) string)
   (g-object-info-get-get-value-function-pointer (giobject) giobjectgetvaluefunction)
   ))
