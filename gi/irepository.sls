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
   g-irepository-get-dependencies
   g-irepository-get-immediate-dependencies
   g-irepository-get-loaded-namespaces
   g-irepository-get-n-infos
   g-irepository-get-typelib-path
   g-irepository-is-registered
   g-irepository-require
   g-irepository-require-private
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
   (g_irepository_get_dependencies (string) (* u8*))
   (g_irepository_get_immediate_dependencies (string) (* u8*))
   (g_irepository_get_loaded_namespaces () (* u8*))
   (g-irepository-get-n-infos (string) int)
   (g-irepository-get-info (string int) gibaseinfo)
   (g-irepository-enumerate-versions (string) (* glist))
   #;(g-irepository-load-typelib (...) ...)
   (g-irepository-get-typelib-path (string) string)
   (g-irepository-is-registered (string string) boolean)
   (g_irepository_require (string string int (* gerror*)) gitypelib)
   (g_irepository_require_private (string string string int (* gerror*)) gitypelib)
   (g-irepository-get-c-prefix (string) string)
   (g-irepository-get-shared-library (string) string)
   (g-irepository-get-version (string) string)
   (g-irepository-find-by-gtype (gtype) gibaseinfo)
   )

  ;; [proc] g-irepository-get-dependencies: recursively get all dependencies for namespace.
  ;; [returns] string list of dependencies, empty list if there are none.
  ;;
  ;; Each dependency is a string of format: "<namespace>-<version>".
  ;;
  ;; Namespace must be loaded.
  ;;
  ;; > (g-irepository-require "Gtk" #f)
  ;; 94555665748480
  ;; > (g-irepository-get-dependencies "Gtk")
  ;; ("xlib-2.0" "GLib-2.0" "Gdk-3.0" "GdkPixbuf-2.0" "cairo-1.0"
  ;;  "GObject-2.0" "Pango-1.0" "Gio-2.0" "GModule-2.0" "Atk-1.0")
  ;; > (g-irepository-get-dependencies "GLib")
  ;; ()
  (define g-irepository-get-dependencies
    (lambda (namespace)
      (let ([slist (g_irepository_get_dependencies namespace)])
        (u8**->strings/free slist))))

  ;; [proc] g-irepository-get-immediate-dependencies: get immediate dependencies for namespace.
  ;; [returns] string list of dependencies, empty list if there are none.
  ;;
  ;; This is a non-recursive version of g-irepository-get-dependencies.
  ;;
  ;; > (g-irepository-require "Gtk" #f)
  ;; 94555665748480
  ;; > (g-irepository-get-immediate-dependencies "Gtk")
  ;; ("xlib-2.0" "Gdk-3.0" "Atk-1.0")
  (define g-irepository-get-immediate-dependencies
    (lambda (namespace)
      (let ([slist (g_irepository_get_immediate_dependencies namespace)])
        (u8**->strings/free slist))))

  ;; [proc] g-irepository-get-loaded-namespaces: get names of all loaded namespaces.
  ;; [returns] string list of namespaces, empty list if none are loaded.
  ;;
  ;; > (g-irepository-get-loaded-namespaces)
  ;; ()
  ;; > (g-irepository-require "Gtk" #f)
  ;; 94555665748480
  ;; > (g-irepository-get-loaded-namespaces)
  ;; ("Gtk" "GdkPixbuf" "GObject" "GModule" "cairo" "GLib" "xlib"
  ;;  "Atk" "Gio" "Pango" "Gdk")
  (define g-irepository-get-loaded-namespaces
    (lambda ()
      (let ([slist (g_irepository_get_loaded_namespaces)])
        (u8**->strings/free slist))))

  ;; [proc] irequire: internal irepository require function.
  (define irequire
    (lambda (func funcsym . args)
      (alloc ([err* &&err gerror*])
        (foreign-set! 'void* err* 0 0)	; glib will WARN if this is uninitialised.
        (let ([typelib (apply func (append args (list &&err)))])
          (if (fx=? typelib 0)
            (let* ([&err (ftype-ref gerror* () &&err)]
                   [msg (u8*->string (ftype-ref gerror (message) &err))])
              (error funcsym msg)
              (g-error-free &err))
            typelib)))))

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
      (irequire g_irepository_require 'g_irepository_require namespace version 0)))

  ;; [proc] g-irepository-require-private: loads type-library identified by namespace/version from private path.
  ;; [returns]: typelib pointer
  ;; [library]: (gi irepository)
  ;;
  ;; Raises error condition if namespace is not found within path.
  ;;
  ;; $ cp -vi /usr/lib/girepository-*/GLib* /tmp
  ;; '/usr/lib/girepository-1.0/GLib-2.0.typelib' -> '/tmp/GLib-2.0.typelib'
  ;; $ chez-scheme
  ;; > (import (gi irepository))
  ;; > (g-irepository-get-loaded-namespaces)
  ;; ()
  ;; > (g-irepository-require-private "/home" "GLib" #f)
  ;; Exception in g_irepository_require_private: Typelib file for namespace 'GLib' (any version) not found
  ;; Type (debug) to enter the debugger.
  ;; > (g-irepository-require-private "/tmp" "GLib" #f)
  ;; 94596583322112
  ;; > (g-irepository-get-loaded-namespaces)
  ;; ("GLib")
  (define g-irepository-require-private
    (lambda (path namespace version)
      (irequire g_irepository_require_private 'g_irepository_require_private path namespace version 0)))
  )
