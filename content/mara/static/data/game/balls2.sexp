(program
      (= GRID_SIZE 16)
    
      (object Goal (Cell 0 0 "green"))
      (: goal Goal)
      (= goal (initnext (Goal (Position 0 10)) (prev goal)))
    
      (object Ball (: direction Number) (: color String) (Cell 0 0 color))
    
      (= nextBall (fn (ball)
                    (if (< (.. ball direction) 45)
      then (updateObj ball "origin"
             (Position (.. (.. ball origin) x) (- (.. (.. ball origin) y) 1)))
      else
      (if (< (.. ball direction) 90)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (- (.. (.. ball origin) y) 1)))
      else
      (if (< (.. ball direction) 135)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (.. (.. ball origin) y)))
      else
      (if (< (.. ball direction) 180)
      then (updateObj ball "origin"
             (Position (+ (.. (.. ball origin) x) 1) (+ (.. (.. ball origin) y) 1)))
      else
      (if (< (.. ball direction) 225)
      then (updateObj ball "origin"
             (Position (.. (.. ball origin) x) (+ (.. (.. ball origin) y) 1)))
      else
      (if (< (.. ball direction) 270)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (+ (.. (.. ball origin) y) 1)))
      else
      (if (< (.. ball direction) 315)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (.. (.. ball origin) y)))
      else
      (if (< (.. ball direction) 360)
      then (updateObj ball "origin"
             (Position (- (.. (.. ball origin) x) 1) (- (.. (.. ball origin) y) 1)))
      else ball))))))))))
    
    
      (on (clicked goal) (= goal (prev goal)))
    
      (= wallintersect (fn (ball)
                         (if (& (< (.. ball direction) 180) (== (.. (.. ball origin) y) 15)) then (- 180 (.. ball direction)) else
      (if (& (== (.. ball direction) 180) (== (.. (.. ball origin) y) 15)) then 0 else
      (if (& (> (.. ball direction) 180) (== (.. (.. ball origin) y) 15)) then (+ 90 (.. ball direction)) else
      (if (& (& (< (.. ball direction) 270) (> (.. ball direction) 180)) (== (.. (.. ball origin) x) 0)) then (- 360 (.. ball direction)) else
      (if (& (== (.. ball direction) 270) (== (.. (.. ball origin) x) 0)) then 90 else
      (if (& (> (.. ball direction) 270) (== (.. (.. ball origin) x) 0)) then (- 360 (.. ball direction)) else
      (if (& (< (.. ball direction) 90) (== (.. (.. ball origin) x) 15)) then (+ 270 (.. ball direction)) else
      (if (& (== (.. ball direction) 90) (== (.. (.. ball origin) x) 15)) then 270 else
      (if (& (> (.. ball direction) 90) (== (.. (.. ball origin) x) 15)) then (+ 90 (.. ball direction)) else
      (if (& (> (.. ball direction) 180) (== (.. (.. ball origin) y) 0)) then (- 520 (.. ball direction)) else
      (if (& (== (.. ball direction) 45) (== (.. (.. ball origin) y) 0)) then 180 else
      (if (& (< (.. ball direction) 180) (== (.. (.. ball origin) y) 0)) then (- 180 (.. ball direction)) else
      (.. ball direction)))))))))))))))
    
      (= ballcollision (fn (ball1 ball2)
                         (.. ball2 direction)
              ))
    
      (: ball_a Ball)
      (= ball_a (initnext (Ball 361 "blue" (Position 6 10)) (if (intersects ball_a ball_b) then (nextBall (updateObj (prev ball_a) "direction" (ballcollision (prev ball_a) (prev ball_b)))) else (nextBall (updateObj (prev ball_a) "direction" (wallintersect (prev ball_a)))))))
    
      (: ball_b Ball)
      (= ball_b (initnext (Ball 361 "red" (Position 10 10)) (if (intersects ball_b ball_c) then (nextBall (updateObj (prev ball_b) "direction" (ballcollision (prev ball_b) (prev ball_c)))) else (if (intersects (prev ball_a) ball_b) then (nextBall (updateObj (prev ball_b) "direction" 361)) else (nextBall (updateObj (prev ball_b) "direction" (wallintersect (prev ball_b))))))))
    
      (: ball_c Ball)
      (= ball_c (initnext (Ball 270 "purple" (Position 14 10)) (if (intersects (prev ball_b) ball_c) then (nextBall (updateObj (prev ball_c) "direction" 361)) else (nextBall (updateObj (prev ball_c) "direction" (wallintersect (prev ball_c)))))))
    
      (on (intersects ball_a goal) (= ball_a (updateObj ball_a "direction" 361)))
    )
