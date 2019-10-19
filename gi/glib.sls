(library (gi glib)
  (export
   gquark
   gerror gerror*
   glist glist*
   gslist gslist*
   gtype
   goptiongroup
   g-error-free)
  (import
   (chezscheme)
   (gi ftypes-util))

  (define load-lib
    (load-shared-object "libglib-2.0.so"))

  (define-ftype gquark integer-32)
  (define-ftype gerror
    (struct
     [domain	gquark]
     [code	int]
     [message	u8*]))
  (define-ftype gerror* (* gerror))
  (define-ftype gtype int)

  (define-ftype glist
    (struct
     [data	void*]
     [next	(* glist)]
     [prev	(* glist)]))
  (define-ftype glist* (* glist))
  (define-ftype gslist
    (struct
     [data	void*]
     [next	(* gslist)]))
  (define-ftype gslist* (* gslist))

  (define-ftype goptiongroup void*)

  (c-function
   (g-error-free ((* gerror)) void))
  )
