(program 
      (= GRID_SIZE 16)
    
      (object Goal (Cell 0 0 "green"))
      (: goal Goal)
      (= goal (initnext (Goal (Position 0 10)) (prev goal)))
    
      (object Ball (: direction Number) (: color String) (Cell 0 0 color))
      (object Wall (: visible Bool)(list (Cell 0 0 (if visible then "gray" else "white")) (Cell 0 1 (if visible then "gray" else "white")) (Cell 0 2 (if visible then "gray" else "white"))))
    
      (: wall Wall)
      (= wall (initnext (Wall true (Position 4 9)) (prev wall)))
    
      (= nextBall (fn (ball)
                    (if (== (.. ball direction) 1)
      then (updateObj ball "origin"
             (Position (.. (.. ball origin) x) (- (.. (.. ball origin) y) 1)))
      else
      (if (== (.. ball direction) 2)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (- (.. (.. ball origin) y) 1)))
      else
      (if (== (.. ball direction) 3)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (.. (.. ball origin) y)))
      else
      (if (== (.. ball direction) 4)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (+ (.. (.. ball origin) y) 1)))
      else
      (if (== (.. ball direction) 5)
      then (updateObj ball "origin"
             (Position (.. (.. ball origin) x) (+ (.. (.. ball origin) y) 1)))
      else
      (if (== (.. ball direction) 6)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (+ (.. (.. ball origin) y) 1)))
      else
      (if (== (.. ball direction) 7)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (.. (.. ball origin) y)))
      else
      (if (== (.. ball direction) 8)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (- (.. (.. ball origin) y) 1)))
      else ball))))))))))
    
    
      (on (clicked wall) (= wall (updateObj wall "visible" (! (.. wall visible)))))
    
      (= wallintersect (fn (ball)
                         (if (& (== (.. ball direction) 4) (== (.. (.. ball origin) y) 15)) then 2 else
      (if (& (== (.. ball direction) 5) (== (.. (.. ball origin) y) 15)) then 1 else
      (if (& (== (.. ball direction) 6) (== (.. (.. ball origin) y) 15)) then 8 else
      (if (& (== (.. ball direction) 6) (== (.. (.. ball origin) x) 0)) then 4 else
      (if (& (== (.. ball direction) 7) (== (.. (.. ball origin) x) 0)) then 3 else
      (if (& (== (.. ball direction) 8) (== (.. (.. ball origin) x) 0)) then 2 else
      (if (& (== (.. ball direction) 2) (== (.. (.. ball origin) x) 15)) then 8 else
      (if (& (== (.. ball direction) 3) (== (.. (.. ball origin) x) 15)) then 7 else
      (if (& (== (.. ball direction) 4) (== (.. (.. ball origin) x) 15)) then 6 else
      (if (& (== (.. ball direction) 8) (== (.. (.. ball origin) y) 0)) then 6 else
      (if (& (== (.. ball direction) 1) (== (.. (.. ball origin) y) 0)) then 5 else
      (if (& (== (.. ball direction) 2) (== (.. (.. ball origin) y) 0)) then 4 else
    
      (.. ball direction)))))))))))))))
    
    
      (: ball_a Ball)
      (= ball_a (initnext (Ball 7 "blue" (Position 15 10)) (if (intersects ball_a ball_b) then (nextBall (updateObj (prev ball_a) "direction" 6)) else (nextBall (updateObj (prev ball_a) "direction" (wallintersect (prev ball_a)))))))
    
      (: ball_b Ball)
      (= ball_b (initnext (Ball 6 "red" (Position 15 5)) (if (intersects (prev ball_a) ball_b) then (nextBall (updateObj (prev ball_b) "direction" 2)) else (nextBall (updateObj (prev ball_b) "direction" (wallintersect (prev ball_b)))))))
      )
