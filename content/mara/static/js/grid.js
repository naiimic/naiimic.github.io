// Configuration constants
const UPDATE_INTERVAL = 100;
const FRAME_RATE = 250;
const CLICK_ANIMATION_DURATION = 300;

let autumnstdlib = `
(module
  (= move (--> (obj dir) 
    (updateObj obj "origin" 
      (Position 
        (+ (.. (.. obj origin) x) (.. dir x))
        (+ (.. (.. obj origin) y) (.. dir y))
      )
    )
  ))
  
  (= moveRight (--> obj (move obj (Position 1 0))))
  (= moveLeft (--> obj (move obj (Position -1 0))))
  (= moveUp (--> obj (move obj (Position 0 -1))))
  (= moveDown (--> obj (move obj (Position 0 1))))

  (= moveNoCollision (--> (obj x y) 
    (if (isFreeExcept (move obj (Position x y)) obj) then (move obj (Position x y)) else obj)
  ))


  (= rotateNoCollision (--> (obj)
    (if (& (isWithinBounds (rotate obj)) (isFreeExcept (rotate obj) obj)) then (rotate obj) else obj)
  ))

  (= movePos (--> (pos dir)
    (Position 
      (+ (.. pos x) (.. dir x))
      (+ (.. pos y) (.. dir y))
    )
  ))

  (= moveRightPos (--> pos (movePos pos (Position 1 0))))
  (= moveLeftPos (--> pos (movePos pos (Position -1 0))))
  (= moveUpPos (--> pos (movePos pos (Position 0 -1))))
  (= moveDownPos (--> pos (movePos pos (Position 0 1))))

  (= abs (--> x (if (< x 0) then (- x) else x)))
  
  (= sign (--> x 
    (if (== x 0) 
      then 0 
      else (if (< x 0) then -1 else 1))
  ))

  (= vcat concat)
  
  (= deltaPos (--> (pos1 pos2) 
    (Position 
      (- (.. pos2 x) (.. pos1 x)) 
      (- (.. pos2 y) (.. pos1 y))
    )
  ))

  (= rect (--> (pos1 pos2) (
    let (= xmin (.. pos1 x))
        (= xmax (.. pos2 x))
        (= ymin (.. pos1 y))
        (= ymax (.. pos2 y))
        (= rectPos (concat (map (--> y (map (--> x (Position x y)) (range xmin xmax))) (range ymin ymax))))
        rectPos
  )))

  (= displacement deltaPos)

  (= deltaElem (--> (e1 e2)
    (deltaPos (.. e1 position) (.. e2 position))
  ))

  (= deltaObj (--> (obj1 obj2)
    (deltaPos (.. obj1 origin) (.. obj2 origin))
  ))


  (= adjacentElem (--> (e1 e2) (
      let (= delta (deltaPos (.. e1 position) (.. e2 position)))
          (== (+ (abs (.. delta x)) (abs (.. delta y))) 1)
      )
  ))

  (= adjacentPoss (--> (p1 p2 unitSize) (
    let (= delta (deltaPos p1 p2))
        (<= (+ (abs (.. delta x)) (abs (.. delta y))) unitSize)
    )
  ))

  (= adjacentTwoObjs (--> (obj1 obj2 unitSize) (
    adjacentPoss (.. obj1 origin) (.. obj2 origin) unitSize
  )))

  (= adjacentPossDiag (--> (p1 p2) (
    let (= delta (deltaPos p1 p2))
        (& (<= (abs (.. delta x)) 1)
           (<= (abs (.. delta y)) 1))

  )))

  (= adjacentTwoObjsDiag (--> (obj1 obj2) (
    adjacentPossDiag (.. obj1 origin) (.. obj2 origin)
  )))


  (= adjacentObjs (--> (obj1 unitSize) 
    (if (isList obj1) then 
    (filter (--> obj2 (any (--> o1 (adjacentTwoObjs o1 obj2 unitSize)) obj1)) ((allObjs)))
    else
    (filter (--> obj2 (adjacentTwoObjs obj1 obj2 unitSize)) ((allObjs)))
  )))

  (= adjacentObjsDiag (--> obj (
    if (isList obj) then 
    (filter (--> obj2 (any (--> o1 (adjacentTwoObjsDiag o1 obj2)) obj)) ((allObjs)))
    else
    (filter (--> obj2 (adjacentTwoObjsDiag obj obj2)) ((allObjs)))
  )))


  (= adj (--> (obj objs unitSize)
    (any (--> obj2 (adjacentTwoObjs obj obj2 unitSize)) objs)
  ))

  (= objClicked (--> (objs) (
    filter (--> obj (clicked obj)) objs
  )))

  (= sqdist (--> (pos1 pos2) 
           (let 
             (= delta (deltaPos pos1 pos2))
             (+ (* (.. delta x) (.. delta x)) (* (.. delta y) (.. delta y)))
           )
  ))
  
  (= unitVector (--> (obj target)
    (let
      (= delta (deltaPos (.. obj origin) (.. target origin)))
      (= sign_x (sign (.. delta x)))
      (= sign_y (sign (.. delta y)))
      (if (and (== (abs sign_x) 1)
               (== (abs sign_y) 1)) then
          (Position sign_x 0) else (Position sign_x sign_y)
      )
    )))

  (= unitVectorObjPos (--> (obj pos)
    (let
      (= delta (deltaPos (.. obj origin) pos))
      (= sign_x (sign (.. delta x)))
      (= sign_y (sign (.. delta y)))
      (if (and (== (abs sign_x) 1)
               (== (abs sign_y) 1)) then
          (Position sign_x 0) else (Position sign_x sign_y)
      )
    )
  ))

  (= max (--> (a b) (if (< a b) then b else a)))
  (= min (--> (a b) (if (< a b) then a else b)))

  (= closest (--> (obj listObjs) 
            (if (== (length listObjs) 0) then obj else
            (foldl (--> (obj1 obj2) 
              (if (< (sqdist (.. obj1 origin) (.. obj origin)) (sqdist (.. obj2 origin) (.. obj origin))) then obj1 else obj2
            )) (head listObjs) listObjs)
            )))

  (= closestPos (--> (obj listPoss)
            (if (== (length listPoss) 0) then (.. obj origin) else
            (foldl (--> (pos1 pos2) 
              (if (< (sqdist pos1 (.. obj origin)) (sqdist pos2 (.. obj origin))) then pos1 else pos2
            )) (head listPoss) listPoss)
            )))

  (= renderValue (--> obj (if (isList obj) then (concat (map renderValue obj)) else ((.. obj render)))))


  (= intersectsElems (--> (elems1 elems2) (
        if (or (== (length elems1) 0) (== (length elems2) 0)) then false else
        (any (--> elem1
                  (any (--> elem2 (== (.. elem1 position) (.. elem2 position))) elems2)) elems1)
        )
  ))

  (= intersectsPosElems (--> (pos elems) 
                          (any (--> elem (== (.. elem position) pos)) elems)))

  (= intersectsPosPoss (--> (pos poss) 
                          (any (--> pos2 (== pos pos2)) poss)))


  (= intersects (--> (obj1 obj2) (intersectsElems (renderValue obj1) (renderValue obj2))))

  (= isFree (--> obj (! (any (--> e (! (isFreePos (.. e position)))) (renderValue obj)))))


  (= in (--> (e l) (any (--> x (== x e)) l)))

  (= isFreeExcept (--> (obj prev_obj) (
    let (= prev_elems (renderValue prev_obj))
        (= curr_elems (renderValue obj))
        (= filtered_elems (filter (--> elem (! (in elem prev_elems))) curr_elems))
        (! (any (--> elem (! (isFreePos (.. elem position)))) filtered_elems))
  )))

  (= isFreePosExceptObj (--> (pos obj) (
    if (| (isFreePos pos) (intersectsPosElems pos (renderValue obj))) then true else false
    )
  ))

  (= isFreeRangeExceptObj (--> (start end obj) (
    let (= allCheckedPos (map (--> (x) (Position x 0)) (range start end)))
        (= prev_elems (renderValue obj))
        (= filtered_pos (filter (--> pos (! (intersectsPosElems pos prev_elems))) allCheckedPos))
        (! (any (--> pos (! (isFreePos pos))) filtered_pos))
  )))


  (= moveLeftNoCollision (--> obj (let 
      (if (and (isWithinBounds (moveLeft obj)) (isFreeExcept (moveLeft obj) obj)) then (moveLeft obj) else obj))))
  (= moveRightNoCollision (--> obj (let
      (= wbound (isWithinBounds (moveRight obj)))
      (= fr (isFreeExcept (moveRight obj) obj))
      (= ret (if (& wbound fr) then (moveRight obj) else obj))
      ret
      ))
  )
  (= moveUpNoCollision (--> obj (if (and (isWithinBounds (moveUp obj)) (isFreeExcept (moveUp obj) obj)) then (moveUp obj) else obj)))
  (= moveDownNoCollision (--> obj (if (and (isWithinBounds (moveDown obj)) (isFreeExcept (moveDown obj) obj)) then (moveDown obj) else obj)))

  (= nextSolid moveDownNoCollision)


  
  (= nextLiquidClosestHole (--> (obj holes) 
      (if (== (length holes) 0) then obj else (
              let (= closestHole (closestPos obj holes))
                  (nextLiquidMoveClosestHole obj closestHole)
          )
      ))
  )

  (= nextLiquid (--> (obj) (
    if (and
        (!= (.. (.. obj origin) y) (- GRID_SIZE 1))
        (isFree (moveDown obj))
        ) then (moveDown obj) else (
          let (= nextRowPos (rect (Position 0 (+ (.. (.. obj origin) y) 1)) (Position GRID_SIZE (+ (.. (.. obj origin) y) 2))))
              (= nextRowPos (filter (--> p (!= (.. p y) GRID_SIZE)) nextRowPos))
              (= holes (filter (--> p (and (isFreePos p) (isFreePos (moveUpPos p)))) nextRowPos))
              (nextLiquidClosestHole obj holes)
          )
    )))


  (= nextLiquidMoveClosestHole (--> (obj closestHole) (
     let (= dir (unitVectorObjPos obj (moveUpPos closestHole)))
         (= movedObj (move obj dir))
         (if (and (isFreePos (moveUpPos closestHole))
              (and (isFreePos (.. movedObj origin))
                    (isWithinBounds movedObj))
             ) then movedObj else obj)
     )
  ))

)
`

