num_actions = 12;
actInfo = rlNumericSpec([num_actions 1], 'LowerLimit', -1, 'UpperLimit', 1);
actInfo.Name = 'G1_Leg_Torques';

num_obs = 37;
obsInfo = rlNumericSpec([num_obs 1]);
obsInfo.Name = 'G1_Master_Observation';

Ts = 0.02;
Tf = 10.0; 

