(program
  (= GRID_SIZE 16)

  (object Bbq (: fire Bool) (: gas Number) (list (Cell 0 1 "gray") (Cell 1 1 "gray") (Cell 2 1 "gray") (Cell 1 0 (if fire then "orange" else "white")) (Cell 0 2 "gray") (Cell 0 3 "gray") (Cell 2 2 "gray") (Cell 2 3 "gray") (Cell 1 2 (if (> gas 20) then "yellow" else "white")) (Cell 1 3 (if (> gas 0) then "yellow" else "white"))))

  (object Person (: sick Bool) (Cell 0 0 (if sick then "green" else "blue")))
  (object Meat (: cooked Number)  (Cell 0 0 (if (< cooked 15) then "pink" else (if (< cooked 30) then "brown" else "gray"))))

  (object FillBBQ (Cell 0 0 "yellow"))

  (: bbq Bbq)
  (= bbq (initnext (Bbq true 28 (Position 7 12))
            (if (== (.. (prev bbq) gas) 0) then (updateObj (prev bbq) "fire" false) else
                  (if (.. (prev bbq) fire)
                    then (updateObj (prev bbq) "gas" (- (.. (prev bbq) gas) 1))
                    else (prev bbq)))))

  (: meat Meat)
  (= meat (initnext (Meat 0 (Position 8 11))
          (if (.. bbq fire)
            then (updateObj (prev meat) "cooked" (+ (.. (prev meat) cooked) 1))
            else (prev meat))))


  (: fillButton FillBBQ)
  (= fillButton (initnext (FillBBQ (Position 0 15)) (prev fillButton)))

  (on (clicked bbq) (= bbq (if (== (.. (prev bbq) gas) 0) then (prev bbq) else (updateObj bbq "fire" (! (.. bbq fire))))))
  (on (clicked fillButton) (= bbq (updateObj bbq "gas" (+ (.. (prev bbq) gas) 5))))
)
