
disp('Initializing Deep Learning Architecture...');

env = rlSimulinkEnv('g1_29dof_rev_1_0', 'g1_29dof_rev_1_0/RL Agent', obsInfo, actInfo);

statePath = [
    featureInputLayer(37, 'Normalization', 'none', 'Name', 'State')
    fullyConnectedLayer(256, 'Name', 'State_FC')
];

actionPath = [
    featureInputLayer(12, 'Normalization', 'none', 'Name', 'Action')
    fullyConnectedLayer(256, 'Name', 'Action_FC')
];

commonPath = [
    additionLayer(2, 'Name', 'Add')
    reluLayer('Name', 'Critic_Relu1')
    fullyConnectedLayer(256, 'Name', 'Critic_FC2')
    reluLayer('Name', 'Critic_Relu2')
    fullyConnectedLayer(256, 'Name', 'Critic_FC3')
    reluLayer('Name', 'Critic_Relu3')
    fullyConnectedLayer(1, 'Name', 'Critic_Output')
];

criticNet = layerGraph(statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'State_FC', 'Add/in1');
criticNet = connectLayers(criticNet, 'Action_FC', 'Add/in2');

critic1 = rlQValueFunction(criticNet, obsInfo, actInfo, ...
    'ObservationInputNames', 'State', 'ActionInputNames', 'Action');
critic2 = rlQValueFunction(criticNet, obsInfo, actInfo, ...
    'ObservationInputNames', 'State', 'ActionInputNames', 'Action');

commonActorPath = [
    featureInputLayer(37, 'Normalization', 'none', 'Name', 'State')
    fullyConnectedLayer(256, 'Name', 'Actor_FC1')
    reluLayer('Name', 'Actor_Relu1')
    fullyConnectedLayer(256, 'Name', 'Actor_FC2')
    reluLayer('Name', 'Actor_Relu2')
];

meanPath = fullyConnectedLayer(12, 'Name', 'Mean_Output');

stdPath = [
    fullyConnectedLayer(12, 'Name', 'Std_FC')
    softplusLayer('Name', 'Std_Output')
];

actorNet = layerGraph(commonActorPath);
actorNet = addLayers(actorNet, meanPath);
actorNet = addLayers(actorNet, stdPath);

actorNet = connectLayers(actorNet, 'Actor_Relu2', 'Mean_Output');
actorNet = connectLayers(actorNet, 'Actor_Relu2', 'Std_FC');

actor = rlContinuousGaussianActor(actorNet, obsInfo, actInfo, ...
    'ObservationInputNames', 'State', ...
    'ActionMeanOutputNames', 'Mean_Output', ...
    'ActionStandardDeviationOutputNames', 'Std_Output');

agentOptions = rlSACAgentOptions;
agentOptions.SampleTime = 0.02; 
agentOptions.TargetSmoothFactor = 0.005; 
agentOptions.ExperienceBufferLength = 1e6; 
agentOptions.DiscountFactor = 0.99; 

disp('Fusing Actor and Twin-Critics into SAC Agent...');
agent = rlSACAgent(actor, [critic1, critic2], agentOptions);
disp('Neural Architecture Successfully Compiled. Ready for Training.');