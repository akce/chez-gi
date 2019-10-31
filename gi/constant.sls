;; https://developer.gnome.org/gi/stable/gi-GIConstantInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi constant)
  (export
   giconstant
   g-constant-get-value)
  (import
   (rnrs)
   (only (chezscheme) format)
   (gi base)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (lso))

  (define-ftype giconstant void*)
  (define-ftype GIArgument
    (union
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
   (g_constant_info_get_value (giconstant (* GIArgument)) int))

  (define g-constant-get-value
    (lambda (gia)
      (alloc ([v &v GIArgument])
        (let ([sz (g_constant_info_get_value gia &v)]
              [type (g-constant-info-get-type gia)])
          (let ([tag (g-type-info-get-tag type)])
            (g-base-info-unref type)
            (let ([val (case tag
                         [(BOOLEAN)	(ftype-ref GIArgument (v-boolean) &v)]
                         [(INT8)	(ftype-ref GIArgument (v-int8) &v)]
                         [(UINT8)	(ftype-ref GIArgument (v-uint8) &v)]
                         [(INT16)	(ftype-ref GIArgument (v-int16) &v)]
                         [(UINT16)	(ftype-ref GIArgument (v-uint16) &v)]
                         [(INT32)	(ftype-ref GIArgument (v-int32) &v)]
                         [(UINT32)	(ftype-ref GIArgument (v-uint32) &v)]
                         [(INT64)	(ftype-ref GIArgument (v-int64) &v)]
                         [(UINT64)	(ftype-ref GIArgument (v-uint64) &v)]
                         [(FLOAT)	(ftype-ref GIArgument (v-float) &v)]
                         [(DOUBLE)	(ftype-ref GIArgument (v-double) &v)]
                         [(UTF8)	(u8*->string (ftype-ref GIArgument (v-string) &v))]
                         [else
                          (error 'g-constant-info-get-value (format "Unknown const type: ~a" (symbol->string tag)))])])
              (g-constant-info-free-value gia &v)
              val)))))))
