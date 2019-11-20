;; https://developer.gnome.org/gi/stable/gi-GITypeInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi c type)
  (export
   gitype
   GIArrayType
   GITypeTag
   (rename (g-type-info-is-pointer g-type-info-pointer?))
   g-type-info-get-tag
   g-type-info-get-param-type
   g-type-info-get-interface
   g-type-info-get-array-length
   g-type-info-get-array-fixed-size
   (rename (g-type-info-is-zero-terminated g-type-info-zero-terminated?))
   g-type-info-get-array-type)
  (import
   (rnrs)
   (gi c base)
   (gi c ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype gitype void*)

  (c-enum GIArrayType C ARRAY PTR_ARRAY BYTE_ARRAY)

  (c-enum GITypeTag VOID BOOLEAN INT8 UINT8 INT16 UINT16 INT32 UINT32 INT64 UINT64 FLOAT DOUBLE GTYPE
          UTF8 FILENAME ARRAY INTERFACE GLIST GSLIST GHASH ERROR UNICHAR)

  (c-function
   (g-type-info-is-pointer (gitype) boolean)
   (g_type_info_get_tag (gitype) int)
   (g-type-info-get-param-type (gitype int) gitype)
   (g-type-info-get-interface (gitype) gibase)
   (g-type-info-get-array-length (gitype) int)
   (g-type-info-get-array-fixed-size (gitype) int)
   (g-type-info-is-zero-terminated (gitype) boolean)
   (g_type_info_get_array_type (gitype) int))

  (define g-type-info-get-tag
    (lambda (gia)
      (GITypeTag (g_type_info_get_tag gia))))

  (define g-type-info-get-array-type
    (lambda (gia)
      (GIArrayType (g_type_info_get_array_type gia)))))
