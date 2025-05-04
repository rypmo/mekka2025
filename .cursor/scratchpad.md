# MEKKA2025 Project Planning

## Background and Motivation
MEKKA2025 is a game project using Godot 4.4.1, with a focus on mech-based gameplay. The current state shows we have implemented core gameplay mechanics including:
- Player mech with movement, dashing, and shooting
- Enemy system with AI behavior and difficulty scaling
- Wave-based combat system
- Projectile system with damage and knockback
- Game state management and scoring

## High-Level Project Goals

*   **Core Gameplay Loop:** Create a compelling mix of horde survival (inspired by Vampire Survivors) and an extraction mechanic (inspired by Escape From Tarkov). With roguelite upgrades (inspired by Hades).
*   **Visual Style:** Develop a 2D top-down isometric aesthetic, drawing inspiration from games like Hades and Hyper Light Drifter.
*   **Level Design (Long-Term):** Implement procedurally generated maps for replayability.
*   **There will be a staging area (Long-Term):** In between rounds players can spend found currency to upgrade various traits for the mech or the pilot. 

The current distance-based attack trigger is unreliable, especially for non-centered collisions (corners, angles). Enemies fail to attack even when their collision shapes touch the player because the distance between their centers is greater than the configured `attack_range`. The goal is to implement a reliable attack trigger based on physical overlap using Godot's standard `Area2D` system.

## Key Challenges and Analysis
1. **Project Structure**: We need to establish a clear, maintainable project structure
2. **Version Control**: Ensure proper Git setup and workflow
3. **Development Environment**: Verify Godot version and compatibility
4. **Code Organization**: Implement consistent coding standards and patterns
5. **Testing Framework**: Establish testing practices for game mechanics
6. **Documentation**: Create clear documentation for the project
7. **Game Balance**: Fine-tune difficulty scaling and combat mechanics
8. **Performance Optimization**: Ensure smooth gameplay with multiple enemies and projectiles
9. **Debugging**: Systematically identify and fix bugs found during testing.

- Distance checks are inaccurate for shape overlap.
- Manual overlap calculation is complex.
- `Area2D` provides a robust, built-in solution for overlap detection.

## Checkpoints

### Checkpoint 1 (YYYY-MM-DD HH:MM): Area2D Hitbox/Hurtbox Plan Confirmed
- **Goal:** Replace distance-based attack check with `Area2D` overlap detection.
- **Components:**
    - Enemy "Hitbox" (`Area2D` + `CollisionShape2D`)
    - Player "Hurtbox" (`Area2D` + `CollisionShape2D`)
- **Trigger:** `area_entered` signal from Enemy Hitbox.
- **Tasks:** Define layers, add Area2Ds to scenes, modify `enemy.gd` script, test.

## High-level Task Breakdown
1. **Project Setup and Verification**
   - [x] Verify Godot version and compatibility
   - [x] Check project structure and organization
   - [x] Review Git setup and configuration
   - [x] Document current project state

2. **Code Quality and Standards**
   - [x] Establish coding standards and style guide
   - [x] Review existing code for consistency
   - [x] Implement linting and formatting tools
   - [x] Create code review process

3. **Core Gameplay Implementation**
   - [x] Implement player movement and controls
   - [x] Create projectile system
   - [x] Develop enemy AI and behavior
   - [x] Implement wave-based combat
   - [x] Add difficulty scaling
   - [ ] Balance gameplay mechanics
   - [ ] Add visual feedback for combat
   - [ ] Implement sound effects

