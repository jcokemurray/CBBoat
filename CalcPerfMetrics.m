function [LegMargin,CGH,MCH,FA,WA]=CalcPerfMetrics(PersonWeight,Lbay,Nbay,GunPitch,GunwaleHeight,FW,SeatHeight,WaterLineHeight,SWpB,PersonScale)

% lengths in ft

TWpB=PersonWeight+SWpB; % total weight per bay
rhoWater=1000; %kg/m^3

% Calc legroom margin as actual legroom - comfortable legroom (straight
% upper leg). Assuming 2 ft. lower leg and 1.5 ft upper leg.
LLL=2*PersonScale;
ULL=1.5*PersonScale;
if isnan(SeatHeight)
    LegMargin=NaN;
else
    if SeatHeight<LLL
        LegMargin=Lbay-(ULL+sqrt(LLL^2-SeatHeight^2));
    else
        LegMargin=Lbay-ULL;
    end
end

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
