#! /usr/bin/chez-scheme --script

;; Generate Chez scheme bindings for libraries that support gobject introspection.

(suppress-greeting #t)

(import
 (chezscheme)
 (gi typelib))

(define lib-handle
  (make-parameter #f))

(define lib-name
  (make-parameter #f))

(define lib-version
  (make-parameter #f))

(define print-usage
  (lambda ()
    (format #t "Usage: ~a lib-name [lib-version]~n" (car (command-line)))))

(define print-deps
  (lambda ()
    (format #t "~a-~a depends on: ~a~n"
            (lib-name) (lib-version)
            (sort string<? (typelib-dependencies (lib-name))))))

(define args-version
  (lambda (args)
    (cond
     [(fx>? (length args) 1)
      (list-ref args 1)]
     [else
      #f])))

(let ([args (command-line-arguments)])
  (when (null? args)
    (print-usage)
    (exit 1))
  (lib-name (car args))
  (lib-handle (load-typelib (lib-name) (args-version args)))
  (lib-version (typelib-version (lib-name))))

(print-deps)
;; Create some debug test vars here.
#;(define records (map (lambda (x) (display "TOPLEVEL")(newline)(make x)) (get-ptrs)))
(define records (typelib-records (lib-name)))
(define callbacks (type-filter 'CALLBACK records))
(define consts (type-filter 'CONSTANT records))
(define enums (type-filter 'ENUM records))
(define flags (type-filter 'FLAGS records))
(define funcs (type-filter 'FUNCTION records))
(define interfaces (type-filter 'INTERFACE records))
(define objects (type-filter 'OBJECT records))
(define structs (type-filter 'STRUCT records))
(define todos (type-filter 'TODO records))
(new-cafe)
