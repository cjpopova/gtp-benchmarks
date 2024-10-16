#lang racket

#|
This script will take everything in the output file from analyze-contract-random-generate
and send it to my postgres db for further analysis.
|#

(require db)
(define pgc
    (postgresql-connect #:user "postgres"
                        #:database "postgres"
                        #:password "cjp"
                        #:server "localhost"
                        #:port 5432))

; escape special characters
(define (sanitize line)
  (string-replace line ":" "\\:"))

; convert a racket value into the sql equivalent
(define (stringify val) (string-append "'" val "'"))
(define (boolify val) (if (equal? "1" val) "true" "false"))

(define (next-line-it file)
  (let ((line (read-line file 'any)))
    (unless (eof-object? line)
      (define vals (string-split (sanitize line) ","))
      (define conv-vals (list (stringify (first vals))
                              (stringify (second vals))
                              (stringify (third vals))
                              (boolify (last vals))))
      (query pgc (format "INSERT INTO GTP_A1 VALUES (~a)"
                         (string-join conv-vals ", ")))
      (next-line-it file))))

(call-with-input-file "analysis-results.txt" next-line-it)
(disconnect pgc)