const state = {
    interpreter: null,
    programContent: "",
    isInteractivePhase: true,
    interactiveTimer: null,
    lastUpdateTime: 0,
    fetchInProgress: false,
    gameLoopInterval: null,
    totalFrames: null,
    currentFrame: 0,
    colorMap: null,
    playbackInterval: null,
    isVideoCompleted: false,
    correctAnswer: null,
    currentProgramId: null,
    availablePrograms: new Map(),
    completedPrograms: new Set(),
    incorrectOptions: null,
    currentProgramIndex: -1,
    programOrder: [],
    isPlayingVideo: false,
    interactionTime: 25 * 1000,
    timerInterval: null,
    timeLeft: 0,
};

let interpreterModule = null;
let actions = [];


// Interactive Phase Functions
async function loadPrograms() {
    // Reset program state
    state.availablePrograms = new Map();
    state.programOrder = [];
    state.currentProgramIndex = -1;
    
    // Static list of program names (matching the filenames without extensions)
    const programNames = ['ants', 'bbq', 'coins', 'disease', 'egg', 'gravity', 'grow', 'ice', 'lights', 'lock', 'magnets', 'paint', 'particles', 'rink', 'sand', 'space_invaders', 'waterplug', 'wind'];
    
    for (const programName of programNames) {
        try {
            // Load the video JSON file to get program metadata
            const response = await fetch(`../mara/static/data/video/${programName}.json`);
            if (!response.ok) continue;
            
            const videoData = await response.json();
            const observations = videoData.questions?.[0]?.observations || [];
            
            state.availablePrograms.set(programName, {
                name: videoData.name || programName,
                total_frames: observations.length,
                grid_size: observations[0]?.grid?.length || 16,
                eval_type: videoData.eval_type || 'timed',
                interaction_time: (videoData.interaction_time || 30) * 1000,
                incorrect_options: videoData.questions?.[0]?.incorrect_options || []
            });
        } catch (error) {
            console.error(`Error loading program ${programName}:`, error);
        }
    }
    
    state.programOrder = Array.from(state.availablePrograms.keys());    
    return state.programOrder;
}


