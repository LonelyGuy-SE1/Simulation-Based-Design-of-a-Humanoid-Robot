model_name = 'g1_29dof_rev_1_0';
robot_subsystem = [model_name, '/Unitree G1 Hardware'];

active_legs = {
    'left_hip_pitch_joint', 'left_hip_roll_joint', 'left_hip_yaw_joint', ...
    'left_knee_joint', 'left_ankle_pitch_joint', 'left_ankle_roll_joint', ...
    'right_hip_pitch_joint', 'right_hip_roll_joint', 'right_hip_yaw_joint', ...
    'right_knee_joint', 'right_ankle_pitch_joint', 'right_ankle_roll_joint'
};

disp('Executing Final Torso Lock with Correct Enums...');
all_joints = find_system(robot_subsystem, 'LookUnderMasks', 'on', 'MaskType', 'Revolute Joint');

for i = 1:length(all_joints)
    joint_path = all_joints{i};
    [~, joint_name] = fileparts(joint_path);
    
    if ~ismember(joint_name, active_legs)
        try
            set_param(joint_path, 'SpringStiffness', '1000');
            set_param(joint_path, 'DampingCoefficient', '100');
            
            set_param(joint_path, 'TorqueActuationMode', 'NoTorque');
            
            fprintf('LOCKED: %s\n', joint_name);
        catch ME
            fprintf('FATAL on %s: %s\n', joint_name, ME.message);
        end
    end
end
disp('Upper body mathematically frozen. Ready for physics validation.');