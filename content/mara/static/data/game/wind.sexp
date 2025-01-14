(program
  (= GRID_SIZE 17)
  
  (object Water (Cell 0 0 "lightblue"))
  (: water (List Water))
  (= water (initnext (list) (filter isWithinBounds (prev water))))

  (object Cloud (map (--> pos (Cell (.. pos x) (.. pos y) "gray")) (rect (Position 0 0) (Position 17 2))))
  (: cloud Cloud)
  (= cloud (initnext (Cloud (Position 0 0)) (prev cloud)))
  
  (: wind Number)
  (= wind (initnext 0 (prev wind)))
  
  (: time Number)
  (= time (initnext 0 (+ (prev time) 1)))
  
  (on (== wind 0) (= water (updateObj (prev water) (--> obj (moveDown obj)))))
  (on (== wind 1) (= water (updateObj (prev water) (--> obj (moveRight (moveDown obj))))))
  (on (== wind -1) (= water (updateObj (prev water) (--> obj (moveLeft (moveDown obj))))))
  
  (on left (= wind (if (== (prev wind) -1) then (prev wind) else (- (prev wind) 1))))
  (on right (= wind (if (== (prev wind) 1) then (prev wind) else (+ (prev wind) 1))))
  
  
  (on (== (% time 5) 2) 
    (= water (addObj 
              water 
              (map (--> pos (Water pos)) (list (Position 2 2)
                                                
                                              (Position 6 2)
                                              
                                              (Position 10 2)
                                              
                                              (Position 14 2))))))
)
