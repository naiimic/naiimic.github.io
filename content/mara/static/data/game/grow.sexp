(program
  (= GRID_SIZE 16)
  
  (object Water (Cell 0 0 "blue"))
  (object Leaf (: color String) (Cell 0 0 color))
  (object Cloud (list (Cell -1 0 "gray") (Cell 0 0 "gray") (Cell 1 0 "gray") (Cell 2 0 "gray")
                      (Cell -1 1 "gray") (Cell 0 1 "gray") (Cell 1 1 "gray") (Cell 2 1 "gray")
                      (Cell -1 2 "gray") (Cell 0 2 "gray") (Cell 1 2 "gray") (Cell 2 2 "gray")))
  
  (object Sun (: movingLeft Bool) (list (Cell 0 0 "gold")
                                        (Cell 0 1 "gold")
                                        (Cell 1 0 "gold")
                                        (Cell 1 1 "gold")
                                        (Cell 0 2 "gold")
                                        (Cell 1 2 "gold")
                                        (Cell 2 0 "gold")
                                        (Cell 2 1 "gold")
                                        (Cell 2 2 "gold")))
  
  (: sun Sun)
  (= sun (initnext (Sun false (Position 0 0)) (prev sun)))
  
  (: water (List Water))
  (= water (initnext (list) (filter isWithinBounds (map (--> o (moveDown o)) (prev water))) ))
  
  (: cloud Cloud)
  (= cloud (initnext (Cloud (Position 13 0)) (prev cloud)))
  
  (: leaves (List Leaf))
  (= leaves (initnext (list (Leaf "green" (Position 1 15) ) (Leaf "green" (Position 3 15)) (Leaf "green" (Position 5 15)) (Leaf "green" (Position 7 15)) (Leaf "green" (Position 9 15)) (Leaf "green" (Position 11 15)) (Leaf "green" (Position 13 15)) (Leaf "green" (Position 15 15))) (prev leaves)))
  
  (on down
    (= water (addObj (prev water) (Water (.. (moveDown (prev cloud)) origin)))))
  
  (on (intersects (map (--> obj (moveDown obj)) (prev water) ) (prev leaves))
    (= water (filter (--> obj (!(intersects (moveDown obj) (prev leaves)))) water) ) )
  
  (on (and (intersects (map moveDown (prev water)) (filter (--> obj (== (.. obj color) "green")) (prev leaves))) (! (intersects (prev sun) (prev cloud))))
    (= leaves (addObj (prev leaves) (map (--> obj (Leaf (if (== (.. (.. (moveUp obj) origin) y) 12) then "mediumpurple" else "green") (.. (moveUp obj) origin))) (filter (--> obj (intersects (moveUp obj) (prev water))) (prev leaves))))))
    
  (on left (= cloud (moveLeft (prev cloud))))
  (on right (= cloud (moveRight (prev cloud))))
  
  (on (== (.. (.. (prev sun) origin) x) 0) (= sun (updateObj (prev sun) "movingLeft" false)))
  (on (== (.. (.. (prev sun) origin) x) 5) (= sun (updateObj (prev sun) "movingLeft" true)))
  
  (on (clicked (prev sun)) (= sun (if (.. (prev sun) movingLeft) then (moveLeft (prev sun)) else (moveRight (prev sun)))))
)
