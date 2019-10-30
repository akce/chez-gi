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

  ;; GType (typedef gsize) defined in:
  ;; /usr/include/glib-2.0/gobject/gtype.h
  ;; and documented at:
  ;; https://developer.gnome.org/gobject/stable/gobject-Type-Information.html#GType
  ;; gsize (typedef size_t/ulong) documented at:
  ;; https://developer.gnome.org/glib/stable/glib-Basic-Types.html#gsize
  (define-ftype gtype size_t)

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
