;; https://developer.gnome.org/gi/stable/gi-GIFieldInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi c field)
  (export
   gifield
   GIFieldInfoFlags
   g-field-info-get-field
   g-field-info-set-field
   g-field-info-get-flags
   g-field-info-get-offset
   g-field-info-get-size
   g-field-info-get-type)
  (import
   (rnrs)
   (gi c arg)
   (gi c type)
   (gi c ftypes-util))

  (define load-library
    (lso))

  (define-ftype gifield void*)

  ;; Dropping the IS_ prefix for value symbols.
  (c-bitmap GIFieldInfoFlags READABLE WRITABLE)

  (c-function
   (g-field-info-get-field (gifield void* giarg) boolean)
   (g-field-info-set-field (gifield void* giarg) boolean)
   (g_field_info_get_flags (gifield) int)
   (g-field-info-get-offset (gifield) int)
   (g-field-info-get-size (gifield) int)
   (g-field-info-get-type (gifield) gitype))

  (define g-field-info-get-flags
    (lambda (gia)
      (GIFieldInfoFlags (g_field_info_get_flags gia))))
  )
