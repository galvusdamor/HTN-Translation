(define
 (problem tower_problem_15)
 (:domain towers)
 (:objects t1 t2 t3 - TOWER
           r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 - RING)
 (:init
  (smallerThan r1 t1)
  (smallerThan r1 t2)
  (smallerThan r1 t3)
  (smallerThan r2 t1)
  (smallerThan r2 t2)
  (smallerThan r2 t3)
  (smallerThan r3 t1)
  (smallerThan r3 t2)
  (smallerThan r3 t3)
  (smallerThan r4 t1)
  (smallerThan r4 t2)
  (smallerThan r4 t3)
  (smallerThan r5 t1)
  (smallerThan r5 t2)
  (smallerThan r5 t3)
  (smallerThan r6 t1)
  (smallerThan r6 t2)
  (smallerThan r6 t3)
  (smallerThan r7 t1)
  (smallerThan r7 t2)
  (smallerThan r7 t3)
  (smallerThan r8 t1)
  (smallerThan r8 t2)
  (smallerThan r8 t3)
  (smallerThan r9 t1)
  (smallerThan r9 t2)
  (smallerThan r9 t3)
  (smallerThan r10 t1)
  (smallerThan r10 t2)
  (smallerThan r10 t3)
  (smallerThan r11 t1)
  (smallerThan r11 t2)
  (smallerThan r11 t3)
  (smallerThan r12 t1)
  (smallerThan r12 t2)
  (smallerThan r12 t3)
  (smallerThan r13 t1)
  (smallerThan r13 t2)
  (smallerThan r13 t3)
  (smallerThan r14 t1)
  (smallerThan r14 t2)
  (smallerThan r14 t3)
  (smallerThan r15 t1)
  (smallerThan r15 t2)
  (smallerThan r15 t3)
  (smallerThan r1 r2)
  (smallerThan r1 r3)
  (smallerThan r1 r4)
  (smallerThan r1 r5)
  (smallerThan r1 r6)
  (smallerThan r1 r7)
  (smallerThan r1 r8)
  (smallerThan r1 r9)
  (smallerThan r1 r10)
  (smallerThan r1 r11)
  (smallerThan r1 r12)
  (smallerThan r1 r13)
  (smallerThan r1 r14)
  (smallerThan r1 r15)
  (smallerThan r2 r3)
  (smallerThan r2 r4)
  (smallerThan r2 r5)
  (smallerThan r2 r6)
  (smallerThan r2 r7)
  (smallerThan r2 r8)
  (smallerThan r2 r9)
  (smallerThan r2 r10)
  (smallerThan r2 r11)
  (smallerThan r2 r12)
  (smallerThan r2 r13)
  (smallerThan r2 r14)
  (smallerThan r2 r15)
  (smallerThan r3 r4)
  (smallerThan r3 r5)
  (smallerThan r3 r6)
  (smallerThan r3 r7)
  (smallerThan r3 r8)
  (smallerThan r3 r9)
  (smallerThan r3 r10)
  (smallerThan r3 r11)
  (smallerThan r3 r12)
  (smallerThan r3 r13)
  (smallerThan r3 r14)
  (smallerThan r3 r15)
  (smallerThan r4 r5)
  (smallerThan r4 r6)
  (smallerThan r4 r7)
  (smallerThan r4 r8)
  (smallerThan r4 r9)
  (smallerThan r4 r10)
  (smallerThan r4 r11)
  (smallerThan r4 r12)
  (smallerThan r4 r13)
  (smallerThan r4 r14)
  (smallerThan r4 r15)
  (smallerThan r5 r6)
  (smallerThan r5 r7)
  (smallerThan r5 r8)
  (smallerThan r5 r9)
  (smallerThan r5 r10)
  (smallerThan r5 r11)
  (smallerThan r5 r12)
  (smallerThan r5 r13)
  (smallerThan r5 r14)
  (smallerThan r5 r15)
  (smallerThan r6 r7)
  (smallerThan r6 r8)
  (smallerThan r6 r9)
  (smallerThan r6 r10)
  (smallerThan r6 r11)
  (smallerThan r6 r12)
  (smallerThan r6 r13)
  (smallerThan r6 r14)
  (smallerThan r6 r15)
  (smallerThan r7 r8)
  (smallerThan r7 r9)
  (smallerThan r7 r10)
  (smallerThan r7 r11)
  (smallerThan r7 r12)
  (smallerThan r7 r13)
  (smallerThan r7 r14)
  (smallerThan r7 r15)
  (smallerThan r8 r9)
  (smallerThan r8 r10)
  (smallerThan r8 r11)
  (smallerThan r8 r12)
  (smallerThan r8 r13)
  (smallerThan r8 r14)
  (smallerThan r8 r15)
  (smallerThan r9 r10)
  (smallerThan r9 r11)
  (smallerThan r9 r12)
  (smallerThan r9 r13)
  (smallerThan r9 r14)
  (smallerThan r9 r15)
  (smallerThan r10 r11)
  (smallerThan r10 r12)
  (smallerThan r10 r13)
  (smallerThan r10 r14)
  (smallerThan r10 r15)
  (smallerThan r11 r12)
  (smallerThan r11 r13)
  (smallerThan r11 r14)
  (smallerThan r11 r15)
  (smallerThan r12 r13)
  (smallerThan r12 r14)
  (smallerThan r12 r15)
  (smallerThan r13 r14)
  (smallerThan r13 r15)
  (smallerThan r14 r15)
  (on r1 r2)
  (on r2 r3)
  (on r3 r4)
  (on r4 r5)
  (on r5 r6)
  (on r6 r7)
  (on r7 r8)
  (on r8 r9)
  (on r9 r10)
  (on r10 r11)
  (on r11 r12)
  (on r12 r13)
  (on r13 r14)
  (on r14 r15)
  (on r15 t1)
  (towerTop r1 t1)
  (towerTop t2 t2)
  (towerTop t3 t3))
 (:goal (and
         (on r1 r2)
         (on r2 r3)
         (on r3 r4)
         (on r4 r5)
         (on r5 r6)
         (on r6 r7)
         (on r7 r8)
         (on r8 r9)
         (on r9 r10)
         (on r10 r11)
         (on r11 r12)
         (on r12 r13)
         (on r13 r14)
         (on r14 r15)
         (on r15 t3))))