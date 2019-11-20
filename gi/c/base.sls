;; GObject Introspection base type info interface.
;;
;; https://developer.gnome.org/gi/stable/GIBaseInfo.html
;;
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense

(library (gi c base)
  (export
   gibase gitypelib GIInfoType
   g-base-info-ref
   g-base-info-unref
   g-base-info-equal
   g-base-info-get-type
   g-base-info-get-typelib
   g-base-info-get-namespace
   g-base-info-get-name
   (rename (g-base-info-is-deprecated g-base-info-deprecated?))
   g-info-type-to-string)
  (import
   (rnrs)
   (gi c ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype gibase void*)
  (define-ftype gitypelib void*)

  (c-enum GIInfoType
    INVALID FUNCTION CALLBACK STRUCT BOXED ENUM FLAGS OBJECT INTERFACE CONSTANT
    INVALID_0 UNION VALUE SIGNAL VFUNC PROPERTY FIELD ARG TYPE UNRESOLVED)

  (c-function
   (g-base-info-ref (gibase) gibase)
   (g-base-info-unref (gibase) void)
   (g-base-info-equal (gibase gibase) boolean)
   (g_base_info_get_type (gibase) int)
   (g-base-info-get-typelib (gibase) gitypelib)
   (g-base-info-get-namespace (gibase) string)
   (g-base-info-get-name (gibase) string)
   (g-base-info-is-deprecated (gibase) boolean)
   (g-info-type-to-string (gibase) string))

  (define g-base-info-get-type
    (lambda (bi)
      (GIInfoType (g_base_info_get_type bi)))))