function updateProgramName(programId) {
    const navProgramName = document.querySelector('.nav-program-name');
    const aiPerformanceBtn = document.querySelector('.ai-performance-btn');
    
    // Hide AI Performance button
    if (aiPerformanceBtn) {
        aiPerformanceBtn.classList.add('hidden');
    }

    if (navProgramName) {
        const programInfo = state.availablePrograms.get(programId);
        const displayName = programInfo?.name || programId;
        
        navProgramName.classList.remove('glow');
        
        if (navProgramName.textContent) {
            navProgramName.classList.remove('active');
            setTimeout(() => {
                navProgramName.textContent = displayName;
                navProgramName.classList.add('active', 'glow');
            }, 300);
        } else {
            navProgramName.textContent = displayName;
            navProgramName.classList.add('active');
        }
    }
}


function setupInteractiveUI() {
    const grid = document.querySelector('.grid');
    grid.classList.add('interactive');
    
    document.querySelector('.action-visualizer').classList.remove('hidden');
    document.querySelector('.interactive-controls').classList.add('visible');
    document.querySelector('.video-controls').classList.remove('visible');
    
    showPhaseIndicator(`Interactive Phase - Arrow keys and click`);
    setupSkipButton();
}


function startGameLoop() {
    if (state.gameLoopInterval) {
        cancelAnimationFrame(state.gameLoopInterval);
    }
    state.lastUpdateTime = Date.now();
    state.fetchInProgress = false;
    
    function animate() {
        processGameLoop();
        state.gameLoopInterval = requestAnimationFrame(animate);
    }
    animate();
}


function processGameLoop() {
    if (!state.isInteractivePhase) return;
    
    const currentTime = Date.now();
    
    // Only process if enough time has passed and we're not already processing
    if (!state.fetchInProgress && currentTime - state.lastUpdateTime >= UPDATE_INTERVAL) {
        requestAnimationFrame(() => sendActions(currentTime));
    }
}


function applyVisualUpdate(action) {
    const grid = document.querySelector('.grid');
    
    if (action.click) {
        const [x, y] = action.click;
        const cellIndex = y * state.gridSize + x;
        const cellElement = grid.children[cellIndex];
        
        if (cellElement) {
            // Remove any existing animation class
            cellElement.classList.remove('clicked');
            // Force a reflow to ensure the animation triggers again
            void cellElement.offsetWidth;
            // Add visual feedback with longer duration
            cellElement.classList.add('clicked');
            showActionIcon('click');
            
            // Clear the animation after it completes
            setTimeout(() => {
                cellElement.classList.remove('clicked');
                showActionIcon('none');
            }, CLICK_ANIMATION_DURATION);
        }
    } else if (action.left || action.right || action.up || action.down) {
        const actionType = Object.keys(action)[0];
        showActionIcon(actionType);
        
        setTimeout(() => {
            showActionIcon('none');
        }, CLICK_ANIMATION_DURATION);
    }
}


async function sendActions(currentTime) {
    if (state.fetchInProgress) {
        // Instead of returning, queue the action for next frame
        requestAnimationFrame(() => sendActions(currentTime));
        return;
    }
    
    state.fetchInProgress = true;
    
    const currentActions = [...actions];
    actions = []; // Clear the queue immediately
    
    try {
        // Process all queued actions in order
        for (const action of currentActions) {
            if (action.click) {
                const [x, y] = action.click;
                state.interpreter.click(x, y);
                // Apply visual feedback immediately and wait for animation
                await new Promise(resolve => {
                    applyVisualUpdate(action);
                    setTimeout(resolve, 50); // Small delay between clicks
                });
            } else if (action.left) {
                state.interpreter.left();
                applyVisualUpdate(action);
            } else if (action.right) {
                state.interpreter.right();
                applyVisualUpdate(action);
            } else if (action.up) {
                state.interpreter.up();
                applyVisualUpdate(action);
            } else if (action.down) {
                state.interpreter.down();
                applyVisualUpdate(action);
            }
        }

        // Step the interpreter
        state.interpreter.step();
        
        // Render the new state
        const renderResult = parseRenderResult(state.interpreter.renderAll());
        renderGameState(renderResult);
        
    } catch (error) {
        console.error('Error processing actions:', error);
    } finally {
        state.lastUpdateTime = currentTime;
        state.fetchInProgress = false;
        
        // If there are pending actions, process them in the next frame
        if (actions.length > 0) {
            requestAnimationFrame(() => sendActions(Date.now()));
        }
    }
}


function parseRenderResult(renderResult) {
    // renderResult is a String, first parse to json
    renderResult = JSON.parse(renderResult);
    // get keys of the Object
    const keys = Object.keys(renderResult);
    var sceneData = [];
    for (let i = 0; i < keys.length; i++) {
        // get the key
        const key = keys[i];
        if (key === "GRID_SIZE") {
            state.gridSize = renderResult[key];
        } else {
            const elem = renderResult[key];
            for (let j = 0; j < elem.length; j++) {
                var value = elem[j];
                // add opacity if not present
                if (!value.opacity) {
                    value.opacity = 1;
                }
                sceneData.push(value);
            }
        }
    }
    return sceneData;
}


function setupInteractiveControls() {
    document.addEventListener('keydown', handleKeyPress);
    const grid = document.querySelector('.grid');
    if (grid) {
        grid.addEventListener('pointerdown', handleGridClick);
    }

    const timer = document.querySelector('.timer');
    
    // Get program info to check eval_type
    const programInfo = state.availablePrograms.get(state.currentProgramId);
    const isUntimed = programInfo && programInfo.eval_type === 'untimed';
    
    // Only show timer for timed programs
    if (timer) {
        timer.style.display = isUntimed ? 'none' : 'block';
    }

    // Ensure interactive phase is set
    state.isInteractivePhase = true;
}

