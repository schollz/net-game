(in-package #:net-game)

(defclass animal-data (identifiable named)
  ((pack :accessor anim-pack
         :initform 1
         :initarg :pack)
   (speed :accessor anim-speed
          :initform 1
          :initarg :speed)
   (threat :accessor anim-threat
           :initform 1
           :initarg :threat)
   (air :accessor anim-air
        :initform nil
        :initarg :air)
   (sea :accessor anim-sea
        :initform nil
        :initarg :sea)
   (size :accessor anim-size
         :initform 1
         :initarg :size)))

(defun make-animal-data (id name &rest keys &key &allow-other-keys)
  (apply #'make-instance 'animal-data :id id :name name keys))

(defgeneric load-creature (type &rest data))

(defmethod load-creature ((type (eql 'animal)) &rest data)
  (destructuring-bind (id name . rest) data
    (apply #'make-animal-data id name rest)))

(defgeneric make-creature (data))

(defmethod make-creature ((data animal-data))
  (make-animal data))

(defclass creature (named located)
  ())

#|
 | Moods
 | * Passive - Moves randomly, if approached by a player, behaves according to attitude.
 | * Hunting - Chases the player. If the player is too far, moves randomly.
 | * Stalking - Chases the player at a distance. Moves in to Hunting eventually.
 | * Sneaky - Preparing to stalk when the player leaves.
 | Attitudes
 | * Passive - Does not strike unless struck.
 | * Hunting - Moves to Hunting mood when a player is spotted.
 | * Stalking - Moves to Sneaky mood when a player moves away.
 |#
(defclass animal (creature damageable)
  ((speed :accessor anim-speed
          :initform 1
          :initarg :speed)
   (mood :accessor anim-mood
         :initform 'passive
         :initarg :mood)
   (attitude :accessor anim-attitude
             :initform 'passive
             :initarg :attitude)
   (atk :accessor atk
        :initform 1
        :initarg :atk)
   (air :accessor anim-air
        :initform nil
        :initarg :air)
   (sea :accessor anim-sea
        :initform nil
        :initarg :sea)))

(defun make-animal (data)
  (make-instance 'animal
                 :name (get-name data)
                 :speed (anim-speed data)
                 :mood 'passive
                 :attitude (case (anim-threat data)
                             (1 'passive)
                             (2 (choose '(passive passive passive hunting)))
                             (3 (choose '(passive hunting stalking stalking)))
                             (4 (choose '(hunting hunting stalking stalking)))
                             (5 (choose '(hunting hunting hunting stalking)))
                             (t 'passive))
                 :hp (case (anim-size data)
                       (1 (+ 0.20 (random 0.20)))
                       (2 (+ 0.34 (random 0.25)))
                       (3 (+ 0.46 (random 0.45)))
                       (4 (+ 0.59 (random 0.51)))
                       (5 (+ 0.88 (random 1.00)))
                       (t 0.10))
                 :atk (case (anim-size data)
                        (1 (+ 0.01 (random 0.04)))
                        (2 (+ 0.05 (random 0.10)))
                        (3 (+ 0.14 (random 0.10)))
                        (4 (+ 0.19 (random 0.15)))
                        (5 (+ 0.29 (random 0.30))))
                 :sea (anim-sea data)
                 :air (anim-air data)))

(defmethod entity-turn ((obj animal))
;  (format t "The ~A (~A / ~A) at ~A is going to go now.~%"
;          (get-name obj) (anim-mood obj) (anim-attitude obj) (get-name (get-loc obj)))
  (if (not (is-desirable-square obj (get-loc obj)))
      (move-object obj (choose (halo (get-loc obj) 1)))
      (case (anim-mood obj)
        (passive (cond
                   ((member *player* (location-contents (get-loc obj)))
                    (case (anim-attitude obj)
                      (passive nil)
                      (hunting (setf (anim-mood obj) 'hunting)
                               (entity-turn obj))
                      (stalking (setf (anim-mood obj) 'sneaky))))
                   ((<= (random 6) (anim-speed obj))
                    (wander obj)
                    (when (and (eql (anim-attitude obj) 'stalking)
                               (member *player* (location-contents (get-loc obj))))
                      (setf (anim-mood obj) 'sneaky)))
                   (t nil)))
        (sneaky (cond
                  ((member *player* (location-contents (get-loc obj))) nil)
                  ((some (lambda (x) (member *player* (location-contents x)))
                         (halo (get-loc obj) 1))
                   (setf (anim-mood obj) 'stalking))
                  (t (setf (anim-mood obj) 'passive))))
        (hunting (cond
                   ((member *player* (location-contents (get-loc obj)))
                    (format t "The ~A attacks.~%" (get-name obj))
                    (do-attack obj :target *player*))
                   ((adjacent-pursue obj *player*))
                   ((<= (random 6) (anim-speed obj))
                    (wander obj))
                   (t nil)))
        (stalking (cond
                    ((member *player* (location-contents (get-loc obj)))
                     (setf (anim-mood obj) 'hunting)
                     (entity-turn obj))
                    ((some (lambda (x) (member *player* (location-contents x)))
                           (halo (get-loc obj) 1))
                     nil)
                    ((simple-stalk obj *player*))
                    (t (setf (anim-mood obj) 'passive)))))))

(defmethod is-desirable-square ((obj animal) (loc location))
  (cond
    ; If sea-based and location is a land tile, undesirable.
    ((and (anim-sea obj)
          (not (or (check-flag 'shore loc)
                   (check-flag 'sea loc)))) nil)
    ; If passive attitude, civilized tile, and not a passive bird, then undesirable.
    ((and (eql (anim-attitude obj) 'passive)
          (check-flag 'civilized loc)
          (not (and (anim-air obj)
                    (eql (anim-mood obj) 'passive)))) nil)
    ; Otherwise, desirable.
    (t)))

; TODO User-friendly description
(defmethod do-action ((act (eql 'examine)) (obj animal) preps)
  (declare (ignore preps))
  (format t "An animal~%"))

(defmethod system-keys append ((obj animal))
  `((anim-mood "Current Mood" ,(anim-mood obj))
    (anim-attitude "Attitude" ,(anim-attitude obj))))
