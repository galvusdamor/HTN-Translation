(define
 (problem pfile_3_005)
 (:domain blocks)
 (:objects arm1 arm2 arm3 - ARM b1 b2 b3 b4 b5 - BLOCK)
 (:init
  (hand-empty arm1)
  (hand-empty arm2)
  (hand-empty arm3)
  (clear b5)
  (on-table b5)
  (clear b1)
  (on-table b3)
  (on b1 b4)
  (on b4 b3)
  (clear b2)
  (on-table b2))
 (:goal (and
         (clear b3)
         (on-table b4)
         (on b3 b4)
         (clear b5)
         (on-table b2)
         (on b5 b1)
         (on b1 b2))))