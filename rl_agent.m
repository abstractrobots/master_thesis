numObs = 3;  % Number of dimension of the observation space
numAct = 5;   % Number of dimension of the action space

obsInfo = rlNumericSpec([numObs 1]);

actInfo = rlNumericSpec([numAct 1]);
actInfo.LowerLimit = -1;
actInfo.UpperLimit = 1;

mdl = "neoArm_14_05_2024";
blk = mdl + "/RL Agent";
env = rlSimulinkEnv(mdl,blk,obsInfo,actInfo);

env.ResetFcn = @neoArmResetFcn;

Ts = 0.01;
Tf = 10;


% Set the random seed for reproducibility.
rng(0)

% Define the network layers.
cnet = [
    featureInputLayer(numObs,Name="observation")
    fullyConnectedLayer(128)
    concatenationLayer(1,2,Name="concat")
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(32)
    reluLayer
    fullyConnectedLayer(1,Name="CriticOutput")];
actionPath = [
    featureInputLayer(numAct,Name="action")
    fullyConnectedLayer(128,Name="fc2")];

% Connect the layers.
criticNetwork = layerGraph(cnet);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = connectLayers(criticNetwork,"fc2","concat/in2");

% plot(criticNetwork)

%%

criticdlnet = dlnetwork(criticNetwork,'Initialize',false);
criticdlnet1 = initialize(criticdlnet);
criticdlnet2 = initialize(criticdlnet);

critic1 = rlQValueFunction(criticdlnet1,obsInfo,actInfo, ...
    ObservationInputNames="observation");
critic2 = rlQValueFunction(criticdlnet2,obsInfo,actInfo, ...
    ObservationInputNames="observation");
%%
% Create the actor network layers.
commonPath = [
    featureInputLayer(numObs,Name="observation")
    fullyConnectedLayer(128)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer(Name="anet_out")];
meanPath = [
    fullyConnectedLayer(32,Name="meanFC")
    reluLayer(Name="relu3")
    fullyConnectedLayer(numAct,Name="mean")];
stdPath = [
    fullyConnectedLayer(numAct,Name="stdFC")
    reluLayer(Name="relu4")
    softplusLayer(Name="std")];

% Connect the layers.
actorNetwork = layerGraph(commonPath);
actorNetwork = addLayers(actorNetwork,meanPath);
actorNetwork = addLayers(actorNetwork,stdPath);
actorNetwork = connectLayers(actorNetwork,"anet_out","meanFC/in");
actorNetwork = connectLayers(actorNetwork,"anet_out","stdFC/in");

%%
actordlnet = dlnetwork(actorNetwork);
actor = rlContinuousGaussianActor(actordlnet, obsInfo, actInfo, ...
    ObservationInputNames="observation", ...
    ActionMeanOutputNames="mean", ...
    ActionStandardDeviationOutputNames="std");

%%

agentOpts = rlSACAgentOptions( ...
    SampleTime=Ts, ...
    TargetSmoothFactor=1e-3, ...    
    ExperienceBufferLength=1e6, ...
    MiniBatchSize=128, ...
    NumWarmStartSteps=1000, ...
    DiscountFactor=0.99);

agentOpts.ActorOptimizerOptions.Algorithm = "adam";
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.ActorOptimizerOptions.GradientThreshold = 1;

for ct = 1:2
    agentOpts.CriticOptimizerOptions(ct).Algorithm = "adam";
    agentOpts.CriticOptimizerOptions(ct).LearnRate = 1e-4;
    agentOpts.CriticOptimizerOptions(ct).GradientThreshold = 1;
end

agent = rlSACAgent(actor,[critic1,critic2],agentOpts);

%%

trainOpts = rlTrainingOptions(...
    MaxEpisodes=6000, ...
    MaxStepsPerEpisode=floor(Tf/Ts), ...
    ScoreAveragingWindowLength=100, ...
    Plots="training-progress", ...
    StopTrainingCriteria="AverageReward", ...
    StopTrainingValue=675, ...
    UseParallel=false);

if trainOpts.UseParallel
    % Disable visualization in Simscape Mechanics Explorer
    set_param(mdl, SimMechanicsOpenEditorOnUpdate="off");
    set_param(mdl+"/Physical Model RL/Dinamik Model", ...
        "VChoice", "None");
    % Disable animation in MATLAB figure
    doViz = false;
    save_system(mdl);
else
    % Enable visualization in Simscape Mechanics Explorer
    set_param(mdl, SimMechanicsOpenEditorOnUpdate="on");
    % Enable animation in MATLAB figure
    doViz = true;
end

logger = rlDataLogger();
logger.AgentLearnFinishedFcn = @logAgentLearnData;
logger.EpisodeFinishedFcn    = @(data) logEpisodeData(data, doViz);


doTraining = true;
if doTraining
    trainResult = train(agent,env,trainOpts,Logger=logger);
else
    load("neoArmAgent.mat");       
end

userSpecifiedConditions = true;
if userSpecifiedConditions
    env.ResetFcn = [];
else
    env.ResetFcn = @neoArmResetFcn;
end

simOpts = rlSimulationOptions(MaxSteps=floor(Tf/Ts));

set_param(mdl, SimMechanicsOpenEditorOnUpdate="on");
doViz = true;

experiences = sim(agent,env,simOpts);

fig = animatedPath(experiences);


%%
function in = neoArmResetFcn(in)
    U0 = [0 0 0 0 0];
    in = setVariable(in,"U0",U0);
end


function dataToLog = logAgentLearnData(data)
% This function is executed after completion
% of the agent's learning subroutine

dataToLog.ActorLoss = data.ActorLoss;
dataToLog.CriticLoss = data.CriticLoss;

end

function dataToLog = logEpisodeData(data, doViz)
% This function is executed after the completion of an episode

dataToLog.Experience = data.Experience;

% Show an animation after episode completion
if doViz
    animatedPath(data.Experience);
end

end
