(program
    (= GRID_SIZE 16)
    
    (object Particle (: color String) (Cell 0 0 color))
    
    (: particles (List Particle))
    (= particles (initnext (list) (prev "particles")))
    
    (: currColor String)
    (= currColor (initnext "red" (prev "currColor")))
    
    (on clicked (= particles (addObj (prev "particles") (Particle currColor (Position (.. click x) (.. click y))))))
    (on (and ((up)) (== (prev "currColor") "red")) (= currColor "gold"))
    (on (and ((up)) (== (prev "currColor") "gold")) (= currColor "green"))
    (on (and ((up)) (== (prev "currColor") "green")) (= currColor "blue"))
    (on (and ((up)) (== (prev "currColor") "blue")) (= currColor "purple"))
    (on (and ((up)) (== (prev "currColor") "purple")) (= currColor "red"))
)
