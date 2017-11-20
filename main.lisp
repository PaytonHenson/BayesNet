(defun example1 ()
  (let* ((c nil)
         (d nil)
         (root 'd)
         (nodes '(c d)))
    ;;setup node c
    (setf (get 'c 'parent) 'd)
    (setf (get 'c 'children) nil)
    (setf (get 'c 'instantiated) nil)
    (setf (get 'c 'cpt) (make-array '(2 2) :initial-contents '((0.5 0.5) (0.25 0.75))))
    (setf (get 'c 'probs) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'c 'lambda-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'c 'lambda-messages) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'c 'pi-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'c 'pi-messages) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    ;;setup node d
    (setf (get 'd 'parent) nil)
    (setf (get 'd 'children) '(c))
    (setf (get 'd 'instantiated) nil)
    (setf (get 'd 'cpt) (make-array '2 :initial-contents '(0.9 0.1)))
    (setf (get 'd 'probs) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'd 'lambda-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'd 'pi-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (operative-formula-2 'c)))

(defun operative-formula-1 (node)
  (let ((lambda-msgs (get node 'lambda-messages)
         (cpt (get node 'cpt))
         (lambda-vals (get node 'lambda-values))))
    (dotimes (i (array-dimension lambda-msgs 0))
      (setf (aref lambda-msgs i) 0)
      (dotimes (j (array-dimension cpt i))
        (setf (aref lambda-msgs i) (+ (aref lambda-msgs i)
                                      (* (aref cpt i j)
                                         (aref lambda-vals j))))))))

(defun operative-formula-2 (child)
  (let* ((parent-instantiated (get (get child 'parent) 'instantiated))
         (parent-probs (get (get child 'parent) 'probs))
         (lambda-msgs (get child 'lambda-messages))
         (pi-msgs (get child 'pi-messages)))
    (when parent-instantiated
      (dotimes (i (array-dimension parent-probs 0))
        (setf (aref pi-msgs i) (aref parent-probs i))))
    (when (not parent-instantiated)
      (dotimes (i (array-dimension parent-probs 0))
        (setf (aref pi-msgs i) (/ (aref parent-probs i) 
                                  (aref lambda-msgs i)))))))
