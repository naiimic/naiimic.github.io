(program
  (= GRID_SIZE 28)
  (= background "black")
  
  (object Rink (map (--> pos (Cell (.. pos x) (.. pos y) "lightblue")) (rect (Position 0 0) (Position 22 22))))
  (object Skater (Cell 0 0 "red"))
    
  (: rink Rink)
  (= rink (initnext (Rink (Position 3 3)) (prev rink)) )
  
  (: skater Skater)
  (= skater (initnext (Skater (Position 0 0)) (prev skater)))
  
  (: slide String)
  (= slide (initnext "none" (prev "slide")))
  
  (on left (= skater (moveLeft skater)))
  (on right (= skater (moveRight skater)))
  (on up (= skater (moveUp skater)))
  (on down (= skater (moveDown skater)))
    
  (on (& left (! (in slide (list "none" "right")))) (= slide "left"))
  (on (& right (! (in slide (list "none" "left")))) (= slide "right"))
  (on (& up (! (in slide (list "none" "down")))) (= slide "up"))
  (on (& down (! (in slide (list "none" "up")))) (= slide "down"))

  (on (& (!= (prev "slide") "none") (! (intersects (prev skater) rink))) 
    (= slide "none"))  
  
  (on (== slide "left") (= skater (move (prev skater) (Position -2 0))))
  (on (== slide "right") (= skater (move (prev skater) (Position 2 0))))
  (on (== slide "up") (= skater (move (prev skater) (Position 0 -2))))
  (on (== slide "down") (= skater (move (prev skater) (Position 0 2))))

   
  (on (& (! (intersects (prev skater) rink)) (intersects skater rink)) 
    (= slide (if left then "left" else (if right then "right" else (if up then "up" else "down")))))    
)
