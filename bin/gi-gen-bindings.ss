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
    (format #t "~a-~a depends on: ~a~n"
            (lib-name)
            (if (lib-version) (lib-version) (g-irepository-get-version (lib-name)))
            (sort string<? (g-irepository-get-dependencies (lib-name))))))

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

(define names
  (lambda (lst)
    (map g-base-info-get-name lst)))

(define types
  (lambda (lst)
    (map g-base-info-get-type lst)))

;; enums: (list enum-name-str (value-name-str . value-int) ...)
(define enum-values
  (lambda (gia)
    (let ([en (g-enum-info-get-n-values gia)])
      (let ([vis (map
                  (lambda (i)
                    (g-enum-info-get-value gia i))
                  (iota en))])
        (let ([vals (map (lambda (x) (cons (g-base-info-get-name x) (g-value-info-get-value x))) vis)])
          (for-each g-base-info-unref vis)
          vals)))))

(let ([args (command-line-arguments)])
  (when (null? args)
    (print-usage)
    (exit 1))
  (lib-name (car args))
  (lib-version (args-version args)))

(g-irepository-require (lib-name) (lib-version))
(print-deps)
;; Create some debug test vars here.
(define infos (get-all-infos))
;; consts: (list (name-string value) ...)
(define consts (map (lambda (x) (list (g-base-info-get-name x) (g-constant-get-value x))) (type-filter 'CONSTANT infos)))
(define def-enum
  (lambda (lst)
    (map
     (lambda (x)
       (list (g-base-info-get-name x) (enum-values x)))
     lst)))
(define enums (def-enum (type-filter 'ENUM infos)))
;; Flags appear to be enums, but the value is the left shift amount. ie, 1 << value.
(define flags (def-enum (type-filter 'FLAGS infos)))
;; todos: a list of infos that aren't handled yet.
(define todos
  (filter
   (lambda (x)
     (case (g-base-info-get-type x)
       ;; Add supported types here.
       [(CONSTANT ENUM FLAGS) #f]
       ;; Unsupported..
       [else x]))
   infos))
(new-cafe)
