function [TotalWeight,StructureWeight,CGH,CGLShift,MCH,GunwaleHeight,WaterLineHeight,FW,LegMargin,FA,WA,SeatHeight]=CalcCBParams(Lbay,GunPitch,CabinWidth,GunwaleMargin,PersonWeight,SeatDepth,Nbay,PersonScale)

% All lengths in and out in inches. All angles in deg

% ft
Lbay=Lbay/12;
CabinWidth=CabinWidth/12;
GunwaleMargin=GunwaleMargin/12;
SeatDepth=SeatDepth/12;

% Size structure
CBeam=.1; % Beam height scale factor (on Lbay)
BeamHeight=CBeam*Lbay; %ft
BeamWidth=2/3*BeamHeight; %ft
CBDens=.5; %lb/ft^2 (sheet density)
BeamWeight=CBDens*2*(BeamHeight*Lbay+BeamWidth*Lbay);
SkinWeight=CBDens*(CabinWidth*Lbay+CabinWidth/3*Lbay*2); % approx... assume cabin height = 1/3 width and full floor width as a guess...
FSeat=.01; % seat structure weight as fraction of person weight (efficiency)
SeatWeight=FSeat*PersonWeight;
SWpB=BeamWeight+SkinWeight+SeatWeight; % structure weight per bay (lbs)
TWpB=PersonWeight+SWpB; % total weight per bay

% Calc bouyancy depth requirement
rhoWater=1000; %kg/m^3
TM=TWpB*4.448/9.81; %kg
CabinWidthWL=CabinWidth-2*(GunwaleMargin/tan(GunPitch/180*pi)); % Cabin width at waterline
WaterLineHeight=CabinWidthWL*.3048/2*tan(GunPitch/180*pi)-1/2*sqrt((CabinWidthWL*.3048*tan(GunPitch/180*pi))^2-4*TM*tan(GunPitch/180*pi)/(rhoWater*Lbay*.3048));
if imag(WaterLineHeight)==0
    WaterLineHeight=WaterLineHeight/.3048; %ft
    GunwaleHeight=WaterLineHeight+GunwaleMargin;
    GL=GunwaleHeight/sin(GunPitch/180*pi); % Length of Gunwale piece
    GW=GL*cos(GunPitch/180*pi);
    if 2*GW>CabinWidth
        warning('Gunwale width is larger than specified overall cabin width.')
        % For calculation purposes, set to NaN
        FW=NaN;
        WaterLineHeight=NaN;
        GunwaleHeight=NaN;
    else
        FW=CabinWidth-2*GW; % width of floor
    end
else
    % For calculation purposes, set to NaN
    FW=NaN;
    WaterLineHeight=NaN;
    GunwaleHeight=NaN;
end

% Calc seat height
SeatHeight=WaterLineHeight-SeatDepth;

% Calc performance metrics
[LegMargin,CGH,CGLShift,MCH,FA,WA]=CalcPerfMetrics(PersonWeight,Lbay,Nbay,GunPitch,GunwaleHeight,FW,SeatHeight,WaterLineHeight,SWpB,PersonScale);

% Total weight (lbs)
StructureWeight=SWpB*Nbay;
TotalWeight=TWpB*Nbay;

% Inches
GunwaleHeight=GunwaleHeight*12;
WaterLineHeight=WaterLineHeight*12;
FW=FW*12;
SeatHeight=SeatHeight*12;
LegMargin=LegMargin*12; 
MCH=MCH*12; 
CGH=CGH*12;
CGLShift=CGLShift*12;

