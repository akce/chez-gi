;; https://developer.gnome.org/gi/stable/gi-GIFunctionInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi function)
  (export
   GIFunctionFlags
   g-function-info-get-flags
   g-function-info-get-property
   g-function-info-get-symbol
   )
  (import
   (rnrs)
   (gi callable)
   (gi property)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  ;; Note: purposefully dropping the IS_ prefix.
  (c-enum GIFunctionFlags METHOD CONSTRUCTOR GETTER SETTER WRAPS_VFUNC THROWS)

  (c-function
   (g_function_info_get_flags (gifunction) int)
   (g-function-info-get-property (gifunction) giproperty)
   (g-function-info-get-symbol (gifunction) string)
   (g-function-info-get-vfunc (gifunction) givfunc)
   #;(g-function-info-invoke (...) ...)
   #;(g_invoke_error_quark (...) ...))

  (define g-function-info-get-flags
    (lambda (gia)
      (GIFunctionFlags (g_function_info_get_flags gia)))))
