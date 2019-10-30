;; https://developer.gnome.org/gi/stable/gi-GIEnumInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi enum)
  (export
   gienum givalue
   g-enum-info-get-n-values
   g-enum-info-get-value
   g-enum-info-get-n-methods
   g-enum-info-get-method
   g-enum-info-get-storage-type
   g-enum-info-get-error-domain
   g-value-info-get-value)
  (import
   (rnrs)
   (gi callable)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (lso))

  (define-ftype gienum void*)
  (define-ftype givalue void*)

  (c-function
   (g-enum-info-get-n-values (gienum) int)
   (g-enum-info-get-value (gienum int) givalue)
   (g-enum-info-get-n-methods (gienum) int)
   (g-enum-info-get-method (gienum int) gifunction)
   (g_enum_info_get_storage_type (gienum) int)
   (g-enum-info-get-error-domain (gienum) string)
   (g-value-info-get-value (givalue) integer-64))

  (define g-enum-info-get-storage-type
    (lambda (gia)
      (GITypeTag (g_enum_info_get_storage_type gia)))))
