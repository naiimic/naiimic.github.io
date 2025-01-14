(program
  (= GRID_SIZE 8)
  
  (object Agent (Cell 0 0 "blue"))
  (object Box (Cell 0 0 "darkorange"))
  (object Goal (Cell 0 0 "red"))
  (object Teleporter (Cell 0 0 "green"))
  (object Wall (Cell 0 0 "black"))
  
  (: agent Agent)
  (= agent (initnext (Agent (Position 3 3)) (prev agent)))
      
  (: boxes (List Box))
  (= boxes (initnext (list (Box (Position 1 6)) (Box (Position 4 1)) (Box (Position 6 4)) (Box (Position 3 6))) (prev boxes)))
  
  (: goal Goal)
  (= goal (initnext (Goal (Position 0 0)) (prev goal)))
  
  (: teleporter1 Teleporter)
  (= teleporter1 (initnext (Teleporter (Position 2 6)) (prev teleporter1)))

  (: teleporter2 Teleporter)
  (= teleporter2 (initnext (Teleporter (Position 0 4)) (prev teleporter2)))
  
  (: walls (List Wall))
  (= walls (initnext (list (Wall (Position 1 1)) 
                            (Wall (Position 1 2)) 
                            (Wall (Position 1 3)) 
                            (Wall (Position 1 4)) 
                            (Wall (Position 1 5))
                            (Wall (Position 2 1))
                            (Wall (Position 3 1))
                            (Wall (Position 5 1))
                            (Wall (Position 5 0))) (prev walls)))
  
  (on left (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) -1 0)) 
                (= agent (moveAgent (prev agent) (prev boxes) (prev goal) -1 0)))) 

  (on right (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 1 0)) 
                 (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 1 0))))

  (on up (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 0 -1)) 
              (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 0 -1))))

  (on down (let (= boxes (moveBoxes (prev boxes) (prev agent) (prev goal) 0 1)) 
                (= agent (moveAgent (prev agent) (prev boxes) (prev goal) 0 1))))
  
  (on (& clicked (isFreePos click)) (= boxes (addObj boxes (Box click))))

  (= moveBoxes (fn (boxes agent goal x y) 
                    (let (= movedBoxes (map (--> o (move o (Position x y))) boxes))
                         (= noIntersectGoalBoxes (filter (--> o (! (intersects o goal))) movedBoxes))
                         (= boxOverlapTeleporter2 (intersects (prev boxes) (prev teleporter2)))
                         (updateObj noIntersectGoalBoxes
                            (--> obj (
                                if (& (intersects obj (prev teleporter1)) (! boxOverlapTeleporter2))
                                then (updateObj obj "origin" (.. (prev teleporter2) origin)) 
                                else (moveNoCollision obj (Position x y))
                              )
                            )
                            (--> obj (== (displacement (.. obj origin) (.. agent origin)) (Position (- 0 x) (- 0 y))))))))

  (= moveAgent (fn (agent boxes goal x y) 
                    (if (| (| (intersects (move agent (Position x y)) (moveBoxes boxes agent goal x y))
                              (intersects (move agent (Position x y)) (prev walls)))
                           (! (isWithinBounds (move agent (Position x y)))))
                    then agent 
                    else (move agent (Position x y)))))
)
