;; https://developer.gnome.org/gi/stable/gi-GIInterfaceInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi interface)
  (export
   giinterface
   g-interface-info-get-n-prerequisites
   g-interface-info-get-prerequisite
   g-interface-info-get-n-properties
   g-interface-info-get-property
   g-interface-info-get-n-methods
   g-interface-info-get-method
   g-interface-info-find-method
   g-interface-info-get-n-signals
   g-interface-info-get-signal
   g-interface-info-find-signal
   g-interface-info-get-n-vfuncs
   g-interface-info-get-vfunc
   g-interface-info-find-vfunc
   g-interface-info-get-n-constants
   g-interface-info-get-constant
   g-interface-info-get-iface-struct)
  (import
   (rnrs)
   (gi base)
   (gi callable)
   (gi constant)
   (gi property)
   (gi signal)
   (gi struct)
   (gi ftypes-util))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype giinterface void*)

  (c-function
   (g-interface-info-get-n-prerequisites (giinterface) int)
   (g-interface-info-get-prerequisite (giinterface int) gibase)
   (g-interface-info-get-n-properties (giinterface) int)
   (g-interface-info-get-property (giinterface int) giproperty)
   (g-interface-info-get-n-methods (giinterface) int)
   (g-interface-info-get-method (giinterface int) gifunction)
   (g-interface-info-find-method (giinterface string) gifunction)
   (g-interface-info-get-n-signals (giinterface) int)
   (g-interface-info-get-signal (giinterface int) gisignal)
   (g-interface-info-find-signal (giinterface string) gisignal)
   (g-interface-info-get-n-vfuncs (giinterface) int)
   (g-interface-info-get-vfunc (giinterface int) givfunc)
   (g-interface-info-find-vfunc (giinterface string) givfunc)
   (g-interface-info-get-n-constants (giinterface) int)
   (g-interface-info-get-constant (giinterface int) giconstant)
   (g-interface-info-get-iface-struct (giinterface) gistruct)))
