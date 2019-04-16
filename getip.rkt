#!/usr/local/racket/bin/racket
#lang racket

(require json)
(require net/http-client json)
(define-values (status header response)
  (http-sendrecv "httpbin.org" "/ip" #:ssl? 'tls))
(define data (read-json response))
(printf "~a~%" (hash-ref data 'origin))