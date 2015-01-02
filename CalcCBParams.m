function [TotalWeight,StructureWeight,CGH,MCH,GunwaleHeight,WaterLineHeight,FW,LegMargin,FA,WA,SeatHeight]=CalcCBParams(Lbay,GunPitch,CabinWidth,GunwaleMargin,PersonWeight,SeatDepth,Nbay,PersonScale)

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
% Calc legroom margin as actual legroom - comfortable legroom (straight
% upper leg). Assuming 2 ft. lower leg and 1.5 ft upper leg.
SeatHeight=WaterLineHeight-SeatDepth;
LLL=2*PersonScale;
ULL=1.5*PersonScale;
LegMargin=Lbay-(ULL+sqrt(LLL^2-SeatHeight^2));

% Calc CG height
% Assume person cg is 6 in. above seat, and structure cg is 1/2 of gunwale
% height...
CGHS=1/3;
StructureCG=CGHS*GunwaleHeight; %ft, above floor
PersonCG=.5*PersonScale;
CGH=(PersonWeight*(SeatHeight+PersonCG)+SWpB*StructureCG)/TWpB; % ft

% % Test plot bouyancy roll moment about centerline for different roll angles
% BoatRoll=-10:10; % deg
% theta1=(GunPitch+BoatRoll)/180*pi;
% theta2=(GunPitch-BoatRoll)/180*pi;
% theta3=(BoatRoll)/180*pi;
% FWm=FW*.3048; %m
% CenterDepth=WaterLineHeight*.3048; %m
% d1=CenterDepth-FWm/2*sin(theta3); %m
% d2=CenterDepth+FWm/2*sin(theta3); %m
% % bouyancy moment and force (note: force at zero boat roll should equal person
% % weight)
% Mb=(Lbay*.3048*rhoWater*9.81*(cos(theta3)./tan(theta1).*d1.^2*FWm/4+d1.^3./(6*tan(theta1).^2)-cos(theta3)./tan(theta2).*d2.^2*FWm/4-d2.^3./(6*tan(theta2).^2)-cos(theta3).^2.*sin(theta3)*FWm^3/12))/(4.448*.3048);  %lb-ft
% Fb=(Lbay*.3048*rhoWater*9.81*(d1.^2./(2*tan(theta1))+d2.^2./(2*tan(theta2))+CenterDepth*FWm*cos(theta3)))/4.448; %lbs
% plot(BoatRoll,Mb,BoatRoll,Fb)
% % Calc metacenter (moment center) height above moment ref point at zero
% % roll angle. Moment ref point is set at center of floor panel, and boat
% % roll angle is applied around this point for the purpose of approximating
% % moment center...
% % (MetacenterHeight = dMb/dTheta / Fb , where Mb is referenced to a point 
% % on the y station of the current bouyancy center, i.e. the current zero moment y station)
% % Need CG height above moment ref to be less than metacenter height above
% % moment ref for roll stability.
% MCH=-((Mb(12)-Mb(10))/(2/180*pi))/Fb(11);


% Calc metacenter (moment center) height above moment ref point at zero
% roll angle. Moment ref point is set at center of floor panel, and boat
% roll angle is applied around this point for the purpose of approximating
% moment center...
% (MetacenterHeight = dMb/dTheta / Fb , where Mb is referenced to a point 
% on the y station of the current bouyancy center, i.e. the current zero moment y station)
% Need CG height above moment ref to be less than metacenter height above
% moment ref for roll stability.
FWm=FW*.3048; %m
CenterDepth=WaterLineHeight*.3048; %m
Fb0=(Lbay*.3048*rhoWater*9.81)*(CenterDepth^2/tan(GunPitch/180*pi)+CenterDepth*FWm)/4.448; %lbs
dMbdtheta0=-(Lbay*.3048*rhoWater*9.81)*(CenterDepth*FWm^2/(2*tan(GunPitch/180*pi))+CenterDepth^2*FWm/2*((1+cos(GunPitch/180*pi)^2)/sin(GunPitch/180*pi)^2)+(2/3)*CenterDepth^3/(tan(GunPitch/180*pi)*sin(GunPitch/180*pi)^2)+FWm^3/12)/(4.448*.3048); %lb-ft
MCH=-dMbdtheta0/Fb0;

% Frontal area underwater (less frontal area, less potential for pressure
% drag...)
FA=(CenterDepth^2/tan(GunPitch/180*pi)+CenterDepth*FWm)/(.3048^2);  % ft^2
% Wetted area underwater  (less wetted area, less friction drag)
WA=(FWm+2*CenterDepth/sin(GunPitch/180*pi))/(.3048)*Lbay*Nbay; % ft^2

% Total weight (lbs)
StructureWeight=SWpB*Nbay;
TotalWeight=TWpB*Nbay;

% Inches
GunwaleHeight=GunwaleHeight*12;
WaterLineHeight=WaterLineHeight*12;
FW=FW*12;
LegMargin=LegMargin*12; 
SeatHeight=SeatHeight*12;
MCH=MCH*12; 
CGH=CGH*12;


