;; https://developer.gnome.org/gi/stable/gi-GIRegisteredTypeInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi c regtype)
  (export
   giregtype
   g-registered-type-info-get-type-name
   g-registered-type-info-get-type-init
   g-registered-type-info-get-g-type)
  (import
   (rnrs)
   (gi c glib)
   (gi c ftypes-util))

  (define load-library
    (lso))

  (define-ftype giregtype void*)

  (c-function
   (g-registered-type-info-get-type-name (giregtype) string)
   (g-registered-type-info-get-type-init (giregtype) string)
   (g-registered-type-info-get-g-type (giregtype) gtype)))