function handleKeyPress(event) {
    if (!state.isInteractivePhase) return;

    const keyActions = {
        'ArrowLeft': { left: true },
        'ArrowRight': { right: true },
        'ArrowUp': { up: true },
        'ArrowDown': { down: true }
    };

    const action = keyActions[event.key];
    if (action) {
        event.preventDefault();
        
        // Add to actions queue for server processing
        actions.push(action);
        
        // Apply visual update immediately
        applyVisualUpdate(action);
    }
}


function handleGridClick(event) {
    if (!state.isInteractivePhase) return;

    const grid = event.currentTarget;
    const rect = grid.getBoundingClientRect();
    
    // Get the CSS variables for cell size and spacing
    const cellSize = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--cell-size'));
    const cellSpacing = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--cell-spacing'));
    const totalCellSize = cellSize + (2 * cellSpacing);
    
    // Calculate the total expected grid content size
    const expectedContentSize = totalCellSize * state.gridSize;
    
    // Get the actual rendered size and calculate the scale factor
    const gridStyle = window.getComputedStyle(grid);
    const padding = parseFloat(gridStyle.padding);
    const actualContentWidth = rect.width - (2 * padding);
    const scaleFactor = actualContentWidth / expectedContentSize;
    
    // Get click position relative to grid content area and adjust for scale
    const clickX = (event.clientX - (rect.left + padding)) / scaleFactor;
    const clickY = (event.clientY - (rect.top + padding)) / scaleFactor;
    
    // Calculate grid coordinates
    const x = Math.floor(clickX / totalCellSize);
    const y = Math.floor(clickY / totalCellSize);

    if (x >= 0 && x < state.gridSize && y >= 0 && y < state.gridSize) {
        const action = { click: [x, y] };
        actions.push(action);
        applyVisualUpdate(action);
    }
}


function cleanupInteractivePhase() {
    if (state.gameLoopInterval) {
        cancelAnimationFrame(state.gameLoopInterval);
        state.gameLoopInterval = null;
    }
    if (state.timerInterval) {
        clearInterval(state.timerInterval);
        state.timerInterval = null;
    }
    if (state.interactiveTimer) {
        clearTimeout(state.interactiveTimer);
        state.interactiveTimer = null;
    }
    state.fetchInProgress = false;
    actions = [];
    
    document.removeEventListener('keydown', handleKeyPress);
    const grid = document.querySelector('.grid');
    if (grid) {
        grid.removeEventListener('pointerdown', handleGridClick);
    }
    
    const interactiveControls = document.querySelector('.interactive-controls');
    if (interactiveControls) {
        interactiveControls.classList.remove('visible');
    }
}


function setupVideoUI() {
    document.querySelector('.grid').classList.remove('interactive');
    document.querySelector('.action-visualizer').classList.remove('hidden');
    document.querySelector('.interactive-controls').classList.remove('visible');
    
    const videoControls = document.querySelector('.video-controls');
    
    videoControls.innerHTML = '';
    
    const playPauseButton = document.createElement('button');
    playPauseButton.className = 'play-pause-button';
    playPauseButton.disabled = true;
    playPauseButton.innerHTML = '<i class="fas fa-pause"></i>';
    
    // Add pointer-events: none to the icon to ensure clicks go through to the button
    const icon = playPauseButton.querySelector('i');
    if (icon) {
        icon.style.pointerEvents = 'none';
    }
    
    const slider = document.createElement('input');
    slider.type = 'range';
    slider.className = 'video-slider';
    slider.min = 0;
    slider.value = 0;
    slider.disabled = true;
    
    videoControls.appendChild(playPauseButton);
    videoControls.appendChild(slider);
    videoControls.classList.add('visible');
    
    // Add click handler to button
    playPauseButton.addEventListener('click', (e) => {
        e.preventDefault(); // Prevent any default button behavior
        togglePlayPause();
    });
    
    slider.addEventListener('input', handleSliderInput);
    
    showPhaseIndicator('Video Phase - First Playthrough');
    updatePlayPauseButton();
}


function handleSliderInput(e) {
    if (!state.isVideoCompleted) return;
    
    const frameIndex = parseInt(e.target.value);
    state.currentFrame = frameIndex;
    pauseVideo();
    fetchFrame(frameIndex);
    updatePlayPauseButton();
}


function updatePlayPauseButton() {
    const button = document.querySelector('.play-pause-button');
    if (!button) return;

    const icon = button.querySelector('i');
    if (!icon) return;

    if (state.isVideoCompleted) {
        if (state.currentFrame === state.totalFrames - 1) {
            icon.className = 'fas fa-backward-step';
        } else if (state.isPlayingVideo) {
            icon.className = 'fas fa-pause';
        } else {
            icon.className = 'fas fa-play';
        }
    } else {
        icon.className = 'fas fa-pause';
    }
}


function togglePlayPause() {
    if (!state.isVideoCompleted && state.isPlayingVideo) {
        return; // Only prevent pausing during first playthrough
    }

    if (state.isVideoCompleted && state.currentFrame === state.totalFrames - 1) {
        // If at the end, start from beginning
        state.currentFrame = 0;
        resumeVideo();
    } else if (state.isPlayingVideo) {
        pauseVideo();
    } else {
        resumeVideo();
    }
}


function pauseVideo() {
    if (state.playbackInterval) {
        clearInterval(state.playbackInterval);
    }
    state.isPlayingVideo = false;
    updatePlayPauseButton();
}


function resumeVideo() {
    if (!state.isPlayingVideo) {
        state.isPlayingVideo = true;
        updatePlayPauseButton();
        startVideoPlayback(state.currentFrame);
    }
}


