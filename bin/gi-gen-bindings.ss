#! /usr/bin/chez-scheme --script

;; Generate Chez scheme bindings for libraries that support gobject introspection.

(suppress-greeting #t)

(import
 (chezscheme)
 (gi))

(define lib-name
  (make-parameter #f))

(define lib-version
  (make-parameter #f))

(define print-usage
  (lambda ()
    (format #t "Usage: ~a <path-to-typelib>~n" (car (command-line)))))

(define print-deps
  (lambda ()
    (format #t "~a -> ~a~n" (lib-name) (sort string<? (g-irepository-get-dependencies (lib-name))))))

;; Get all the gibase structs for lib-name.
(define get-all-infos
  (lambda ()
    (let* ([name (lib-name)]
           [nums (g-irepository-get-n-infos name)])
      (map
       (lambda (i)
         (g-irepository-get-info name i))
       (iota nums)))))

(define args-version
  (lambda (args)
    (cond
     [(fx>? (length args) 1)
      (list-ref args 1)]
     [else
      #f])))

(define type-filter
  (lambda (sym lst)
    (filter (lambda (x) (eq? sym (g-base-info-get-type x))) lst)))

(let ([args (command-line-arguments)])
  (if (null? args)
    (begin
      (print-usage)
      (exit 1)))
  (lib-name (car args))
  (lib-version (args-version args)))
(g-irepository-require (lib-name) (lib-version))
(unless (lib-version)
  (format #t "loaded version ~a~n" (g-irepository-get-version (lib-name))))
(print-deps)
;; Create some debug test vars here.
(define infos (get-all-infos))
(define consts (map (lambda (x) (list (g-base-info-get-name x) (g-constant-get-value x))) (type-filter 'CONSTANT infos)))
(new-cafe)
