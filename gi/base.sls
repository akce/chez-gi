;; GObject Introspection base type info interface.
;;
;; https://developer.gnome.org/gi/stable/GIBaseInfo.html
;;
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense

(library (gi base)
  (export
   gibaseinfo gitypelib GIInfoType
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
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype gibaseinfo void*)
  (define-ftype gitypelib void*)

  (c-enum GIInfoType
    GI_INFO_TYPE_INVALID
    GI_INFO_TYPE_FUNCTION
    GI_INFO_TYPE_CALLBACK
    GI_INFO_TYPE_STRUCT
    GI_INFO_TYPE_BOXED
    GI_INFO_TYPE_ENUM
    GI_INFO_TYPE_FLAGS
    GI_INFO_TYPE_OBJECT
    GI_INFO_TYPE_INTERFACE
    GI_INFO_TYPE_CONSTANT
    GI_INFO_TYPE_INVALID_0
    GI_INFO_TYPE_UNION
    GI_INFO_TYPE_VALUE
    GI_INFO_TYPE_SIGNAL
    GI_INFO_TYPE_VFUNC
    GI_INFO_TYPE_PROPERTY
    GI_INFO_TYPE_FIELD
    GI_INFO_TYPE_ARG
    GI_INFO_TYPE_TYPE
    GI_INFO_TYPE_UNRESOLVED)

  (c-function
   (g-base-info-ref (gibaseinfo) gibaseinfo)
   (g-base-info-unref (gibaseinfo) void)
   (g-base-info-equal (gibaseinfo gibaseinfo) boolean)
   (g_base_info_get_type (gibaseinfo) int)
   (g-base-info-get-typelib (gibaseinfo) gitypelib)
   (g-base-info-get-namespace (gibaseinfo) string)
   (g-base-info-get-name (gibaseinfo) string)
   (g-base-info-is-deprecated (gibaseinfo) boolean)
   (g-info-type-to-string (gibaseinfo) string))

  (define g-base-info-get-type
    (lambda (bi)
      (GIInfoType (g_base_info_get_type bi)))))