function startVideoPlayback(startFrame = 0) {
    if (state.playbackInterval) {
        clearInterval(state.playbackInterval);
    }

    if (!state.totalFrames) {
        console.error('Total frames not set');
        return;
    }

    state.isPlayingVideo = true;
    state.currentFrame = startFrame;
    fetchFrame(startFrame);
    updatePlayPauseButton();

    document.querySelector('.video-controls').classList.add('visible');

    // Update slider max value
    const slider = document.querySelector('.video-slider');
    if (slider) {
        slider.max = state.totalFrames - 1;
    }

    state.playbackInterval = setInterval(() => {
        if (state.currentFrame < state.totalFrames - 1 && state.isPlayingVideo) {
            state.currentFrame++;
            fetchFrame(state.currentFrame);
            
            if (slider) slider.value = state.currentFrame;
        } else if (state.currentFrame >= state.totalFrames - 1) {
            clearInterval(state.playbackInterval);
            state.isPlayingVideo = false;
            state.isVideoCompleted = true;
            
            if (slider) {
                slider.disabled = false;
                slider.classList.add('enabled');
            }
            
            updatePlayPauseButton();  // Show rewind icon when reaching the end
        }
    }, FRAME_RATE);
}


async function startVideoPhase() {
    if (!state.currentProgramId || state.isVideoCompleted) {
        console.warn('Invalid state for video phase');
        return;
    }
    
    state.isInteractivePhase = false;
    cleanupInteractivePhase();
    setupVideoUI();
    
    try {
        if (!state.currentProgramId) {
            console.error('No current program ID');
            return;
        }
        
        const programInfo = state.availablePrograms.get(state.currentProgramId);
        if (programInfo) {
            // Set total frames from program info
            state.totalFrames = programInfo.total_frames;
            if (programInfo.colors) {
                state.colorMap = programInfo.colors;
            }
            if (programInfo.incorrect_options) {
                state.incorrectOptions = programInfo.incorrect_options;
            }
        }
        
        state.currentFrame = 0;
        state.isVideoCompleted = false;
        
        // Update video slider with correct total frames
        const slider = document.querySelector('.video-slider');
        if (slider) {
            slider.max = state.totalFrames - 1;
            slider.value = 0;
        }
        
        startVideoPlayback();
    } catch (error) {
        console.error('Error starting video phase:', error);
    }
}


async function fetchFrame(idx) {
    if (!state.currentProgramId) return;
    
    try {
        const response = await fetch(`/mara/static/data/video/${state.currentProgramId}.json`);
        if (!response.ok) throw new Error('Failed to load video data');
        
        const videoData = await response.json();
        const frame = videoData.questions[0].observations[idx];
        
        if (frame) {
            state.currentFrame = idx;
            updateFrame({
                colors: videoData.colors,
                observations: [frame]
            });
        }
    } catch (error) {
        console.error('Error fetching frame:', error);
    }
}


function renderGameState(sceneData) {
    const gridElement = document.querySelector('.grid');
    const GRID_SIZE = state.gridSize || 16; // fallback if not defined
    
    // Clear existing state first
    renderGrid(gridElement, GRID_SIZE);
    
    // Reset all cells to default state
    const cells = gridElement.querySelectorAll('.cell');
    cells.forEach(cell => {
        cell.classList.remove('active');
        cell.style.backgroundColor = '';
        cell.style.opacity = '1';
    });

    sceneData.forEach(obj => {
        const x = obj.position.x;
        const y = obj.position.y;
        
        if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
            const cellIndex = y * GRID_SIZE + x;
            const cellElement = gridElement.children[cellIndex];
            
            if (cellElement) {
                cellElement.classList.add('active');
                cellElement.style.backgroundColor = obj.color;
                if (obj.opacity !== undefined && obj.opacity !== 1) {
                    cellElement.style.opacity = obj.opacity;
                }
            }
        }
    });
}


function renderGrid(gridElement, size) {
    // Clear existing grid content
    gridElement.innerHTML = '';
    
    // Reset any existing background color
    gridElement.style.backgroundColor = '';
    
    // Set CSS Grid properties for the container
    gridElement.style.display = 'grid';
    gridElement.style.gridTemplateColumns = `repeat(${size}, 1fr)`;
    gridElement.style.gridTemplateRows = `repeat(${size}, 1fr)`;
    gridElement.style.gap = 'var(--cell-spacing)';
    
    // Iterate over rows and columns to create cells
    for (let row = 0; row < size; row++) {
        for (let col = 0; col < size; col++) {
            const cell = document.createElement('div');
            cell.className = 'cell';
            // Reset cell background color and opacity
            cell.style.backgroundColor = '';
            cell.style.opacity = '1';
            cell.dataset.row = row;
            cell.dataset.col = col;
            gridElement.appendChild(cell);
        }
    }
}


function showPhaseIndicator(text) {
    const indicator = document.querySelector('.phase-indicator');
    if (indicator) {
        indicator.textContent = text;
    }
}


// Timer Functions
function startTimer() {
    const programInfo = state.availablePrograms.get(state.currentProgramId);
    const isUntimed = programInfo && programInfo.eval_type === 'untimed';
    
    // Don't start timer for untimed programs
    if (isUntimed) {
        return;
    }

    if (state.timerInterval) {
        clearInterval(state.timerInterval);
    }
    
    const timerElement = document.querySelector('.time-value');
    if (!timerElement) return;
    
    state.timeLeft = Math.round(state.interactionTime / 1000);
    timerElement.textContent = state.timeLeft;
    
    state.timerInterval = setInterval(() => {
        state.timeLeft--;
        if (timerElement) {
            timerElement.textContent = state.timeLeft;
        }
        if (state.timeLeft <= 0) {
            clearInterval(state.timerInterval);
            // Transition to video phase when timer expires
            state.isInteractivePhase = false;
            cleanupInteractivePhase();
            startVideoPhase();
        }
    }, 1000);
}


function updateTimer() {
    const timerElement = document.querySelector('.time-value');
    if (timerElement) {
        timerElement.textContent = state.timeLeft;
    }
}


function setupSkipButton() {
    const skipButton = document.querySelector('.skip-button');
    if (skipButton) {
        skipButton.addEventListener('click', () => {
            if (state.isInteractivePhase) {
                state.isInteractivePhase = false;
                cleanupInteractivePhase();
                startVideoPhase();
            }
        });
    }
}


