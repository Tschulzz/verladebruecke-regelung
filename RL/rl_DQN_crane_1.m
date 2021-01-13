L_0 = 0.2;
x_0 = 0;
phi_0 = 0;
g = 9.81;
T1 = 0.05;
T2 = 0.05;
r1 = 0.05;
r2 = 0.05;
ue1 = 6;
ue2 = 3;
d = 0.02;

mdl = 'modular_NL_Modell_2020b';
open_system(mdl)

env = rlPredefinedEnv('SimplePendulumModel-Discrete');
env.ResetFcn = @(in)setVariable(in,'theta0',pi,'Workspace',mdl);

obsInfo = getObservationInfo(env);

actInfo = getActionInfo(env);

Ts = 0.05;
Tf = 20;

rng(0);

dnn = [
    featureInputLayer(3,'Normalization','none','Name','state')
    fullyConnectedLayer(24,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(48,'Name','CriticStateFC2')
    reluLayer('Name','CriticCommonRelu')
    fullyConnectedLayer(3,'Name','output')];

figure
plot(layerGraph(dnn))

criticOpts = rlRepresentationOptions('LearnRate',0.001,'GradientThreshold',1);
critic = rlQValueRepresentation(dnn,obsInfo,actInfo,'Observation',{'state'},criticOpts);

agentOptions = rlDQNAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-3,...
    'ExperienceBufferLength',3000,... 
    'UseDoubleDQN',false,...
    'DiscountFactor',0.9,...
    'MiniBatchSize',64);

agent = rlDQNAgent(critic,agentOptions);

trainingOptions = rlTrainingOptions(...
    'MaxEpisodes',1000,...
    'MaxStepsPerEpisode',500,...
    'ScoreAveragingWindowLength',5,...
    'Verbose',false,...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',-1100,...
    'SaveAgentCriteria','EpisodeReward',...
    'SaveAgentValue',-1100);

doTraining = false;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainingOptions);
else
    % Load the pretrained agent for the example.
    load('SimulinkPendulumDQNMulti.mat','agent');
end

simOptions = rlSimulationOptions('MaxSteps',500);
experience = sim(env,agent,simOptions);
