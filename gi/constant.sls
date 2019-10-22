;; https://developer.gnome.org/gi/stable/gi-GIConstantInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi constant)
  (export
   giconstant
   GIArgument
   g-constant-info-free-value
   g-constant-info-get-type
   g-constant-info-get-value)
  (import
   (rnrs)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype giconstant void*)
  (define-ftype GIArgument
    (struct
     [v-boolean	boolean]
     [v-int8	integer-8]
     [v-uint8	unsigned-8]
     [v-int16	integer-16]
     [v-uint16	unsigned-16]
     [v-int32	integer-32]
     [v-uint32	unsigned-32]
     [v-int64	integer-64]
     [v-uint64	unsigned-64]
     [v-float	float]
     [v-double	double]
     [v-short	short]
     [v-ushort	unsigned-short]
     [v-int	int]
     [v-uint	unsigned]
     [v-long	long]
     [v-ulong	unsigned-long]
     [v-ssize	ssize_t]
     [v-size	size_t]
     [v-string	(* unsigned-8)]
     [v-pointer	void*]))

  (c-function
   (g-constant-info-free-value (giconstant (* GIArgument)) void)
   (g-constant-info-get-type (giconstant) gitype)
   (g-constant-info-get-value (giconstant (* GIArgument)) int)))
