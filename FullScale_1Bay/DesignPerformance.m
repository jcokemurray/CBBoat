clear; 
close all;

% Calc performance for a given design, person weight, and structure weight...

% Utils path
path('../',path);

% Scale factor over subscale config 1 values
SFC1=1/.4681;

% Inputs
PersonWeight=18*SFC1^3; %lbs
PersonScale=1; % length scale for legroom and person CG metrics...
Nbay=1; % num of bays (rowers)

% Calc design from sizing laws, or spec directly
CalcDesign=0;
if CalcDesign
    % Sizing inputs
    BayLength=22*SFC1; % length of bays (in)
    GunwalePitch=55; % deg
    CabinWidth=15.5*SFC1; %in, generally needs to be fixed for decent ability to row with a kayak paddle, but generally less width => less drag but less stability...
    SeatDepth=.5*SFC1; % in, below waterline
    GunwaleMargin=2.375*SFC1; %in, gunwale height margin above waterline...
    
    % Calc parameters
    [TotalWeight,StructureWeight,CGH,CGLShift,MCH,GunwaleHeight,WaterLineHeight,FloorWidth,LegMargin,FA,WA,SeatHeight]=CalcCBParams(BayLength,GunwalePitch,CabinWidth,GunwaleMargin,PersonWeight,SeatDepth,Nbay,PersonScale);
    % Design params display
    BayLength
    GunwalePitch
    GunwaleHeight
    FloorWidth
    SeatHeight
    StructureWeight

else
    % Design params
    % Subscale config 1 scaled up and then lengthened...
    BayLength=60; % in
    GunwalePitch=55; % deg
    GunwaleHeight=10.0015;
    FloorWidth=19.1063; % in
    SeatHeight=3.8597; % in
    StructureWeight=15; % lbs
end

%-------

% Calc water line height
TWpB=(PersonWeight+StructureWeight)/Nbay; % total weight per bay
TM=TWpB*4.448/9.81; %kg
rhoWater=1000; %kg/m^3
theta=(90-GunwalePitch)/180*pi;
A=tan(theta);
B=FloorWidth*.0254;
C=-TM/(BayLength*.0254*rhoWater);
z=(-B+sqrt(B^2-4*A*C))/(2*A);
WaterLineHeight=z/.0254; % in

% Calc performance for a given design
SWpB=StructureWeight/Nbay; % lbs
[LegMargin,CGH,MCH,FA,WA]=CalcPerfMetrics(PersonWeight,BayLength/12,Nbay,GunwalePitch,GunwaleHeight/12,FloorWidth/12,SeatHeight/12,WaterLineHeight/12,SWpB,1);
StabMargin=(MCH-CGH)/MCH*100;

% inches
LegMargin=LegMargin*12;
CGH=CGH*12;
MCH=MCH*12;

StabMargin
LegMargin
FA
WA
CGH
MCH
WaterLineHeight

