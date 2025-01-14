(program
  (= GRID_SIZE 16)

  (object Key (list (Cell 0 0 "blue") (Cell 0 1 "blue")))
  (object Lock (list (Cell 0 0 "red") (Cell 0 1 "red") (Cell 0 2 "red") (Cell 0 3 "red") (Cell 1 2 "red") (Cell 1 3 "red") (Cell 2 0 "red") (Cell 2 1 "red") (Cell 2 2 "red") (Cell 2 3 "red")))
  (object Wall (list (Cell 0 0 "gray") (Cell 1 0 "gray") (Cell 2 0 "gray") (Cell 3 0 "gray") (Cell 4 0 "gray")))

  (: fixedLock Lock)
  (= fixedLock (initnext (Lock (Position 0 7)) (prev fixedLock)))

  (: mobileKey Key)
  (= mobileKey (initnext (Key (Position 0 0)) (prev mobileKey)))

  (: movingWall Wall)
  (= movingWall (initnext (Wall (Position 3 7)) (prev movingWall)))

  (on left (= mobileKey (moveLeftNoCollision (prev mobileKey))))
  (on right (= mobileKey (moveRightNoCollision (prev mobileKey))))
  (on up (= mobileKey (moveUpNoCollision (prev mobileKey))))
  (on down (= mobileKey (moveDownNoCollision (prev mobileKey))))
  (on (& (== (.. mobileKey origin) (Position 1 7)) (!= (.. movingWall origin) (Position 4 7))) (= movingWall (moveLeft (prev movingWall))))
  (on (& (!= (.. mobileKey origin) (Position 1 7)) (== (.. movingWall origin) (Position 4 7))) (= movingWall (moveRight (prev movingWall))))

)
