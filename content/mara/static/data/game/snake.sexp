(program
  (= GRID_SIZE 16)
  
  (object Snake (: snakeHead Cell) (: snakeTail (List Cell)) (: direction Position) (concat (list (list snakeHead) snakeTail)))
  (object Food (Cell 0 0 "pink"))
  
  (: snake Snake)
  (= snake (initnext (Snake (Cell 7 7 "green") (list (Cell 8 7 "green")) (Position -1 0) (Position 0 0)) 
                      (nextSnake (prev snake) (prev food))))
  
  (: food Food)
  (= food (initnext (Food (Position 10 8)) (nextFood food)))


  (= moveWrapPos (fn (pos dir) (Position (% (+ (.. pos x) (+ (.. dir x) GRID_SIZE)) GRID_SIZE) (% (+ (.. pos y) (+ (.. dir y) GRID_SIZE)) GRID_SIZE))))
  (= nextSnake (fn (snake food) (let 
          (= snakeHead (.. snake snakeHead))
          (= direction (.. snake direction))
          (= snakeTail (.. snake snakeTail))
          (= snakeHeadPos (Position ((.. snakeHead x)) ((.. snakeHead y))))
          (= snakeHeadPos (moveWrapPos snakeHeadPos direction))
          (= newSnakeHead (Cell (.. snakeHeadPos x) (.. snakeHeadPos y) "green"))
          (= snakeTail (if (! (intersects (prev food) (prev snake))) then (removeObj snakeTail (tail snakeTail)) else snakeTail))
          (= snakeTail (concat (list (list snakeHead) snakeTail)))
          (= newSnake (Snake newSnakeHead snakeTail direction (.. snake origin)))
          newSnake)
  ))
  
  (= nextFood (fn (food) (if (! (intersects food snake))
                          then food 
                          else (Food (uniformChoice (filter isFreePos (allPositions GRID_SIZE)))))))
  
  (on left (= snake (if (== (.. (.. snake snakeHead) color) "red") then snake else (updateObj (prev snake) "direction" (Position -1 0)))))
  (on right (= snake (if (== (.. (.. snake snakeHead) color) "red") then snake else (updateObj (prev snake) "direction" (Position 1 0)))))
  (on up (= snake (if (== (.. (.. snake snakeHead) color) "red") then snake else (updateObj (prev snake) "direction" (Position 0 -1)))))
  (on down (= snake (if (== (.. (.. snake snakeHead) color) "red") then snake else (updateObj (prev snake) "direction" (Position 0 1)))))
)
