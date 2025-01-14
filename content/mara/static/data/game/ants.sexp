(program
  (= GRID_SIZE 16)
  
  (object Ant (Cell 0 0 "gray"))
  (object Food (Cell 0 0 "red"))
  
  (: ants (List Ant))
  (= ants (initnext (list (Ant (Position 5 5)) (Ant (Position 1 14))) (prev ants)))
  
  (: foods (List Food))
  (= foods (initnext (list) (prev foods)))
  

  (on true (= foods (filter (--> obj (! (intersects obj (prev ants)))) (prev foods))))
  (on true (= ants (updateObj (prev ants) (--> obj (move obj (unitVector obj (closest obj foods)))))))

  (on clicked (= foods (addObj foods (map (--> pos (Food pos)) (randomPositions GRID_SIZE 2)))))

)
