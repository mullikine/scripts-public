#!/usr/local/racket/bin/racket
#lang racket

(define (collect inputs) 
   (let-values (((h t) (collect^ inputs))) 
     (unless (null? t) 
       (error 'collect "failed to collect everything" t)) 
     h)) 

(define (collect^ inputs) 
   (let ((indent (caar inputs)) 
         (head (cdar inputs)) 
         (inputs (cdr inputs))) 
     (n-collect indent head inputs))) 

(define (n-collect n head stream) 
   ;; n-collect will collect up all 
   ;; subtrees off the stream whose 
   ;; level is > N 
   (let loop ((subtrees '()) 
              (stream stream)) 
     (if (or (null? stream) 
             (<= (caar stream) n)) 
         (values (append head (reverse subtrees)) stream) 
         (let-values (((subtree stream) (collect^ stream))) 
           (loop (cons subtree subtrees) 
                 stream))))) 