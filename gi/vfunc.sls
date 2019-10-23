;; https://developer.gnome.org/gi/stable/gi-GIVFuncInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi vfunc)
  (export
   GIVFuncFlags
   g-vfunc-info-get-flags
   g-vfunc-info-get-offset
   g-vfunc-info-get-signal
   g-vfunc-info-get-invoker
   g-vfunc-info-get-address)
  (import
   (rnrs)
   (gi callable)
   (gi glib)
   (gi signal)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (c-enum GIVFuncFlags MUST_CHAIN_UP MUST_OVERRIDE MUST_NOT_OVERRIDE THROWS)

  (c-function
   (g_vfunc_info_get_flags (givfunc) int)
   (g-vfunc-info-get-offset (givfunc) int)
   (g_vfunc_info_get_signal (givfunc) int)
   (g-vfunc-info-get-invoker (givfunc) gifunction)
   (g-vfunc-info-get-address (givfunc gtype (* gerror*)) void*)
   #;(g-vfunc-info-invoke (...) ...))

  (define g-vfunc-info-get-flags
    (lambda (gia)
      (GIVFuncFlags (g_vfunc_info_get_flags gia))))

  (define g-vfunc-info-get-signal
    (lambda (gia)
      (GSignalFlags (g_vfunc_info_get_signal gia)))))
