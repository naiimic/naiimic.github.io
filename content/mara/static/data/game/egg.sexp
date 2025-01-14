(program
  (= GRID_SIZE 16)
  (= background "gray")
  
  (object Button (: color String) (Cell 0 0 color))
  (object Piece (Cell 0 0 "gold"))
  (object Egg (list (Cell -1 -2 "tan") (Cell 0 -2 "tan") (Cell 1 -2 "tan")  
                    (Cell -2 -1 "tan") (Cell -1 -1 "tan") (Cell 0 -1 "tan") (Cell 1 -1 "tan") (Cell 2 -1 "tan")
                    (Cell -2 0 "tan") (Cell -1 0 "tan") (Cell 0 0 "tan") (Cell 1 0 "tan") (Cell 2 0 "tan") 
                    (Cell -2 1 "tan") (Cell -1 1 "tan") (Cell 0 1 "tan") (Cell 1 1 "tan") (Cell 2 1 "tan") 
                  (Cell -1 2 "tan") (Cell 0 2 "tan") (Cell 1 2 "tan")))
  
  (: egg Egg)
  (= egg (initnext (Egg (Position 7 13)) (prev egg)))
  
  (: pieces (List Piece))
  (= pieces (initnext (list) (updateObj (prev pieces) (--> obj (nextLiquid obj)))))
  
  (: button Button)
  (= button (initnext (Button "red" (Position 0 0)) (updateObj (prev button) "color" (if gravity then "pink" else "red"))))
  
  (: gravity Bool)
  (= gravity (initnext false (prev gravity)))
  
  (: height Number)
  (= height (initnext 15 (prev height)))
  
  (on (& gravity (defined "egg")) (= egg (moveDownNoCollision (prev egg))))
    
  (on (& left (& (! gravity) (defined "egg"))) (= egg (moveLeftNoCollision (prev egg))))
  (on (& right (& (! gravity) (defined "egg"))) (= egg (moveRightNoCollision (prev egg))))
  (on (& up (& (! gravity) (defined "egg"))) (= egg (moveUpNoCollision (prev egg))))
  (on (& down (& (! gravity) (defined "egg"))) (= egg (moveDownNoCollision (prev egg))))
  
  (on (& (clicked (prev button)) (defined "egg")) 
    (let (= gravity (! (prev gravity)))
         (= height (.. (.. (prev egg) origin) y))
    true
    ))
  
  (on (let 
        (& (& (defined "egg") (< height 11)) (== (.. (.. egg origin) y) 13))) 
    (let (= egg (removeObj egg)) 
         (= pieces (addObj (prev pieces) (map (--> obj (Piece (Position (.. (.. obj position) x) (+ 1 (.. (.. obj position) y))))) (renderValue (prev egg)))))
         true
         ))
)
