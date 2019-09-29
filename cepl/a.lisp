; edit this file using slimv_box started with "vvc" (https://github.com/justin2004/slimv_box)
;   press ,b  to evaluate this whole vim buffer
;   then jump to the bottom of this document

(ql:quickload :cepl.sdl2)
(ql:quickload :quickproject)
(cepl:make-project "your-proj")
(ql:quickload "your-proj")
(in-package :your-proj)



;;;;;;;;;; begin baggers' example 

;; This gives us a simple moving triangle

(defparameter *vertex-stream* nil)
(defparameter *array* nil)
(defparameter *loop* 0.0)

;; note the use of implicit uniform capture with *loop*
;; special vars in scope can be used inline. During compilation
;; cepl will try work out the type. It does this by seeing if the
;; symbol is bound to a value, and if it is it checks the type of
;; the value for a suitable matching varjo type
(cepl:defun-g calc-pos ((v-pos :vec4) (id :float))
  (let ((pos (rtg-math:v! (* (rtg-math:s~ v-pos :xyz) 0.3) 1.0)))
    (+ pos (let ((i (/ (+ (float id)) 2)))
             (rtg-math:v! (sin (+ i *loop*))
                 (cos (* 3 (+ (tan i) *loop*)))
                 0.0 0.0)))))

;; Also showing that we can use gpu-lambdas inline in defpipeline-g
;; It's not usually done as reusable functions are generally nicer
;; but I wanted to show that it was possible :)
(cepl:defpipeline-g prog-1 ()
  (cepl:lambda-g ((position :vec4) &uniform (i :float))
    (calc-pos position i))
  (cepl:lambda-g ()
    (rtg-math:v! (cos *loop*) (sin *loop*) 0.4 1.0)))

(defun step-demo ()
  (sleep 0.01)
  (cepl:step-host)
  (livesupport:update-repl-link)
  (setf *loop* (+ 0.011 *loop*))
  (cepl:clear)
  (loop :for i :below 100 :do
     (let ((i (/ i 2.0)))
       (cepl:map-g #'prog-1 *vertex-stream* :i i)))
  (cepl:swap))

(let ((running nil))
  (defun run-loop ()
    (setf running t)
    (setf *array* (cepl:make-gpu-array (list (rtg-math:v!  0.0   0.2  0.0  1.0)
                                        (rtg-math:v! -0.2  -0.2  0.0  1.0)
                                        (rtg-math:v!  0.2  -0.2  0.0  1.0))
                                  :element-type :vec4
                                  :dimensions 3))
    (setf *vertex-stream* (cepl:make-buffer-stream *array*))
    (loop :while (and running (not (cepl:shutting-down-p))) :do
       (livesupport:continuable (step-demo))))
  (defun stop-loop () (setf running nil)))


;;;;;;;;;; end baggers' example 



; then uncomment and put your cursor in each form and evaluate with ,e
; (cepl:repl)
; (run-loop)
;; (stop-loop)

