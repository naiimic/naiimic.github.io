(program
  (= GRID_SIZE 16)
  
  (object Light (: turnedOn Bool) (Cell 0 0 (if turnedOn then "yellow" else "white")))
  
  (: lights (List Light))
  (= lights (initnext (map (--> pos (Light false pos)) (filter (--> pos (== (.. pos x) (.. pos y))) (allPositions GRID_SIZE))) 
                      (prev lights)))
  
  (on clicked (= lights (updateObj lights (--> obj (updateObj obj "turnedOn" (! (.. obj turnedOn)))))))
  )