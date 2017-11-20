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
    (setf (get 'c 'lambda-values) (make-array '2 :element-type 'double-float :initial-contents '(1 1)))
    (setf (get 'c 'lambda-messages) (make-array '2 :element-type 'double-float :initial-contents '(1 1)))
    (setf (get 'c 'pi-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'c 'pi-messages) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    ;;setup node d
    (setf (get 'd 'parent) nil)
    (setf (get 'd 'children) '(c))
    (setf (get 'd 'instantiated) nil)
    (setf (get 'd 'cpt) (make-array '2 :initial-contents '(0.9 0.1)))
    (setf (get 'd 'probs) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (setf (get 'd 'lambda-values) (make-array '2 :element-type 'double-float :initial-contents '(1 1)))
    (setf (get 'd 'pi-values) (make-array '2 :element-type 'double-float :initial-element 0.0d0))
    (operative-formula-3 'd)))

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
  (let ((parent-instantiated (get (get child 'parent) 'instantiated)
         (parent-probs (get (get child 'parent) 'probs))
         (lambda-msgs (get child 'lambda-messages))
         (pi-msgs (get child 'pi-messages))))
    (when parent-instantiated
      (dotimes (i (array-dimension pi-msgs 0))
        (setf (aref pi-msgs i) (aref parent-probs i))))
    (when (not parent-instantiated)
      (dotimes (i (array-dimension pi-msgs 0))
        (setf (aref pi-msgs i) (/ (aref parent-probs i)
                                  (aref lambda-msgs i)))))))

(defun operative-formula-3 (node)
  (let ((inst (get node 'instantiated))
        (children (get node 'children))
        (lambda-vals (get node 'lambda-values))
        (probs (get node 'probs)))
    (when inst
      (dotimes (i (array-dimension lambda-vals 0))
        (setf (aref lambda-vals i) (aref probs i))))
    (when (not inst)
      (dotimes (i (array-dimension lambda-vals 0))
        (setf (aref lambda-vals i) 1)
        (dolist (child children)
          (let* ((child-lambda-messages (get child 'lambda-messages)))
            (setf (aref lambda-vals i) (* (aref lambda-vals i)
                                          (aref child-lambda-messages i)))))))))

(defun operative-formula-4 (node)
  (let ((pi-vals (get node 'pi-values))
        (cpt (get node 'cpt))
        (pi-msgs (get node 'pi-messages)))
    (dotimes (i (array-dimension pi-vals 0))
      (setf (aref pi-vals i) 0)
      (dotimes (j (array-dimension cpt i))
        (setf (aref pi-vals i) (+ (aref pi-vals i)
                                  (* (aref cpt j i)
                                     (aref pi-msgs j))))))))

(defun operative-formula-5 (node)
  (let ((probs (get node 'probs))
        (pi-vals (get node 'pi-values))
        (lambda-vals (get node 'lambda-values))
        (sum 0)
        (alpha))
    (dotimes (i (array-dimension probs 0))
      (setf (aref probs i) (* (aref pi-vals i) (aref lambda-vals i)))
      (setf sum (+ sum (aref probs i))))
    (setf alpha (/ 1 sum))
    (dotimes (i (array-dimension probs 0))
      (setf (aref probs i) (* (aref probs i) alpha)))))

(defun update-b (node child-sender)
  (unless (or (null node) (get node 'instantiated))
    (let ((children (get node 'children)))
      (operative-formula-3 node)
      (operative-formula-5 node)
      (operative-formula-1 node)
      (upate-b (get node 'parent) node)
      (dolist (child children)
        (unless (eq child child-sender)
          (operative-formula-2 child)
          (update-c child))))))

(defun update-c (node)
  (unless (or (null node) (get node 'instantiated))
    (operative-formula-4 node)
    (operative-formula-5 node)
    (dolist (child (get node 'children))
      (operative-formula-2 child)
      (update-c child))))

(defun initialize (root)
  (let ((cpt (get root 'cpt))
        (probs (get root 'probs))
        (pi-vals (get root 'pi-values))
        (children (get root 'children)))
    (dotimes (i (array-dimension cpt 0))
      (setf (aref probs i) (aref cpt i))
      (setf (aref pi-vals i) (aref cpt i)))
    (dolist (child children)
      (operative-formula-2 child)
      (update-c child))))

(defun instantiate (node val)
  (let ((probs (get node 'probs))
        (lambda-vals (get node 'lambda-values))
        (lambda-msgs (get node 'lambda-messages))
        (pi-msgs (get node 'pi-msgs))
        (parent (get node 'parent))
        (children (get node 'children))
        (inst (get node 'instantiated)))
    (setf inst t)
    (dotimes (i (array-dimension probs 0))
      (if (eql i val)
        (setf (aref probs i) 1)
        (setf (aref probs i) 0)))
    (operative-formula-3 node)
    (operative-formula-1 node)
    (update-b parent node)
    (dolist (child children)
      (operative-formula-2 child)
      (update-c child))))
