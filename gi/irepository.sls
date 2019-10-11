;; SPDX-License-Identifier: Unlicense
;;
;; GObject Introspection repository interface.
;;
;; https://developer.gnome.org/gi/stable/GIRepository.html
;;
;; Written by Akce 2019.

(library (gi irepository)
  (export
   g-irepository-get-default
   current-irepository
   g-irepository-get-n-infos
   )
  (import
   (rnrs)
   (only (chezscheme) make-parameter)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype girepos void*)

  (c-function
   (g-irepository-get-default () girepos)
   )

  (define current-irepository
    (make-parameter (g-irepository-get-default)))

  (c-default-function (girepos (current-irepository))
   (g-irepository-get-n-infos (string) int))
  )
