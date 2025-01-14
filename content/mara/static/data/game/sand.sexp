(program
  (= GRID_SIZE 10)
  
  (object Button (: color String) (Cell 0 0 color))
  (object Sand (: liquid Bool) (Cell 0 0 (if liquid then "sandybrown" else "tan")))
  (object Water (Cell 0 0 "skyblue"))
  
  (: sandButton Button)
  (= sandButton (initnext (Button "red" (Position 2 0)) (prev sandButton)))
  
  (: waterButton Button)
  (= waterButton (initnext (Button "green" (Position 7 0)) (prev waterButton)))
  
  (: sand (List Sand))
  (= sand (initnext (list (Sand false (Position 2 9)) (Sand false (Position 3 9)) (Sand false (Position 4 9)) (Sand false (Position 5 9)) (Sand false (Position 6 9)) (Sand false (Position 7 9))
                          (Sand false (Position 2 8)) (Sand false (Position 3 8)) (Sand false (Position 4 8)) (Sand false (Position 5 8)) (Sand false (Position 6 8)) (Sand false (Position 7 8))
                          (Sand false (Position 2 7)) (Sand false (Position 3 7)) (Sand false (Position 4 7)) (Sand false (Position 5 7)) (Sand false (Position 6 7)) (Sand false (Position 7 7))
                          (Sand false (Position 2 6)) (Sand false (Position 4 6))  (Sand false (Position 5 6)) (Sand false (Position 7 6))
                          (Sand false (Position 2 5)) (Sand false (Position 4 5))  (Sand false (Position 5 5)) (Sand false (Position 7 5))                    
                    )
            		(prev sand)))
  
  (: water (List Water))
  (= water (initnext (list) (updateObj (prev water) (--> obj (nextLiquid obj)))))
  
  
  (: clickType String)
  (= clickType (initnext "sand" (prev "clickType")))
  
  (on true (let 
          (= sand (updateObj sand (--> obj (if (.. obj liquid) then (nextLiquid obj) else (nextSolid obj)))))
          (= sand (updateObj sand (--> obj (updateObj obj "liquid" true)) (--> obj (let
                (& (! (.. obj liquid)) (intersects (adjacentObjs obj 1) (prev water)))))))
          true
  ))
    
  (on (clicked sandButton) (= clickType "sand"))
  (on (clicked waterButton) (= clickType "water"))
  (on (& (& ((clicked)) (isFreePos click)) (== clickType "sand"))  (= sand (addObj sand (Sand false (Position (.. click x) (.. click y))))))
  (on (& (& ((clicked)) (isFreePos click)) (== clickType "water")) (= water (addObj water (Water (Position (.. click x) (.. click y))))))
    
)
