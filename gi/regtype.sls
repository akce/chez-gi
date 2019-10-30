;; https://developer.gnome.org/gi/stable/gi-GIRegisteredTypeInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi regtype)
  (export
   giregtype
   g-registered-type-info-get-type-name
   g-registered-type-info-get-type-init
   g-registered-type-info-get-g-type)
  (import
   (rnrs)
   (gi glib)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype giregtype void*)

  (c-function
   (g-registered-type-info-get-type-name (giregtype) string)
   (g-registered-type-info-get-type-init (giregtype) string)
   (g-registered-type-info-get-g-type (giregtype) gtype)))
