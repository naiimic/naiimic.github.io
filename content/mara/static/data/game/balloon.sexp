(program
  (= GRID_SIZE 16)
  (= background "skyblue")
  
  (object Rock (Cell 0 0 "gray"))
  (object Balloon (: color String) (list (Cell -1 -2 color) (Cell 0 -2 color) (Cell 1 -2 color)  
                      (Cell -2 -1 color) (Cell -1 -1 color) (Cell 0 -1 color) (Cell 1 -1 color) (Cell 2 -1 color)
                      (Cell -2 0 color) (Cell -1 0 color) (Cell 0 0 color) (Cell 1 0 color) (Cell 2 0 color) 
                      (Cell -2 1 color) (Cell -1 1 color) (Cell 0 1 color) (Cell 1 1 color) (Cell 2 1 color) 
                      (Cell -1 2 color) (Cell 0 2 color) (Cell 1 2 color) 
                      (Cell -1 3 "tan") (Cell 0 4 "tan") (Cell 1 3 "tan")
                      (Cell -1 5 "tan") (Cell 1 5 "tan")
                      (Cell -2 6 "brown") (Cell -2 7 "brown") (Cell -2 8 "brown")
                      (Cell 2 6 "brown") (Cell 2 7 "brown") (Cell 2 8 "brown")
                      (Cell -1 8 "brown") (Cell 0 8 "brown") (Cell 1 8 "brown")      
                  ))

  (: balloon Balloon)
  (= balloon (initnext (Balloon "mediumpurple" (Position 7 7)) (prev balloon)))
  
  (: rocks (List Rock))
  (= rocks (initnext (list) (updateObj (prev rocks) (--> obj (nextSolid obj)))) )
  
  (: weight Bool)
  (= weight (initnext false (prev weight)))

  (= calc_num_contained (fn (rocks balloon)
    (let (= rect_start (movePos (.. balloon origin) (Position -2 0)))
        (= rect_end (movePos (.. balloon origin) (Position 2 7)))
        (= still_rocks (filter (--> obj (intersects obj (nextSolid obj))) rocks))
        (= still_rocks_poss (map (--> obj (.. obj origin)) still_rocks))
        (= num_contained (length (filter (--> pos (
        & (<= (.. pos x) (.. rect_end x))
          (& (<= (.. rect_start x) (.. pos x))
            (& (<= (.. pos y) (.. rect_end y))
              (<= (.. rect_start y) (.. pos y))
            )
          )
        )) still_rocks_poss)))
        num_contained))
  )
  
  (on (
  let (= num_contained (calc_num_contained rocks balloon))
      (>= num_contained 3))
      (let (= weight true)
            true
            )
      )

  (on (< (calc_num_contained rocks balloon) 3)
      (= weight false))
  
  (on (prev weight) 
    (let 
        (= rocks (updateObj 
                    (prev rocks) 
                    (--> obj (if (| (! (intersects obj (nextSolid obj))) (isWithinBounds (moveDown (prev balloon)))) then (moveDown obj) else obj)) 
                    (--> obj (intersectsPosPoss (.. obj origin) 
              (rect (movePos (.. (prev balloon) origin) (Position -2 0)) 
                    (movePos (.. (prev balloon) origin) (Position 2 7)))))))
        (= balloon (if (! (isWithinBounds (moveDown (prev balloon)))) then (prev balloon) else (moveDown (prev balloon))))))

  (on (! (prev weight)) 
    (let 
        (= rocks (updateObj 
                    (prev rocks) 
                    (--> obj (if (! (isWithinBounds (moveUp (prev balloon)))) then (nextSolid obj) else (moveUp obj))) 
                    (--> obj (intersectsPosPoss (.. obj origin) 
              (rect (movePos (.. (prev balloon) origin) (Position -2 0)) 
                    (movePos (.. (prev balloon) origin) (Position 2 7)))))))
        (= balloon (if (! (isWithinBounds (moveUp (prev balloon)))) then (prev balloon) else (moveUp (prev balloon))))))  
  
  (on (& ((clicked)) (isFreePos click)) (= rocks (addObj (prev rocks) (Rock (Position (.. click x) (.. click y ))))))

  (on (clicked (prev rocks)) 
    (= rocks (removeObj 
                (prev rocks) 
                (--> obj (clicked obj))))) 
)
