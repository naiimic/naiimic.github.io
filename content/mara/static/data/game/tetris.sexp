(program
  (= GRID_SIZE 16)

  (object Tetris (: b0 Position) (: b1 Position) (: b2 Position) (: b3 Position) (: color String) (list (Cell (.. b0 x) (.. b0 y) color) (Cell (.. b1 x) (.. b1 y) color) (Cell (.. b2 x) (.. b2 y) color) (Cell (.. b3 x) (.. b3 y) color)))


  (: blocks (List Tetris))
  (= blocks (initnext (list) (prev blocks)))
  
  (: activeTetris Tetris)
  (= activeTetris (initnext (Tetris (Position 0 0) (Position 0 1) (Position 0 2) (Position 1 2) "blue"
                                    (uniformChoice (list (Position 4 0) (Position 7 0) (Position 10 0))))
                            (nextTetris (activeTetris))))
  
  (on left (= activeTetris (moveLeftNoCollision (activeTetris))))
  (on right (= activeTetris (moveRightNoCollision (activeTetris))))
  (on up (= activeTetris (rotateNoCollision (activeTetris))))
  (on down (= activeTetris (rotateNoCollision (rotateNoCollision (rotateNoCollision (activeTetris))))))
  
  (= nextTetris (--> (tetris)
                    (if (
                    let (print ("DEBUG nextTetris"))
                        (print (isFreeRangeExceptObj 0 16 tetris))
                        (print (== (.. (nextSolid tetris) origin) (.. tetris origin)))
                        (isFreeRangeExceptObj 0 16 tetris)
                    ) then 
                      (if (== (.. (nextSolid tetris) origin) (.. tetris origin)) 
                      then (
                        let 
                        (= blocks (addObj blocks tetris))
                        (= nextPos (uniformChoice (list (Position 4 0) (Position 7 0) (Position 10 0))))
                        (uniformChoice (list 
                              (Tetris (Position 0 0) (Position 0 1) (Position 0 2) (Position 1 2) "blue" nextPos)
                              (Tetris (Position -1 0) (Position 0 0) (Position 0 1) (Position 1 0) "yellow" nextPos)
                              (Tetris (Position 0 0) (Position 0 1) (Position 1 0) (Position 1 1) "purple" nextPos)
                              (Tetris (Position 0 0) (Position 0 1) (Position 1 1) (Position 1 2) "limegreen" nextPos)))
                      ) else (nextSolid tetris))
                    else (removeObj tetris))))
)
