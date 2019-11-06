;; https://developer.gnome.org/gi/stable/gi-GIPropertyInfo.html
;; Written by Akce 2019.
;; SPDX-License-Identifier: Unlicense
(library (gi property)
  (export
   giproperty
   GParamFlags
   g-property-info-get-flags
   g-property-info-get-ownership-transfer
   g-property-info-get-type)
  (import
   (rnrs)
   (gi arg)
   (gi type)
   (gi ftypes-util))

  (define load-library
    (lso))

  (define-ftype giproperty void*)

  ;; GParamFlags are a part of GObject GParamSpec but define here for convenience.
  ;; https://developer.gnome.org/gobject/stable/gobject-GParamSpec.html#GParamFlags
  (c-bitmap GParamFlags
    READABLE WRITABLE READWRITE CONSTRUCT CONSTRUCT_ONLY LAX_VALIDATION STATIC_NAME STATIC_NICK
    STATIC_BLURB EXPLICIT_NOTIFY DEPRECATED)

  (c-function
   (g_property_info_get_flags (giproperty) int)
   (g_property_info_get_ownership_transfer (giproperty) int)
   (g-property-info-get-type (giproperty) gitype))

  (define g-property-info-get-flags
    (lambda (gia)
      (GParamFlags (g_property_info_get_flags gia))))

  (define g-property-info-get-ownership-transfer
    (lambda (gia)
      (GITransfer (g_property_info_get_ownership_transfer gia)))))
