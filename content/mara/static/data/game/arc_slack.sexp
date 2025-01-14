(program
  (= GRID_SIZE 16)
  
  (object Particle (: active Bool) (: green Bool) (Cell 0 0 (if green then "green" else "gold")))
  (object Button (: color String) (Cell 0 0 color))
  
  (: particles (List Particle))
  (= particles (initnext (list (Particle true true (Position 1 1)) (Particle false true (Position 5 5)) (Particle false false (Position 11 14)) (Particle false true (Position 4 8)) (Particle false false (Position 9 9)) (Particle false true (Position 1 13)) (Particle false false (Position 14 5)))  
                (prev particles)))

  (: colorButton Button)
  (= colorButton (initnext (Button "gray" (Position (- GRID_SIZE 1) 0)) (prev colorButton)))

  (: removeButton Button)
  (= removeButton (initnext (Button "orangered" (Position (- GRID_SIZE 1) 2)) (prev removeButton)))
  
  (on (clicked colorButton) (= particles (updateObj particles (--> obj (updateObj obj "green" (! (.. obj green)))) (--> obj (.. obj active)))))
  (on (clicked removeButton) (= particles (updateObj particles (--> obj (removeObj obj)) (--> obj (.. obj active)))))  
  (on (clicked particles) 
      (let (= particles (updateObj particles (--> obj (updateObj obj "active" false))
                                   (--> obj (! (clicked obj)))))
           (= particles (updateObj particles (--> obj (updateObj obj "active" true)) (--> obj (clicked obj))))
           true))
  
  (on left (= particles (updateObj particles (--> obj (moveLeftNoCollision obj)) (--> obj (.. obj active)))))
  (on right (= particles (updateObj particles (--> obj (moveRightNoCollision obj)) (--> obj (.. obj active)))))
  (on up (= particles (updateObj particles (--> obj (moveUpNoCollision obj)) (--> obj (.. obj active)))))
  (on down (= particles (updateObj particles (--> obj (moveDownNoCollision obj)) (--> obj (.. obj active)))))
)
