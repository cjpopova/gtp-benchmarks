#lang racket/base
(require
  (only-in file/glob glob in-glob)
  ;(only-in racket/format ~r)
  (only-in racket/file copy-directory/files)
  (only-in racket/path file-name-from-path))

(provide (rename-out
          [output-dir typed-dir]))

(define all-benchmarks (string->path "../benchmarks")) ; Path to benchmarks directory (input)
(define output-dir (string->path "../fully-typed")) ; Path to fully-typed-configurations directory (output)

#|
This is like (require gtp-benchmarks/utilities/make-configurations),
except it only makes the fully typed configuration of gtp benchmarks
into the output-dir folder. I'm not interested in the other points in the lattice.
I did have to change the folder structure from the original, since the og
copied the typed/ files into the config-dir, rather than config-dir/typed/.
|#
(define (make-configurations dir)
  (define config-dir (build-path output-dir
                                 (format "~a-configurations" (path->string (file-name-from-path dir)))))
  (printf "Making directory '~a' ...~n" config-dir)
  (make-directory (build-path config-dir)) ; create directory for this benchmark
  (make-directory (build-path config-dir "typed")) ; create typed subdirectory (same level as base)
  (define base-dir (build-path dir "base"))
  (define both-dir (build-path dir "both"))

  (when (directory-exists? base-dir)
    (copy-directory/files base-dir (build-path config-dir "base")))
  (define f*
    (let ([u* (for/list ((x (in-glob (build-path dir "untyped" "*.rkt")))) (path->string (file-name-from-path x)))]
          [t* (for/list ((x (in-glob (build-path dir "typed" "*.rkt")))) (path->string (file-name-from-path x)))])
      (if (equal? u* t*)
          u*
          (raise-argument-error 'make-configurations "typed and untyped folders have different .rkt files" "typed" t* "untyped" u*))))

  (when (directory-exists? both-dir) ; Both
    (for ((f (in-glob (build-path both-dir "*"))))
      (copy-file f (build-path config-dir "typed" (file-name-from-path f))))) ; copy to typed/
  (for ([f (in-list f*)]) ; Typed
    (copy-file (build-path dir "typed" f) (build-path config-dir "typed" f)))) ; copy to typed/

(unless (directory-exists? output-dir)
  (make-directory output-dir)
  (for* ([benchmark (directory-list all-benchmarks #:build? #t)])
    (make-configurations benchmark)))