4. **Manual Testing and Validation**
   - [ ] Test player movement and controls
   - [ ] Verify projectile behavior and collision
     - [x] Bug Fixed: Projectiles not spawning at correct muzzle position
     - [x] Bug Fixed: Projectiles passing through enemies (Collision Layer/Mask fixed)
     - [x] Bug Clarified: Projectiles dealing damage (Value needed tuning)
     - [x] Bug Fixed: Enemies not visually experiencing knockback (move_and_slide was skipped)
     - [x] Bug Fixed: Enemy knockback resistance confirmed working correctly.
   - [x] Test enemy AI and pathfinding

   **Enhance Test Environment for Spawning Tests**
     - [x] Task: Expand TileMap/ground boundaries in `tests/comprehensive_test_level.tscn` (e.g., double size).
     - [x] Task: Update boundary collision shapes to match new size.
     - [x] Task: Add several simple `StaticBody2D` obstacles with collision shapes.
     - [x] Task: Re-bake `NavigationRegion2D` to account for new obstacles.
     - [x] Task: Adjust `Camera2D` limits in `tests/comprehensive_test_level.tscn` to match new level size.
     - [x] Task: Increase Viewport Width/Height in Project Settings (e.g., to 1600x900).
     - [x] Task: Verify viewport stretch mode handles the new resolution appropriately.

   **Test and Balance Spawning Mechanics**
     - [x] Check if enemies spawn at appropriate intervals (adjust SpawnManager timeline)
     - [x] Verify enemies spawn off-screen correctly
     - [x] Assess if the number of enemies feels appropriate over time (adjust timeline)
     - [x] Evaluate difficulty progression (does it ramp up satisfyingly?)

   **Implement Time-Based Horde Spawning (Vampire Survivors Style)**
     - [x] Task: Create `SpawnManager` node and `spawn_manager.gd` script.
     - [x] Task: Implement core spawn timeline logic in `spawn_manager.gd`
     - [x] Task: Connect `SpawnManager` to GameManager or main scene
     - [x] Task: Ensure `SpawnManager` gets player position reference
     - [x] Task: Implement off-screen spawning logic
     - [x] Task: Test basic spawning

  **Visual Feedback & Juice**
    - [ ] Task: Add Hit Flash effect to enemies/player

5. **Testing Infrastructure**
   - [ ] Set up testing framework
   - [ ] Create test cases for core mechanics
   - [ ] Implement continuous integration
   - [ ] Document testing procedures

6. **Documentation**
   - [x] Create README with project overview
   - [x] Document architecture and design decisions
   - [x] Set up API documentation
   - [x] Create contribution guidelines

7. **Performance and Optimization**
   - [ ] Profile game performance
   - [ ] Optimize enemy spawning
   - [ ] Implement object pooling for projectiles
   - [ ] Add level of detail systems

## Feature Development Backlog (Post Core Loop)

8.  **XP Drops & Collection**
    - [ ] Task: Design XP drop appearance/behavior (e.g., gem scene).
    - [ ] Task: Modify `enemy.gd` to instantiate XP drop on death.
    - [ ] Task: Implement XP collection mechanic (e.g., player Area2D, magnet effect).
    - [ ] Task: Add XP tracking to player/game state.

9.  **Leveling & Upgrade System**
    - [ ] Task: Define XP thresholds for leveling up.
    - [ ] Task: Implement level-up event/signal.
    - [ ] Task: Design basic upgrade selection UI (placeholder).
    - [ ] Task: Create data structure for available upgrades.
    - [ ] Task: Implement logic to present random upgrade choices on level up.
    - [ ] Task: Implement basic upgrade application (stat mods initially).

10. **Extraction Mechanic**
    - [ ] Task: Implement main game timer (e.g., 10 minutes).
    - [ ] Task: Design extraction zone appearance/scene.
    - [ ] Task: Implement logic to spawn extraction zone after timer reaches threshold.
    - [ ] Task: Implement limited-time availability for the zone (e.g., despawn timer).
    - [ ] Task: Implement player detection within the zone and successful extraction trigger.
    - [ ] Task: Define consequence for missing extraction (e.g., wait for next cycle).

### Area2D Hitbox/Hurtbox Implementation

1.  **Task: Define Collision Layers/Masks for Areas.**
    *   **Details:** Assign dedicated physics layers for the new Area2Ds (Based on `project.godot`):
        *   Layer 5 (Value 16): `enemy_hitbox`
        *   Layer 6 (Value 32): `player_hurtbox`
    *   **Configuration:**
        *   Enemy `AttackHitbox` Area2D: Layer = 5 (16), Mask = 6 (32)
        *   Player `PlayerHurtbox` Area2D: Layer = 6 (32), Mask = 5 (16)
    *   **Success Criteria:** Collision layers documented in this plan. *(Completed)*
2.  **Task: Add `PlayerHurtbox` to `mech.tscn`.**
    *   **Details:** Add/Configure `Area2D` (`PlayerHurtbox`) + `CollisionShape2D` to `Mech`. Set shape (e.g., 129x128 rect). Set Layer=6 (32), Mask=5 (16). Add to group `"player_hurtbox"`.
    *   **Success Criteria:** `