function extractMaskedArea(grid, mask) {
    let minRow = Infinity, maxRow = -1, minCol = Infinity, maxCol = -1;
    
    for (let i = 0; i < mask.length; i++) {
        for (let j = 0; j < mask[i].length; j++) {
            if (mask[i][j] === 0) {
                minRow = Math.min(minRow, i);
                maxRow = Math.max(maxRow, i);
                minCol = Math.min(minCol, j);
                maxCol = Math.max(maxCol, j);
            }
        }
    }
    
    if (minRow === Infinity || minCol === Infinity) return null;
    
    const extractedGrid = [];
    for (let i = minRow; i <= maxRow; i++) {
        const row = [];
        for (let j = minCol; j <= maxCol; j++) {
            row.push(grid[i][j]);
        }
        extractedGrid.push(row);
    }
    
    return extractedGrid;
}


function updateFrame(frameData) {
    if (!frameData || !frameData.observations || !frameData.observations.length) return;
    
    const observation = frameData.observations[frameData.observations.length - 1];
    const { grid, action, idx, mask } = observation;
    
    // Update video controls
    const slider = document.querySelector('.video-slider');
    const playPauseButton = document.querySelector('.play-pause-button');
    
    if (slider) {
        slider.value = state.currentFrame;
        
        // Update controls based on video state
        if (state.isVideoCompleted) {
            slider.disabled = false;
            slider.classList.add('enabled');
            if (playPauseButton) {
                playPauseButton.disabled = false;
                playPauseButton.style.opacity = '1';
            }
        } else {
            slider.disabled = true;
            slider.classList.remove('enabled');
            if (playPauseButton) {
                playPauseButton.disabled = true;
            }
        }
    }
    
    // Check for video completion
    if (state.currentFrame === state.totalFrames - 1) {
        if (!state.isVideoCompleted) {
            // Stop playback
            clearInterval(state.playbackInterval);
            state.isPlayingVideo = false;
            state.isVideoCompleted = true;
            
            // Enable controls
            if (slider) {
                slider.disabled = false;
                slider.classList.add('enabled');
            }
            if (playPauseButton) {
                playPauseButton.disabled = false;
                playPauseButton.style.opacity = '1';
            }
            
            // Set up choices if appropriate
            const maskedArea = extractMaskedArea(grid, mask);
            if (maskedArea) {
                const choices = generateChoices(maskedArea);
                if (choices && choices.options && choices.options.length > 0) {
                    setupChoices(choices);
                    const evaluationContainer = document.querySelector('.evaluation-container');
                    if (evaluationContainer) {
                        evaluationContainer.classList.add('visible');
                    }
                }
            }
            
            showPhaseIndicator('Video Phase - Interactive Playback Available');
        }
        // Update button to show rewind icon when at end
        if (playPauseButton) {
            playPauseButton.innerHTML = '<i class="fas fa-backward-step"></i>';
        }
    } else if (state.isVideoCompleted) {
        // Update button based on play state when not at end
        if (playPauseButton) {
            playPauseButton.innerHTML = state.isPlayingVideo ? 
                '<i class="fas fa-pause"></i>' : 
                '<i class="fas fa-play"></i>';
        }
    }
    
    renderVideoFrame(grid, action, idx, mask);
    showActionIcon(action);
}


function showActionIcon(action) {
    action = action?.toLowerCase() || 'none';
    
    const icons = ['clickIcon', 'rightIcon', 'leftIcon', 'upIcon', 'downIcon', 'noneIcon'];
    icons.forEach(id => {
        const icon = document.getElementById(id);
        if (icon) {
            if (id === `${action}Icon`) {
                icon.style.display = 'block';
                icon.classList.add('active');
            } else {
                icon.style.display = 'none';
                icon.classList.remove('active');
            }
        }
    });
}


function generateChoices(correctGrid) {
    if (!correctGrid || !correctGrid.length || !correctGrid[0].length) {
        console.error('Invalid grid provided to generateChoices');
        return null;
    }

    const choices = {
        options: [],
        correct: Math.floor(Math.random() * 4),
        dimensions: {
            rows: correctGrid.length,
            cols: correctGrid[0].length
        }
    };
    
    for (let i = 0; i < 4; i++) {
        if (i === choices.correct) {
            choices.options.push({
                grid: correctGrid
            });
        } else {
            const incorrectIndex = i > choices.correct ? i - 1 : i;
            if (state.incorrectOptions && incorrectIndex < state.incorrectOptions.length) {
                choices.options.push({
                    grid: state.incorrectOptions[incorrectIndex]
                });
            } else {
                console.error("Missing incorrect option for index:", incorrectIndex);
                choices.options.push({
                    grid: generateRandomGrid(correctGrid)
                });
            }
        }
    }
    
    return choices;
}


function generateRandomGrid(originalGrid) {
    if (!originalGrid || !originalGrid.length || !originalGrid[0].length) {
        console.error('Invalid grid provided to generateRandomGrid');
        return null;
    }

    const newGrid = JSON.parse(JSON.stringify(originalGrid));
    
    const possibleValues = new Set();
    originalGrid.forEach(row => {
        row.forEach(cell => {
            if (cell !== 0) possibleValues.add(cell);
        });
    });
    const values = Array.from(possibleValues);
    
    if (values.length === 0) return newGrid;
    
    const numChanges = 2 + Math.floor(Math.random() * 3);
    for (let i = 0; i < numChanges; i++) {
        const row = Math.floor(Math.random() * newGrid.length);
        const col = Math.floor(Math.random() * newGrid[0].length);
        
        if (newGrid[row][col] !== 0) {
            const availableValues = values.filter(v => v !== newGrid[row][col]);
            if (availableValues.length > 0) {
                newGrid[row][col] = availableValues[Math.floor(Math.random() * availableValues.length)];
            }
        }
    }
    
    return newGrid;
}


