(in-package #:net-game)

(defgeneric is-desirable-square (obj loc))

(defmethod is-desirable-square ((obj located) (loc location))
  t)

(defgeneric wander (obj))

(defmethod wander ((obj located))
  "Moves the entity randomly, to a desirable square, or possibly not at all.
   Returns truthy if a move was performed."
  (let* ((nearby (remove-if #'(lambda (x) (not (is-desirable-square obj x)))
                            (halo (get-loc obj) 1)))
         (going (choose nearby)))
    (when (and going
               (not (eql (get-loc obj) going)))
      (move-object obj going)
      t)))

(defun simple-stalk (obj target)
  "Moves the object to a square adjacent to the target, if such a valid move exists.
   Returns truthy if successful."
  (let* ((candidates (intersection (halo (get-loc obj) 1) (halo (get-loc target) 1)))
         (path (find-if #'(lambda (x) (is-desirable-square obj x)) candidates)))
    (when path
      (move-object obj path)
      t)))

(defun adjacent-pursue (obj target)
  "If adjacent to the target, pursue the target directly. Returns truthy if the move was performed."
  (when (and (member-if (lambda (loc1) (member target (location-contents loc1)))
                        (halo (get-loc obj) 1))
             (is-desirable-square obj (get-loc target)))
    (move-object obj (get-loc target))
    t))


