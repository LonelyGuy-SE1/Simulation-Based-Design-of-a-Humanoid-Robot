# End Goal

# End-to-End Base Locomotion Policy (Simscape + RL) (Unitree G1)

## Objective
This project implements a robust, perturbation-resistant base locomotion policy for the 29-DoF Unitree G1 humanoid robot. Built entirely within the MATLAB/Simscape ecosystem, the architecture leverages Soft Actor-Critic (SAC) reinforcement learning to solve stable dynamic walking over uneven terrain. 

The project utilizes a strict Curriculum Learning approach: Phase 1 isolates the 12-DoF lower body to solve the Curse of Dimensionality, while casting the 17-DoF upper body as a rigidly frozen payload. 

## Control Architecture (Physics Engine)
The mechanical environment is engineered in Simulink/Simscape Multibody, prioritizing pure mathematical determinism and API cleanliness:
* **Curriculum Phase 1 (Frozen Torso):** The waist, arms, head, and camera gimbals (17 DoF) are disconnected from neural network actuation. They are locked using computed torque and massive virtual internal mechanics (Spring Stiffness: 1000 N·m/rad, Damping: 100 N·m/(rad/s)) to act as a solid shock-absorbing payload.
* **Contact Kinematics:** To prevent penalty-based contact force explosions during initialization, the 6-DoF root joint spawns the chassis precisely 1.0m above the infinite plane, allowing a clean gravitational drop before the agent takes control.

## Sensory-Motor API
The interface between the physics engine and the Reinforcement Learning agent is strictly defined by an immutable matrix index.

### Observation Space (37 Dimensions)
The robot's "Vestibular System" is built using a passive Transform Sensor to calculate the spatial delta between the World frame and the Pelvis frame. 
* **[1-3] Base Position ($X, Y, Z$):** Used for survival tracking ($Z$-height fall detection).
* **[4-7] Base Orientation ($q_w, q_x, q_y, q_z$):** Quaternions are used exclusively to prevent Gimbal Lock during catastrophic falls.
* **[8-10] Base Linear Velocity ($V_x, V_y, V_z$):** Primary driver for the task reward gradient.
* **[11-13] Base Angular Velocity ($\omega_x, \omega_y, \omega_z$):** Tracked to penalize torso thrashing.
* **[14-25] Joint Positions:** 12-DoF lower body kinematics.
* **[26-37] Joint Velocities:** 12-DoF lower body momentum.

### Action Space (12 Dimensions)
Continuous normalized torque commands $[-1, 1]$ mapped to the 12 lower-body revolute joints (Hip Pitch/Roll/Yaw, Knee, Ankle Pitch/Roll).

## Reinforcement Learning Framework
The learning loop utilizes the Soft Actor-Critic (SAC) algorithm to maximize both task reward and policy entropy, ensuring the discovery of energy-efficient, robust gaits.

### Two-Layer Dense Reward Structure
Instead of relying on sparse rewards or MoCap imitation priors, this environment utilizes a Dense Reward Architecture split into two explicit layers:
1. **The Goal Layer (Task & Survival):** * A constant positive survival drip for maintaining Pelvis $Z > 0.5$ meters.
   * An exponential reward tracking target forward velocity ($V_x$).
2. **The Penalty Layer (Regularization):** * Brutal mathematical penalties applied to energy consumption ($\sum \tau^2$), action rate changes (to prevent 1000Hz motor vibrations), and high angular velocities ($\omega_{x,y}$) to enforce a smooth, biologically plausible gait.

### Sim-to-Real Bridge (Domain Randomization)
To prevent the policy from overfitting to a pristine deterministic simulation, the environment utilizes procedural randomization at the start of every episode:
* Stochastic $Z$-axis drop heights.
* Randomized initial joint angles.
* Simulated IMU latency and observation noise injected directly into the 37-DoF state vector.

## Images

<img width="262" height="520" alt="image" src="https://github.com/user-attachments/assets/e4bfa148-435d-47aa-a9a6-2e7cb65a9b11" />

<img width="908" height="522" alt="image" src="https://github.com/user-attachments/assets/d789e746-8cec-4810-b759-c2b400c7afeb" />

Connections ;-; 12 dof connected :)
<img width="1021" height="535" alt="image" src="https://github.com/user-attachments/assets/ad37a4fe-2c4e-41c1-b1da-3c8907ef5b06" />

<img width="276" height="512" alt="image" src="https://github.com/user-attachments/assets/425e3d06-c132-4371-aaa1-232c1f1fe038" />

slow and steady progress is being made :)
<img width="934" height="466" alt="image" src="https://github.com/user-attachments/assets/5ec94697-e2a4-4dfa-99be-e88303d0a670" />

did some experiments with some different scripts today... and realized "reward hacking" is a real problem 😭, will try working with different scripts to try and limit that.

spent some time experimenting with sac on matlab today... will work on the reward function for the humanoid next.
<img width="364" height="112" alt="image" src="https://github.com/user-attachments/assets/4c61cc37-7470-4d13-8cd5-8a22d853584f" />
<img width="952" height="485" alt="image" src="https://github.com/user-attachments/assets/8c8dda2f-662c-4582-94b9-26e106a0ad91" />