function renderVideoFrame(grid, action, idx, mask) {
    const gridElement = document.querySelector('.grid');
    const GRID_SIZE = grid.length;
    
    // Use common render function
    renderGrid(gridElement, GRID_SIZE);

    grid.forEach((row, i) => {
        row.forEach((cell, j) => {
            const cellIndex = i * GRID_SIZE + j;
            const cellElement = gridElement.children[cellIndex];
            
            if (cellElement) {
                const isMasked = mask[i][j] === 0;
                if (isMasked) {
                    cellElement.classList.add('masked');
                } else if (cell !== 0) {
                    cellElement.classList.add('active');
                    const cellColor = getColorForValue(cell);
                    if (cellColor) {
                        cellElement.style.backgroundColor = cellColor;
                    }
                }
                
                if (action?.toLowerCase() === 'click' && idx !== 'None') {
                    const [clickedX, clickedY] = [parseInt(idx[0]), parseInt(idx[1])];
                    if (i === clickedX && j === clickedY) {
                        cellElement.classList.add('clicked');
                    }
                }
            }
        });
    });
}


function setupChoices(choices) {
    const choicesGrid = document.querySelector('.choices-grid');
    choicesGrid.innerHTML = '';
    state.correctAnswer = choices.correct;
    
    choices.options.forEach((option, index) => {
        const choiceDiv = document.createElement('div');
        choiceDiv.className = 'choice-option';
        choiceDiv.dataset.index = index;
        
        const miniGrid = document.createElement('div');
        miniGrid.className = 'mini-grid';
        miniGrid.style.gridTemplateColumns = `repeat(${choices.dimensions.cols}, 1fr)`;
        
        const cellSize = Math.min(
            Math.floor((120 - 8) / choices.dimensions.cols),
            Math.floor((120 - 8) / choices.dimensions.rows)
        );
        
        option.grid.forEach(row => {
            row.forEach(cell => {
                const miniCell = document.createElement('div');
                miniCell.className = 'mini-cell';
                miniCell.style.width = `${cellSize}px`;
                miniCell.style.height = `${cellSize}px`;
                
                if (cell !== 0) {
                    miniCell.classList.add('active');
                    const cellColor = getColorForValue(cell);
                    if (cellColor) {
                        miniCell.style.background = cellColor;
                        miniCell.style.borderColor = cellColor;
                    }
                }
                miniGrid.appendChild(miniCell);
            });
        });
        
        choiceDiv.appendChild(miniGrid);
        choiceDiv.addEventListener('click', () => handleChoiceSelection(index));
        choicesGrid.appendChild(choiceDiv);
    });
}


function handleChoiceSelection(index) {
    const choices = document.querySelectorAll('.choice-option');
    
    choices.forEach(choice => {
        choice.classList.remove('selected', 'correct', 'incorrect');
    });
    
    choices[index].classList.add('selected');
    
    if (index === state.correctAnswer) {
        choices[index].classList.add('correct');
        setTimeout(() => completeCurrentProgram(), 1000);
    } else {
        choices[index].classList.add('incorrect');
        choices[state.correctAnswer].classList.add('correct');
        setTimeout(() => completeCurrentProgram(), 1000);
    }
}


function completeCurrentProgram() {
    if (state.currentProgramId) {
        state.completedPrograms.add(state.currentProgramId);
        
        const welcomeSection = document.querySelector('.welcome-section');
        const gridContainer = document.querySelector('.grid-container');
        const evaluationContainer = document.querySelector('.evaluation-container');
        
        // Clean up current state
        if (state.playbackInterval) clearInterval(state.playbackInterval);
        if (state.interactiveTimer) clearTimeout(state.interactiveTimer);
        if (state.gameLoopInterval) clearInterval(state.gameLoopInterval);
        if (state.timerInterval) clearInterval(state.timerInterval);
        
        // Reset grid state
        const gridElement = document.querySelector('.grid');
        if (gridElement) {
            gridElement.innerHTML = '';
            gridElement.classList.remove('interactive');
        }
        
        // Clean up video controls
        const videoControls = document.querySelector('.video-controls');
        if (videoControls) {
            videoControls.classList.remove('visible');
            const playPauseButton = videoControls.querySelector('.play-pause-button');
            const slider = videoControls.querySelector('.video-slider');
            
            // Remove event listeners
            if (playPauseButton) {
                playPauseButton.replaceWith(playPauseButton.cloneNode(true));
            }
            if (slider) {
                slider.replaceWith(slider.cloneNode(true));
            }
        }
        
        // Reset state
        state.isVideoPhase = false;
        state.isPlayingVideo = false;
        state.isVideoCompleted = false;
        
        // Continue with existing cleanup...
        if (evaluationContainer) {
            evaluationContainer.classList.remove('visible');
        }
        
        gridContainer.style.opacity = '0';
        gridContainer.style.transition = 'opacity 0.3s ease';
        
        setTimeout(() => {
            gridContainer.classList.remove('active');
            gridContainer.style.display = 'none';
            welcomeSection.style.display = 'flex';
            
            setTimeout(() => {
                welcomeSection.style.opacity = '1';
                setupProgramList();
            }, 50);
        }, 300);
    }
}


function rgbToHex(r, g, b) {
    const toHex = (c) => {
        const hex = Math.round(c * 255).toString(16);
        return hex.length === 1 ? '0' + hex : hex;
    };
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}


function getColorForValue(value) {
    if (!state.colorMap[value]) return null;
    const color = state.colorMap[value];
    return rgbToHex(color.r, color.g, color.b);
}


