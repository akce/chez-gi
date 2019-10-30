;; https://developer.gnome.org/gi/stable/
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi)
  (export)
  (import (chezscheme))
  (export
   (import
    ;; Import list follows order from documentation. See URL above.
    (gi irepository)
    (gi base)
    (gi callable)
    (gi function)
    ;; Defined in (gi callable).
    #;(gi callback)
    (gi signal)
    (gi vfunc)
    (gi regtype)
    (gi enum)
    (gi struct)
    (gi union)
    (gi object)
    (gi interface)
    (gi arg)
    (gi constant)
    (gi field)
    (gi property)
    (gi type)
    ;; Defined in (gi enum).
    #;(gi value))))
