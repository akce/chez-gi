;; https://developer.gnome.org/gi/stable/
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi c)
  (export)
  (import (chezscheme))
  (export
   (import
    ;; Import list follows order from documentation. See URL above.
    (gi c irepository)
    (gi c base)
    (gi c callable)
    (gi c function)
    ;; Defined in (gi c callable).
    #;(gi c callback)
    (gi c signal)
    (gi c vfunc)
    (gi c regtype)
    (gi c enum)
    (gi c struct)
    (gi c union)
    (gi c object)
    (gi c interface)
    (gi c arg)
    (gi c constant)
    (gi c field)
    (gi c property)
    (gi c type)
    ;; Defined in (gi c enum).
    #;(gi c value))))
