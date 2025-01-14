(program
    (= GRID_SIZE 16)
    (object CelestialBody (: day Bool) (list (Cell 0 0 (if day then "gold" else "gray"))
                                            (Cell 0 1 (if day then "gold" else "gray"))
                                            (Cell 1 0 (if day then "gold" else "gray"))
                                            (Cell 1 1 (if day then "gold" else "gray"))))
    (object Cloud (list (Cell -1 0 "gray")
                        (Cell 0 0 "gray")
                        (Cell 1 0 "gray")))
    
    (object Water (: liquid Bool) (Cell 0 0 (if liquid then "blue" else "lightblue")))
    
    (: celestialBody CelestialBody)
    (= celestialBody (initnext (CelestialBody true (Position 0 0)) (prev celestialBody)))
    
    (: cloud Cloud)
    (= cloud (initnext (Cloud (Position 4 0)) (prev cloud)))
    
    (: water (List Water))
    (= water (initnext (list) (updateObj (prev water) nextWater)))
    
    (on left (= cloud (nextCloud cloud (Position -1 0))))
    (on right (= cloud (nextCloud cloud (Position 1 0))))
    (on down (= water (addObj water (Water (.. celestialBody day) (movePos (.. cloud origin) (Position 0 1))))))
    (on clicked (let 
      (= celestialBody (updateObj celestialBody "day" (! (.. celestialBody day))))
      (= water (updateObj water (--> drop (updateObj drop "liquid" (! (.. drop liquid))))))
    ))
    
    (= nextWater (--> (drop) 
                    (if (.. drop liquid)
                      then (nextLiquid drop)
                      else (nextSolid drop))))
    
    (= nextCloud (--> (cloud position)
                    (if (isWithinBounds (move cloud position)) 
                      then (move cloud position)
                      else cloud)))
)