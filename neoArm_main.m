%% Common parameters
% Rigid Body Tree information
neoArm = importrobot("neoArm_conf",DataFormat="column");
eeName = 'Body6';
numJoints = numel(neoArm.homeConfiguration);
ikInitGuess = neoArm.homeConfiguration;

q0 = [-pi/2; 0; 0; 0; 0];
q1 = 0*ones(5,1);

neoArm.Bodies{1}.Joint.PositionLimits = [-pi pi];
neoArm.Bodies{2}.Joint.PositionLimits = [-pi/2 pi/2];
neoArm.Bodies{3}.Joint.PositionLimits = [-pi/2 pi/2];
neoArm.Bodies{4}.Joint.PositionLimits = [-pi/2 pi/2];
neoArm.Bodies{5}.Joint.PositionLimits = [-pi/2 pi/2];
%%
toolPositionHome = [0.2,0,0.3];

% Maximum number of waypoints (for Simulink)
tStart = 0.05;
tDuration = 16;

% Contact surface
refPos = 0.0;
objectPos = 0.2 ;
weights = [0 0 0 1 1 1];
K = [1000  900]; %Genetic alg.

nesneTakip;

% Array of waypoint times
[~,sayi] = size(waypoints);
maxWaypoints = sayi;
waypointTimes = linspace(0,tDuration,sayi); %0:4:16;

% Trajectory sample time
ts = 0.02;
trajTimes = 0:ts:waypointTimes(end);

q0 = [0;0;0;0;0];
q1 = [pi/2;0;0;0;0];
waypt1 = [waypoints(:,1) orientations(:,1)];
initTargetPose = eul2tform(waypt1(:,2)');
initTargetPose(1:3,end) = waypt1(:,1)';
ik = inverseKinematics('RigidBodyTree',neoArm);
[q0,solInfo] = ik(eeName,initTargetPose,weights,q0);
dq0 = [0;0;0;0;0];

clearvars -except weights dq0 q0 q1 neoArm waypoints waypointTimes orientations trajTimes ts tStart tDuration K objectPos refPos
