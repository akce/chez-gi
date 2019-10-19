;; SPDX-License-Identifier: Unlicense
;;
;; GObject Introspection repository interface.
;;
;; https://developer.gnome.org/gi/stable/GIRepository.html
;;
;; Written by Akce 2019.

(library (gi irepository)
  (export
   g-irepository-get-default
   current-irepository
   g-irepository-get-n-infos
   g-irepository-get-typelib-path
   g-irepository-is-registered
   g-irepository-require
   g-irepository-get-c-prefix
   g-irepository-get-shared-library
   g-irepository-get-version
   )
  (import
   (rnrs)
   (only (chezscheme) foreign-set! make-parameter)
   (gi ftypes-util)
   (gi glib))

  (define load-library
    (load-shared-object "libgirepository-1.0.so.1"))

  (define-ftype string-list void*)

  (define-ftype girepos void*)
  (define-ftype gibaseinfo void*)
  (define-ftype gitypelib void*)

  (c-function
   (g-irepository-get-default () girepos)
   (g-irepository-get-option-group () (* glist))
   (g-irepository-prepend-library-path (string) void)
   (g-irepository-prepend-search-path (string) void)
   (g-irepository-get-search-path () (* gslist))
   )

  (define current-irepository
    (make-parameter (g-irepository-get-default)))

  (c-default-function (girepos (current-irepository))
   (g-irepository-get-dependencies (string) string-list)
   (g-irepository-get-immediate-dependencies (string) string-list)
   (g-irepository-get-loaded-namespaces () string-list)
   (g-irepository-get-n-infos (string) int)
   (g-irepository-get-info (string int) gibaseinfo)
   (g-irepository-enumerate-versions (string) (* glist))
   #;(g-irepository-load-typelib (...) ...)
   (g-irepository-get-typelib-path (string) string)
   (g-irepository-is-registered (string string) boolean)
   (g_irepository_require (string string int (* gerror*)) gitypelib)
   (g-irepository-require-private (string string string int (* gerror*)) gitypelib)
   (g-irepository-get-c-prefix (string) string)
   (g-irepository-get-shared-library (string) string)
   (g-irepository-get-version (string) string)
   (g-irepository-find-by-gtype (gtype) gibaseinfo)
   )

  ;; [proc] g-irepository-require: loads type-library identified by namespace/version.
  ;; [returns]: typelib pointer
  ;; [library]: (gi irepository)
  ;;
  ;; Raises error condition if namespace is not found.
  ;;
  ;; > (g-irepository-require "GLib" #f)
  ;; 94057961251328
  ;; > (g-irepository-require "Foolib" #f)
  ;; Exception in g-repository-require: Typelib file for namespace 'Foolib' (any version) not found
  ;; Type (debug) to enter the debugger.
  ;; > (g-irepository-require "GLib" #f)
  ;; 94057961251328
  (define g-irepository-require
    (lambda (namespace version)
      (alloc ([err* &&err gerror*])
        (foreign-set! 'void* err* 0 0)	; glib will WARN if this is uninitialised.
        (let ([typelib (g_irepository_require namespace version 0 &&err)])
          (if (fx=? typelib 0)
            (let* ([&err (ftype-ref gerror* () &&err)]
                   [msg (u8*->string (ftype-ref gerror (message) &err))])
              (error 'g-irepository-require msg)
              (g-error-free &err))
            typelib)))))
  )
