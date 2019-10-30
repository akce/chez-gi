;; https://developer.gnome.org/gi/stable/gi-GIUnionInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi union)
  (export
   giunion
   g-union-info-get-n-fields
   g-union-info-get-field
   g-union-info-get-n-methods
   g-union-info-get-method
   g-union-info-is-discriminated
   g-union-info-get-discriminator-offset
   g-union-info-get-discriminator-type
   g-union-info-get-discriminator
   g-union-info-find-method
   g-union-info-get-size
   g-union-info-get-alignment)
  (import
   (rnrs)
   (gi callable)
   (gi constant)
   (gi field)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype giunion void*)

  (c-function
   (g-union-info-get-n-fields (giunion) int)
   (g-union-info-get-field (giunion int) gifield)
   (g-union-info-get-n-methods (giunion) int)
   (g-union-info-get-method (giunion int) gifunction)
   (g-union-info-is-discriminated (giunion) boolean)
   (g-union-info-get-discriminator-offset (giunion) int)
   (g-union-info-get-discriminator-type (giunion) gitype)
   (g-union-info-get-discriminator (giunion int) giconstant)
   (g-union-info-find-method (giunion string) gifunction)
   (g-union-info-get-size (giunion) size_t)
   (g-union-info-get-alignment (giunion) size_t)))
