;; https://developer.gnome.org/gi/stable/gi-GIArgInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi arg)
  (export
   giarg
   GIDirection
   GIScopeType
   GITransfer
   g-arg-info-get-closure
   g-arg-info-get-destroy
   g-arg-info-get-direction
   g-arg-info-get-ownership-transfer
   g-arg-info-get-scope
   g-arg-info-get-type
   (rename
    (g-arg-info-may-be-null g-arg-info-may-be-null?)
    (g-arg-info-is-caller-allocates g-arg-info-caller-allocates?)
    (g-arg-info-is-optional g-arg-info-optional?)
    (g-arg-info-is-return-value g-arg-info-return-value?)
    (g-arg-info-is-skip g-arg-info-skip?)))
  (import
   (rnrs)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (lso))

  (define-ftype giarg void*)

  (c-enum GIDirection IN OUT INOUT)
  (c-enum GIScopeType INVALID CALL ASYNC NOTIFIED)
  (c-enum GITransfer NOTHING CONTAINER EVERYTHING)

  (c-function
   (g-arg-info-get-closure (giarg) int)
   (g-arg-info-get-destroy (giarg) int)
   (g_arg_info_get_direction (giarg) int)
   (g_arg_info_get_ownership_transfer (giarg) int)
   (g_arg_info_get_scope (giarg) int)
   (g-arg-info-get-type (giarg) gitype)
   ;; g-arg-info-load-type breaks gitype opacity. Use g-arg-info-get-type instead.
   #;(g-arg-info-load-type (giarg gitype) void)
   (g-arg-info-may-be-null (giarg) boolean)
   (g-arg-info-is-caller-allocates (giarg) boolean)
   (g-arg-info-is-optional (giarg) boolean)
   (g-arg-info-is-return-value (giarg) boolean)
   (g-arg-info-is-skip (giarg) boolean))

  (define g-arg-info-get-direction
    (lambda (gia)
      (GIDirection (g_arg_info_get_direction gia))))

  (define g-arg-info-get-ownership-transfer
    (lambda (gia)
      (GITransfer (g_arg_info_get_ownership_transfer gia))))

  (define g-arg-info-get-scope
    (lambda (gia)
      (GIScopeType (g_arg_info_get_scope gia)))))
