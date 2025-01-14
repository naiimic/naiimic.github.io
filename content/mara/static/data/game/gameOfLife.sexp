(program
  (= GRID_SIZE 16)
  
  (object Particle (: living Bool) (Cell 0 0 (if living then "gray" else "white")))
  
  (: particles (List Particle))
  (= particles (initnext (map (--> (pos) (Particle false pos)) (allPositions GRID_SIZE)) 
                (prev particles)))
  
  (: time Number)
  (= time (initnext 0 (+ (prev time) 1)))
    
  (on (& ((clicked)) (< time 20)) (= particles (addObj (removeObj (prev particles) (--> obj (clicked obj))) (Particle true click))))
  (on (> time 20) (= particles 
                      (let (= livingObjs (filter (--> o (.. o living)) (prev particles)))
                           (updateObj (prev particles) 
                           (--> obj  
                           (let (= livingAdjObjs (filter (--> o (adjacentTwoObjsDiag obj o)) livingObjs))
                                 (if (& (.. obj living)
                                        (| (<= (length livingAdjObjs) 1)
                                           (>= (length livingAdjObjs) 4)))
                                 then (updateObj obj "living" false)
                                 else (if (& (! (.. obj living))
                                          (== (length livingAdjObjs) 3))
                                           then (updateObj obj "living" true) else obj))))))))
)
