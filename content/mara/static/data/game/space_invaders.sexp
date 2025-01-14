(program
(= GRID_SIZE 16)

(object Enemy (Cell 0 0 "blue"))
(object Hero (: alive Bool) (Cell 0 0 "gray"))
(object Bullet (Cell 0 0 "red"))
(object EnemyBullet (Cell 0 0 "orange"))

(: enemies1 (List Enemy))
(= enemies1 (initnext (map 
                        (--> pos (Enemy pos)) 
                        (filter (--> pos (and (== (.. pos y) 1) (== (% (.. pos x) 3) 1))) (allPositions GRID_SIZE)))
                      (prev "enemies1")))

(: enemies2 (List Enemy))
(= enemies2 (initnext (map 
                        (--> pos (Enemy pos)) 
                        (filter (--> pos (and (== (.. pos y) 3) (== (% (.. pos x) 3) 2))) (allPositions GRID_SIZE)))
                      (prev "enemies2")))


(: hero Hero)
(= hero (initnext (Hero true (Position 8 15)) (prev "hero")))

(: enemyBullets (List EnemyBullet))
(= enemyBullets (initnext (list) (prev "enemyBullets")))

(: bullets (List Bullet))
(= bullets (initnext (list) (prev "bullets")))

(: time Int)
(= time (initnext 0 (+ (prev "time") 1)))                                                         

(on true (= enemyBullets (updateObj enemyBullets (--> obj (moveDown obj)))))
(on true (= bullets (updateObj bullets (--> obj (moveUp obj)))))
(on left (= hero (moveLeftNoCollision (prev "hero"))))
(on right (= hero (moveRightNoCollision (prev "hero"))))
(on (and ((up)) (.. (prev "hero") alive)) (= bullets (addObj bullets (Bullet (.. (prev "hero") origin)))))  

(on (== (% time 10) 5) (= enemies1 (updateObj enemies1 (--> obj (moveLeft obj)))))
(on (== (% time 10) 0) (= enemies1 (updateObj enemies1 (--> obj (moveRight obj)))))

(on (== (% time 10) 5) (= enemies2 (updateObj enemies2 (--> obj (moveRight obj)))))
(on (== (% time 10) 0) (= enemies2 (updateObj enemies2 (--> obj (moveLeft obj)))))

(on (intersects (prev "bullets") (prev "enemies1"))
  (let (= bullets (removeObj (prev "bullets") (--> obj (intersects obj (prev "enemies1")))))
        (= enemies1 (removeObj (prev "enemies1") (--> obj (intersects obj (prev "bullets"))))))
)          
        
(on (intersects (prev "bullets") (prev "enemies2"))
  (let (= bullets (removeObj (prev "bullets") (--> obj (intersects obj (prev enemies2)))))
        (= enemies2 (removeObj (prev "enemies2") (--> obj (intersects obj (prev bullets))))))
)
        
(on (== (% time 5) 2) (= enemyBullets (addObj enemyBullets (EnemyBullet (uniformChoice (map (--> obj (.. obj origin)) (concat (list (prev "enemies1") (prev "enemies2")))))))))         
(on (intersects (prev "hero") (prev "enemyBullets")) (= hero (updateObj (prev "hero") "alive" false))
)

(on (intersects (prev "bullets") (prev "enemyBullets")) 
  (let 
    (= bullets (removeObj (prev "bullets") (--> obj (intersects obj (prev enemyBullets))))) 
    (= enemyBullets (removeObj (prev "enemyBullets") (--> obj (intersects obj (prev bullets)))))
    true
    ))           
)