async function loadSpecificProgram(programId) {
    const aiPerformanceBtn = document.querySelector('.ai-performance-btn');
    
    // Hide AI Performance button
    if (aiPerformanceBtn) {
        aiPerformanceBtn.classList.add('hidden');
    }
    
    const loadingPage = document.querySelector('.loading-page');
    const gridContainer = document.querySelector('.grid-container');
    const welcomeSection = document.querySelector('.welcome-section');

    welcomeSection.style.display = 'none';
    loadingPage.style.display = 'flex';
    loadingPage.classList.add('active');

    const countdownElement = loadingPage.querySelector('.countdown');
    let countdown = 3;
    countdownElement.textContent = countdown;
    
    const countdownInterval = setInterval(() => {
        countdown--;
        countdownElement.textContent = countdown;
        if (countdown <= 0) {
            clearInterval(countdownInterval);
            loadingPage.classList.remove('active');
            setTimeout(() => {
                loadingPage.style.display = 'none';
                
                // Show grid container immediately after loading page is gone
                gridContainer.style.display = 'block';
                gridContainer.classList.add('active');
                // Force a reflow before setting opacity
                void gridContainer.offsetWidth;
                gridContainer.style.opacity = '1';
                
            }, 300);
        }
    }, 1000);

    try {
        // Load the program's SEXP file
        const sexpResponse = await fetch(`../mara/static/data/game/${programId}.sexp`);
        if (!sexpResponse.ok) throw new Error(`Failed to load program ${programId}`);
        const programContent = await sexpResponse.text();

        // Load the video JSON file
        const videoResponse = await fetch(`../mara/static/data/video/${programId}.json`);
        if (!videoResponse.ok) throw new Error(`Failed to load video data for ${programId}`);
        const videoData = await videoResponse.json();

        // Update state with video data
        const programInfo = state.availablePrograms.get(programId);
        if (!programInfo) throw new Error(`Program info not found for ${programId}`);

        state.currentProgramId = programId;
        state.colorMap = videoData.colors || {};
        state.totalFrames = videoData.questions[0].observations.length;
        
        // Continue with program initialization
        const isUntimed = programInfo.eval_type === 'untimed';
        state.interactionTime = isUntimed ? Infinity : (programInfo.interaction_time || 25000);
        state.incorrectOptions = videoData.questions[0].incorrect_options || [];
        
        // Initialize interpreter
        state.programContent = programContent.trim();
        state.interpreter = await new interpreterModule.Interpreter();
        state.interpreter.runScript(programContent, autumnstdlib);
        state.interpreter.step();
        
        // Setup UI and start game loop
        var renderResult = state.interpreter.renderAll();
        renderResult = parseRenderResult(renderResult);
        renderGameState(renderResult);
        setupInteractiveUI();
        setupInteractiveControls();
        startGameLoop();
        startTimer();

        return true;
    } catch (error) {
        console.error('Error loading program:', error);
        throw error;
    }
}


async function setupProgramList() {
    // Create the program picker structure
    const programPickerContainer = document.querySelector('.program-picker');
    if (!programPickerContainer) return;

    // Clear existing content
    programPickerContainer.innerHTML = '';

    // Create button
    const pickButton = document.createElement('button');
    pickButton.className = 'pick-program-button';
    pickButton.innerHTML = `
        <span>Pick a Program</span>
        <i class="fas fa-chevron-down"></i>
    `;

    // Create program list
    const programList = document.createElement('div');
    programList.className = 'program-list';

    // Create backdrop for clicking outside
    const backdrop = document.createElement('div');
    backdrop.className = 'program-picker-backdrop';

    // Get available programs
    const availablePrograms = Array.from(state.availablePrograms.entries());

    // Populate program list
    availablePrograms.forEach(([id, info]) => {
        const programItem = document.createElement('div');
        programItem.className = `program-item${state.completedPrograms.has(id) ? ' completed' : ''}`;
        programItem.textContent = info.name || id;
        
        programItem.addEventListener('click', () => {
            toggleProgramList(false);
            loadSpecificProgram(id);
        });
        
        programList.appendChild(programItem);
    });

    // Add click handler for the pick button
    pickButton.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleProgramList();
    });

    // Add click handler for the backdrop
    backdrop.addEventListener('click', () => {
        toggleProgramList(false);
    });

    // Add components to the container
    programPickerContainer.appendChild(pickButton);
    programPickerContainer.appendChild(programList);
    document.body.appendChild(backdrop);

    function toggleProgramList(force) {
        const isActive = force !== undefined ? force : !programList.classList.contains('active');
        programList.classList.toggle('active', isActive);
        backdrop.classList.toggle('active', isActive);
        pickButton.classList.toggle('active', isActive);
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
        if (!programPickerContainer.contains(e.target)) {
            toggleProgramList(false);
        }
    });
}

function setupLogoClick() {
    const logoLink = document.querySelector('.logo-link');
    if (logoLink) {
        logoLink.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Clean up current state
            if (state.playbackInterval) clearInterval(state.playbackInterval);
            if (state.interactiveTimer) clearTimeout(state.interactiveTimer);
            if (state.gameLoopInterval) clearInterval(state.gameLoopInterval);
            if (state.timerInterval) clearInterval(state.timerInterval);
            
            // Hide grid and evaluation containers
            const gridContainer = document.querySelector('.grid-container');
            const evaluationContainer = document.querySelector('.evaluation-container');
            const welcomeSection = document.querySelector('.welcome-section');
            
            if (gridContainer) {
                gridContainer.style.opacity = '0';
                gridContainer.style.transition = 'opacity 0.3s ease';
                
                setTimeout(() => {
                    gridContainer.style.display = 'none';
                    gridContainer.classList.remove('active');
                    
                    // Show welcome section with fade in
                    welcomeSection.style.display = 'flex';
                    welcomeSection.style.opacity = '0';
                    
                    setTimeout(() => {
                        welcomeSection.style.opacity = '1';
                        welcomeSection.style.transition = 'opacity 0.3s ease';
                    }, 50);
                }, 300);
            }

            if (evaluationContainer) {
                evaluationContainer.classList.remove('visible');
            }
            
            // Show AI Performance button
            const aiPerformanceBtn = document.querySelector('.ai-performance-btn');
            if (aiPerformanceBtn) {
                aiPerformanceBtn.classList.remove('hidden');
            }

            // Reset program state
            state.currentProgramId = null;
            state.isInteractivePhase = true;
            state.isVideoCompleted = false;
            state.isPlayingVideo = false;
            
            // Clear the program name from nav
            const navProgramName = document.querySelector('.nav-program-name');
            if (navProgramName) {
                navProgramName.classList.remove('active');
                setTimeout(() => {
                    navProgramName.textContent = '';
                    navProgramName.classList.remove('glow');
                }, 300);
            }
        });
    }
}


document.addEventListener('DOMContentLoaded', async () => {
    const welcomeSection = document.querySelector('.welcome-section');
    const gridContainer = document.querySelector('.grid-container');
    interpreterModule = await createInterpreterModule();
    state.interpreter = await new interpreterModule.Interpreter();

    // Load programs first
    await loadPrograms();
    // Setup program list
    await setupProgramList();
    setupLogoClick();
});
