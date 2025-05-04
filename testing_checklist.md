# MEKKA2025 Testing Checklist

## Player Mechanics

### Movement
- [X] Player moves smoothly in all directions (up, down, left, right)
- [X] Player accelerates and decelerates properly
- [X] Player respects map boundaries
- [X] Player can move diagonally
- [X] Running works correctly (when holding run button)
- [X] Movement speed is appropriate for gameplay

### Dash
- [X] Dash activates when dash button is pressed
- [X] Dash moves player in the correct direction
- [X] Dash has the correct speed multiplier
- [X] Dash duration is appropriate
- [X] Dash cooldown works correctly
- [X] Invincibility frames during dash work properly
- [X] Dash can be used to escape enemies

### Shooting
- [X] Projectiles spawn at the correct position (muzzle offset)
- [X] Projectiles travel in the direction of aim
- [X] Projectiles have appropriate speed
- [X] Projectiles deal damage to enemies
- [X] Projectiles apply knockback to enemies
- [X] Projectiles have appropriate lifetime
- [X] Projectiles are destroyed when hitting enemies or walls
- [X] Projectiles respect penetration value

### Aiming
- [X] Player aims in the direction of the mouse
- [X] Player rotation follows aim direction
- [X] Aiming feels responsive and accurate

### Health System
- [X] Player takes damage from enemies
- [X] Health decreases correctly
- [X] Player dies when health reaches zero
- [X] Health UI updates correctly (if implemented)
- [X] Invincibility frames work after taking damage

## Enemy Mechanics

### Movement
- [X] Enemies follow the player when in range
- [X] Enemies move at appropriate speed
- [X] Enemies maintain minimum distance from player
- [X] Enemies stop when too close to player
- [X] Enemies pathfinding works correctly

### Combat
- [X] Enemies attack when in range
- [X] Enemies deal appropriate damage
- [X] Enemies have attack cooldown
- [X] Enemies take damage from projectiles
- [X] Enemies die when health reaches zero
- [X] Enemies apply appropriate knockback resistance

### AI Behavior
- [X] Enemies detect player at appropriate range
- [X] Enemies lose track of player when out of range
- [X] Enemies behave appropriately in groups
- [X] Enemies don't get stuck on obstacles

## Wave System

### Wave Progression
- [ ] Waves start correctly
- [ ] Wave counter increments properly
- [ ] Wave duration is appropriate
- [ ] Waves end when all enemies are defeated
- [ ] Time between waves is appropriate

### Enemy Spawning
- [ ] Enemies spawn at appropriate intervals
- [ ] Enemies spawn around the player (not on top)
- [ ] Maximum enemy count is respected
- [ ] Enemies per wave increases with wave number
- [ ] Spawn positions are randomized

### Difficulty Scaling
- [ ] Enemy health increases with difficulty
- [ ] Enemy damage increases with difficulty
- [ ] Enemy speed increases with difficulty
- [ ] Score value increases with difficulty
- [ ] Difficulty increase rate feels balanced

## Game State Management

### State Transitions
- [ ] Game starts in menu state
- [ ] Game transitions to playing state when started
- [ ] Game pauses correctly
- [ ] Game resumes correctly
- [ ] Game ends when player dies
- [ ] Game over state displays correctly

### Score System
- [ ] Score increases when enemies are defeated
- [ ] Score value is appropriate for difficulty
- [ ] Score persists between waves
- [ ] Score resets when starting a new game

### Statistics
- [ ] Enemies defeated counter works correctly
- [ ] Time played counter works correctly
- [ ] Wave counter works correctly

## Performance

### Frame Rate
- [X] Game maintains stable frame rate with few enemies
- [ ] Game maintains acceptable frame rate with many enemies
- [ ] No significant drops during intense moments

### Memory Usage
- [ ] Memory usage remains stable during extended gameplay
- [ ] No memory leaks when enemies/projectiles are destroyed

### Optimization
- [ ] Projectiles are properly cleaned up
- [ ] Dead enemies are properly removed
- [ ] No unnecessary calculations when off-screen

## XP System (Planned)

- [ ] XP drops spawn from defeated enemies
- [ ] XP drops have appropriate appearance/behavior
- [ ] XP collection mechanic works (e.g., pickup range, magnet effect)
- [ ] Player XP is tracked correctly in game state

## Leveling & Upgrades (Planned)

- [ ] Player levels up at correct XP thresholds
- [ ] Level-up event/signal triggers correctly
- [ ] Upgrade selection UI appears on level up
- [ ] Appropriate number of upgrade choices are presented
- [ ] Selected upgrades apply correctly (e.g., stat modifications)
- [ ] Upgrade effects are noticeable and balanced

## Extraction Mechanic (Planned)

- [ ] Main game timer tracks time correctly
- [ ] Extraction zone spawns at the correct time
- [ ] Extraction zone has appropriate appearance/location
- [ ] Extraction zone despawns after its duration
- [ ] Player entering the zone triggers extraction
- [ ] Extraction success state functions correctly
- [ ] Consequences for missing extraction work (if any)

## Bugs and Issues

### Known Issues
- List any bugs or issues discovered during testing
- Include steps to reproduce
- Note severity (critical, major, minor)

### Improvement Suggestions
- List gameplay improvements
- List visual/audio feedback suggestions
- List performance optimization ideas

## Testing Environment

- Godot Version: 4.1.1
- OS: Windows 10
- Hardware: [Your specs]
- Test Date: [Current date]

## Test Results Summary

- Overall gameplay feel: [Rate 1-10]
- Core mechanics working: [Yes/No]
- Performance acceptable: [Yes/No]
- Major issues found: [Number]
- Ready for next development phase: [Yes/No] 