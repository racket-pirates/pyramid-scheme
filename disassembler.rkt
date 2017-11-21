#lang errortrace typed/racket/no-check

(require "types.rkt")
(require "serializer.rkt")
(require binaryio/integer)
(provide (all-defined-out))

; Outputs 3 column TSV suitable for pasting into Google sheets

(: print-disassembly (-> bytes Void))
(define (print-disassembly bs)
  (define (loop n)
    (fprintf (current-output-port) "~x" n)
    (write-char #\tab)
    ;; (print `(,(bytes-ref bs n)
    ;;          ,(push-op? (dict-ref opcodes-by-byte (bytes-ref bs n)))
    ;;          ,(op-extra-size (dict-ref opcodes-by-byte (bytes-ref bs n)))))
    (write-char #\tab)
    (let ((op (dict-ref opcodes-by-byte (bytes-ref bs n))))
      (if (push-op? op)
          (fprintf (current-output-port)
                   "Push~a 0x~x"
                   (op-extra-size op)
                   (bytes->integer bs 
                                  #f      ; signed?
                                  #t      ; big-endian
                                  (+ n 1) ; start position
                                  (+ n 1 (op-extra-size op)))) ; end
          (write-string (symbol->string (opcode-name op))))
      (set! n (+ n (op-extra-size op))))
    (newline)
    (if (>= n (- (bytes-length bs) 1))
        (void)
        (loop (+ n 1))))
  (loop 0))