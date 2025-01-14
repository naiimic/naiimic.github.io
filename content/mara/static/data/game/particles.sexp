(program
         (= GRID_SIZE 16)

         (object Particle (Cell 0 0 "blue"))

         (: particles (List Particle))
         (= particles 
            (initnext (list) 
                      (updateObj (prev particles) (--> obj (Particle (uniformChoice (adjPositions (.. obj origin)))))))) 

         (on clicked (= particles (addObj (prev particles) (Particle (Position (.. click x) (.. click y)))))))