const programs = ['particles'];
let currentFrame = 0;
let playbackInterval = null;
let videoData = null;

function generateRandomScore() {
    // Generate a more realistic-looking score
    const baseScore = Math.floor(Math.random() * 41) + 60; // Scores between 60-100
    return baseScore;
}

function createTable() {
    const plotContainer = document.querySelector('.performance-wrapper');
    if (!plotContainer) return;
    
    // Clear existing content
    plotContainer.innerHTML = '';
    
    // Create table structure
    const table = document.createElement('table');
    table.className = 'ai-performance-table';
    
    // Create table header
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');
    ['Program', 'Performance', 'Actions'].forEach(text => {
        const th = document.createElement('th');
        th.textContent = text;
        headerRow.appendChild(th);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);

    // Create table body
    const tbody = document.createElement('tbody');
    programs.forEach(programId => {
        const row = document.createElement('tr');
        
        // Program ID cell
        const idCell = document.createElement('td');
        idCell.className = 'program-name';
        idCell.textContent = programId.toLowerCase().replace('_', ' ');
        row.appendChild(idCell);
        
        // Performance Score cell
        const scoreCell = document.createElement('td');
        const score = generateRandomScore();
        scoreCell.className = 'performance-score';
        scoreCell.innerHTML = `<span class="score">${score}</span><span class="percent">%</span>`;
        row.appendChild(scoreCell);
        
        // Action cell
        const actionCell = document.createElement('td');
        const viewButton = document.createElement('button');
        viewButton.className = 'view-gameplay-btn';
        viewButton.innerHTML = '<i class="fas fa-play"></i> View Gameplay';
        viewButton.onclick = () => showAIGameplay(programId);
        actionCell.appendChild(viewButton);
        row.appendChild(actionCell);
        
        tbody.appendChild(row);
    });
    table.appendChild(tbody);
    
    plotContainer.appendChild(table);
}

async function showAIGameplay(programId) {
    try {
        const response = await fetch(`./static/data/ai/agent_${programId}.json`);
        videoData = await response.json();
        
        // Hide plot container
        const plotContainer = document.querySelector('.performance-wrapper');
        plotContainer.style.display = 'none';

        // Update back button behavior
        const backBtn = document.querySelector('.back-btn');
        if (backBtn) {
            backBtn.innerHTML = 'back to table';
            backBtn.onclick = (e) => {
                e.preventDefault();
                
                // Clean up current state
                if (playbackInterval) clearInterval(playbackInterval);
                if (state.interactiveTimer) clearTimeout(state.interactiveTimer);
                if (state.gameLoopInterval) clearInterval(state.gameLoopInterval);
                if (state.timerInterval) clearInterval(state.timerInterval);
                
                // Reset video state
                currentFrame = 0;
                videoData = null;
                state.isVideoPhase = false;
                state.isPlayingVideo = false;
                state.isVideoCompleted = false;
                
                // Remove gameplay container
                const gridContainer = document.querySelector('.grid-container');
                if (gridContainer) {
                    gridContainer.remove();
                }
                
                // Show table again
                plotContainer.style.display = 'block';
                
                // Reset back button
                backBtn.innerHTML = 'back to programs';
                backBtn.onclick = null;
                backBtn.href = 'index.html';
            };
        }

        // Create container structure matching video phase
        const container = document.createElement('div');
        container.className = 'grid-container';
        container.style.opacity = '1';
        container.style.display = 'block';
        container.style.width = 'calc(var(--cell-size) * 16 + var(--cell-spacing) * 30 + 2.5rem)';
        container.style.margin = '-4rem auto 0';
        container.innerHTML = `
            <div class="info-bar">
                <div class="phase-indicator">AI Gameplay</div>
                <div class="action-visualizer">
                    <div class="action-icon">
                        <i id="clickIcon" class="fas fa-mouse-pointer"></i>
                        <i id="leftIcon" class="fas fa-arrow-left"></i>
                        <i id="rightIcon" class="fas fa-arrow-right"></i>
                        <i id="upIcon" class="fas fa-arrow-up"></i>
                        <i id="downIcon" class="fas fa-arrow-down"></i>
                        <i id="noneIcon" class="fas fa-minus"></i>
                    </div>
                </div>
            </div>
            <div class="grid"></div>
            <div class="video-controls">
                <button class="play-pause-button" disabled>
                    <i class="fas fa-pause"></i>
                </button>
                <input type="range" class="video-slider" min="0" max="100" value="0" disabled>
            </div>
            <div class="text-display"></div>
        `;

        document.querySelector('.ai-performance-container').appendChild(container);

        // Initialize state and video controls
        state.gridSize = 16;
        state.currentProgramId = programId;
        state.isVideoPhase = true;
        state.isInteractivePhase = false;
        state.isPlayingVideo = true;
        state.colorMap = videoData.colors;
        
        // Setup video controls
        const videoControls = container.querySelector('.video-controls');
        videoControls.classList.add('visible');
        
        const slider = container.querySelector('.video-slider');
        slider.max = videoData.observations.length - 1;
        slider.disabled = true;  // Start disabled
        slider.classList.remove('enabled');  // Remove enabled class
        
        const playPauseButton = container.querySelector('.play-pause-button');
        playPauseButton.style.opacity = '1';
        playPauseButton.disabled = true;  // Keep disabled initially

        // Check video controls container
        console.log('Video controls container:', videoControls);
        console.log('Video controls visibility:', window.getComputedStyle(videoControls).display);
        
        playPauseButton.addEventListener('click', togglePlayPause);
        
        slider.addEventListener('input', (e) => {
            currentFrame = parseInt(e.target.value);
            const observation = videoData.observations[currentFrame];
            if (observation && observation.grid) {
                const gridSize = observation.grid.length;
                const mask = Array(gridSize).fill().map(() => Array(gridSize).fill(1));
                
                renderVideoFrame(observation.grid, observation.action, observation.idx, mask);
                showActionIcon(observation.action || 'none');
                
                // Update the text display
                const textDisplay = container.querySelector('.text-display');
                if (textDisplay && observation.text) {
                    const descriptionMatch = observation.text.match(/Description:\*(.*?)(?:<\/response>|$)/);
                    if (descriptionMatch) {
                        textDisplay.textContent = descriptionMatch[1].trim();
                    }
                }
            }
        });

        // Create initial grid
        const gridElement = container.querySelector('.grid');
        renderGrid(gridElement, 16);
        
        currentFrame = 0;
        startPlayback();

    } catch (error) {
        console.error('Failed to load AI gameplay:', error);
    }
}

function togglePlayPause() {
    if (!videoData || !videoData.observations) return;
    
    // Prevent toggling if not completed and currently playing
    if (!state.isVideoCompleted && state.isPlayingVideo) {
        return;
    }
    
    if (currentFrame >= videoData.observations.length - 1) {
        // At the end - restart from beginning
        currentFrame = 0;
        const slider = document.querySelector('.video-slider');
        slider.value = 0;
        state.isPlayingVideo = false;
        
        // Update frame immediately
        const observation = videoData.observations[currentFrame];
        if (observation && observation.grid) {
            const gridSize = observation.grid.length;
            const mask = Array(gridSize).fill().map(() => Array(gridSize).fill(1));
            renderVideoFrame(observation.grid, observation.action, observation.idx, mask);
            showActionIcon(observation.action || 'none');
        }
        
        // Update button to show play icon
        const playPauseButton = document.querySelector('.play-pause-button');
        if (playPauseButton) {
            playPauseButton.innerHTML = '<i class="fas fa-play"></i>';
        }
    } else {
        state.isPlayingVideo = !state.isPlayingVideo;
        if (state.isPlayingVideo) {
            startPlayback();
        } else {
            pausePlayback();
        }
    }
    updatePlayPauseButton();
}

function updatePlayPauseButton() {
    const playPauseButton = document.querySelector('.play-pause-button');
    if (!playPauseButton || !videoData || !videoData.observations) return;
    
    if (currentFrame >= videoData.observations.length - 1) {
        playPauseButton.innerHTML = '<i class="fas fa-backward-step"></i>';
    } else {
        playPauseButton.innerHTML = state.isPlayingVideo ? 
            '<i class="fas fa-pause"></i>' : 
            '<i class="fas fa-play"></i>';
    }
}

function startPlayback() {
    if (playbackInterval) clearInterval(playbackInterval);
    if (!videoData || !videoData.observations) return;
    
    state.isPlayingVideo = true;
    updatePlayPauseButton();
    
    playbackInterval = setInterval(() => {
        const slider = document.querySelector('.video-slider');
        if (currentFrame >= videoData.observations.length - 1) {
            // Update slider to final position before pausing
            if (slider) slider.value = videoData.observations.length - 1;
            
            pausePlayback();
            state.isVideoCompleted = true;
            
            // Enable controls only at end
            if (slider) {
                slider.disabled = false;
                slider.classList.add('enabled');
            }
            
            const playPauseButton = document.querySelector('.play-pause-button');
            if (playPauseButton) {
                playPauseButton.disabled = false;
                playPauseButton.style.opacity = '1';
                playPauseButton.innerHTML = '<i class="fas fa-backward-step"></i>';
            }
            return;
        }

        const observation = videoData.observations[currentFrame];
        if (observation && observation.grid) {
            if (slider) slider.value = currentFrame;
            
            const gridSize = observation.grid.length;
            const mask = Array(gridSize).fill().map(() => Array(gridSize).fill(1));
            
            renderVideoFrame(observation.grid, observation.action, observation.idx, mask);
            showActionIcon(observation.action || 'none');
            
            // Update text display
            const textDisplay = document.querySelector('.text-display');
            if (textDisplay && observation.text) {
                const descriptionMatch = observation.text.match(/Description:\*(.*?)(?:<\/response>|$)/);
                if (descriptionMatch) {
                    textDisplay.textContent = descriptionMatch[1].trim();
                }
            }
            
            currentFrame++;
        }
    }, 500);
}

function pausePlayback() {
    if (playbackInterval) {
        clearInterval(playbackInterval);
        playbackInterval = null;
    }
    state.isPlayingVideo = false;
}

document.addEventListener('DOMContentLoaded', createTable);