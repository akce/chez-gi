;; https://developer.gnome.org/gi/stable/gi-GIStructInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi struct)
  (export
   gistruct
   g-struct-info-find-field
   g-struct-info-get-alignment
   g-struct-info-get-size
   g-struct-info-is-gtype-struct
   g-struct-info-get-n-fields
   g-struct-info-get-field
   g-struct-info-get-n-methods
   g-struct-info-get-method
   g-struct-info-find-method)
  (import
   (rnrs)
   (gi callable)
   (gi field)
   (gi glib)
   (gi ftypes-util))

  (define load-library
    (lso))

  (define-ftype gistruct void*)

  (c-function
   (g-struct-info-find-field (gistruct string) gifield)
   (g-struct-info-get-alignment (gistruct) size_t)
   (g-struct-info-get-size (gistruct) size_t)
   (g-struct-info-is-gtype-struct (gistruct) boolean)
   ;; Undocumented.
   #;(g-struct-info-is-foreign (gistruct) boolean)
   (g-struct-info-get-n-fields (gistruct) int)
   (g-struct-info-get-field (gistruct int) gifield)
   (g-struct-info-get-n-methods (gistruct) int)
   (g-struct-info-get-method (gistruct int) gifunction)
   (g-struct-info-find-method (gistruct string) gifunction)))
