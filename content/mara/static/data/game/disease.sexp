(program
(= GRID_SIZE 16)
(object Particle (: health Bool) (Cell 0 0 (if health then "gray" else "darkgreen")))
(: inactiveParticles (List Particle))
(= inactiveParticles (initnext (list (Particle true (Position 7 5)) (Particle true (Position 4 3)) (Particle true (Position 6 6)) (Particle true (Position 3 5))) (updateObj (prev inactiveParticles)
          (--> obj (if true then (updateObj obj "health" false) else obj))
          (--> obj (adj obj
                        (filter (--> o2 (! (.. o2 health))) (vcat (list (list (prev activeParticle)) (prev inactiveParticles))))
                        1)))))
(: activeParticle Particle)
(= activeParticle (initnext (Particle false (Position 2 2)) (prev activeParticle)))
(on (any (--> obj (! (.. obj health))) (adjacentObjs activeParticle 1)) (= activeParticle (updateObj activeParticle "health" false)))
(on (clicked (prev inactiveParticles)) (let 
        (= inactiveParticles (addObj (filter (--> obj (! (clicked obj))) (prev inactiveParticles)) activeParticle))
        (= activeParticle (head (objClicked (prev inactiveParticles))))
        true
        ))
(on left (= activeParticle (move (prev activeParticle) (Position -1 0))))
(on right (= activeParticle (move (prev activeParticle) (Position 1 0))))
(on up (= activeParticle (move (prev activeParticle) (Position 0 -1))))
(on down (= activeParticle (move (prev activeParticle) (Position 0 1))))
)
