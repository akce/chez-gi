;; https://developer.gnome.org/gi/stable/gi-GISignalInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi signal)
  (export
   GSignalFlags
   g-signal-info-get-flags
   g-signal-info-get-class-closure
   (rename (g-signal-info-true-stops-emit g-signal-info-true-stops-emit?)))
  (import
   (rnrs)
   (gi callable)
   (gi ftypes-util))

  (define load-library
    (lso))

  ;; Note: should be declared in glib, but doing here for convenience.
  (c-enum GSignalFlags RUN_FIRST RUN_LAST RUN_CLEANUP NO_RECURSE DETAILED ACTION NO_HOOKS MUST_COLLECT DEPRECATED)

  (c-function
   (g_signal_info_get_flags (gisignal) int)
   (g-signal-info-get-class-closure (gisignal) givfunc)
   (g-signal-info-true-stops-emit (gisignal) boolean)
   #;(g-function-info-invoke (...) ...)
   #;(g_invoke_error_quark (...) ...))

  (define g-signal-info-get-flags
    (lambda (gia)
      (GSignalFlags (g_signal_info_get_flags gia)))))
