;; GObject Introspection callable type module.
;;
;; https://developer.gnome.org/gi/stable/gi-GICallableInfo.html
;;
;; Written by Akce 2019.
;;
;; SPDX-License-Identifier: Unlicense
(library (gi callable)
  (export
   gicallable
   g-callable-info-can-throw-gerror
   g-callable-info-get-n-args
   g-callable-info-get-arg
   g-callable-info-get-caller-owns
   g-callable-info-get-instance-ownership-transfer
   g-callable-info-get-return-attribute
   g-callable-info-get-return-type
   (rename
    (g-callable-info-is-method g-callable-info-method?)
    (g-callable-info-may-return-null g-callable-info-may-return-null?)
    (g-callable-info-skip-return g-callable-info-skip-return?)))
  (import
   (rnrs)
   (gi arg)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype gicallable void*)

  (c-function
   (g-callable-info-can-throw-gerror (gicallable) boolean)
   (g-callable-info-get-n-args (gicallable) int)
   (g-callable-info-get-arg (gicallable int) giarg)
   (g_callable_info_get_caller_owns (gicallable) int)
   (g_callable_info_get_instance_ownership_transfer (gicallable) int)
   (g-callable-info-get-return-attribute (gicallable string) string)
   (g-callable-info-get-return-type (gicallable) gitype)
   ;; Indirect function invocation. Ignore for now as we'll try and call functions directly.
   #;(g-callable-info-invoke (...) ...)
   (g-callable-info-is-method (gicallable) boolean)
   ;; The following functions break opacity, so skip for now.
   #;(g-callable-info-iterate-return-attributes (...) ...)
   #;(g-callable-info-load-arg (...) ...)
   #;(g-callable-info-load-return-type (...) ...)
   (g-callable-info-may-return-null (gicallable) boolean)
   (g-callable-info-skip-return (gicallable) boolean)
   )

  (define g-callable-info-get-caller-owns
    (lambda (gia)
      (GITransfer (g_callable_info_get_caller_owns gia))))

  (define g-callable-info-get-instance-ownership-transfer
    (lambda (gia)
      (GITransfer (g_callable_info_get_instance_ownership_transfer gia)))))
