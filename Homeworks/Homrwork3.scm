(define (derivative expr)
  (cond ((not (list? expr)) (cond
                             ((number? expr) 0)
                             ((symbol? expr) 1)))
        ((null? (cdr expr)) (derivative (car expr)))
        ((and (symbol? (cadr expr)) (equal? '- (car expr))) -1)
        ((equal? '+ (car expr)) `(+ ,@(map derivative (cdr expr))))
        ((equal? '- (car expr)) `(- ,@(map derivative (cdr expr))))
        ((equal? '* (car expr))
         (if (null? (cddr expr))
             (derivative (cadr expr))
             (let ((u (cadr expr))
                   (v (if (null? (cdddr expr))
                          (caddr expr)
                          (cons '* (cddr expr)))))
               `(+ (* ,(derivative u) ,v)
                   (* ,u ,(derivative v))))))
        ((equal? '/ (car expr))
         (let ((numerator (cadr expr))
               (denominator (caddr expr)))
           `(/ (- (* ,(derivative numerator) ,denominator)
                  (* ,(derivative denominator) ,numerator))
               (* ,denominator ,denominator))))
        ((equal? 'expt (car expr))
         (let ((base (cadr expr))
               (exponent (caddr expr)))
           (if (and (symbol? base) (number? exponent))
               `(* ,exponent (expt ,base ,(- exponent 1)))
               `(* ,expr (log ,base) ,(derivative exponent)))))
        ((equal? 'exp (car expr))
         (let ((d (cadr expr)))
           `(* (exp ,d) ,(derivative d))))
        ((equal? 'cos (car expr)) `(* (- (sin ,(cadr expr))) ,(derivative (cadr expr))))
        ((equal? 'sin (car expr)) `(* (cos ,(cadr expr)) ,(derivative (cadr expr))))
        ((equal? 'log (car expr)) `(/ ,(derivative (cadr expr)) ,(cadr expr)))
        (else expr)))

(derivative '(expt x 10)) ; (* 10 (expt x 9))
(derivative '(* 2 (expt x 5))) ; (* 2 (* 5 (expt x 4)))
(derivative (list '* 'x 'x)) ; (+ (* x 1) (* 1 x))
