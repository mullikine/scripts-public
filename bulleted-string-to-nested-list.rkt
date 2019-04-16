#!/usr/local/racket/bin/racket
#lang racket

;; (require (planet williams/describe/describe))

;; (for
;;     ([arg
;;       (current-command-line-arguments)])
;;   (displayln arg))

;; (describe (current-command-line-arguments))
;; (describe (car (current-command-line-arguments)))
;; (describe (vector-ref (current-command-line-arguments) 0))

;; (displayln (vector-ref (current-command-line-arguments) 0))
;; (exit 0)

(define file-content
  (file->string (vector-ref (current-command-line-arguments) 0)))

#| (displayln file-content) |#
#| (exit 0) |#

;; (require racket) ; or match individually. I think this is needed if I do not do C-c C-c. That's correct
;; (require racket/match)
;; (require racket/list)

(define (non-empty-string? s)
  (not (string=? s "")))

(define (string->lines s)
  (filter non-empty-string?
          (regexp-match* #rx"[^\n]*" s)))

(define (indentation-level s)
  (for/first ([c s] [i (in-naturals)] #:unless (char=? c #\space))
    i))

(define (string->symbols s)
  (for/list ([x (in-port read (open-input-string s))])
    x))

(define (strip-dash xs)
  (rest xs))

(define (bullet-string->nested-list s)
  (define lines   (string->lines s))
  (define levels  (map indentation-level lines))
  #| (define symbols (map strip-dash (map string->symbols (string->lines s)))) |#
  (define symbols (map string->symbols (string->lines s)))
  (define (build js xss)
    (match* (js xss)
      [('() _)                         '()]
      [((list j)       (list xs))      xs]
      [((list* i j js) (list* xs xss)) (cond
                                         [(= i j) (cons xs   (list (build (cons j js) xss)))]
                                         [(< i j) (append xs (list (build (cons j js) xss)))]
                                         [else    (error 'build "not proper nesting")])]))
  (build levels symbols))

(bullet-string->nested-list file-content)