% Sizing considerations

Lbay=18:3:72; %in,  min Lbay is 1.5 ft. with a 1 ft. wide seat (6 in. upper leg overhang and vertical lower legs)
GunPitch=40:1:75; % deg


[L,G]=meshgrid(Lbay,GunPitch);

CabinWidth=33; %in, generally needs to be fixed for decent ability to row with a kayak paddle, but generally less width => less drag but less stability...
SeatDepth=1; % in, below waterline
GunwaleMargin=5; %in, gunwale height margin above waterline...
PersonWeight=175; %lbs
Nbay=4; % num of bays (rowers)

TotalWeight=NaN*ones(size(L));
StructureWeight=NaN*ones(size(L));
CGH=NaN*ones(size(L));
MCH=NaN*ones(size(L));
GunwaleHeight=NaN*ones(size(L));
WaterLineHeight=NaN*ones(size(L));
FloorWidth=NaN*ones(size(L));
LegMargin=NaN*ones(size(L));
FA=NaN*ones(size(L));
WA=NaN*ones(size(L));
SeatHeight=NaN*ones(size(L));
for i=1:numel(L)  
    [TotalWeight(i),StructureWeight(i),CGH(i),MCH(i),GunwaleHeight(i),WaterLineHeight(i),FloorWidth(i),LegMargin(i),FA(i),WA(i),SeatHeight(i)]=CalcCBParams(L(i),G(i),CabinWidth,GunwaleMargin,PersonWeight,SeatDepth,Nbay,1);
end
% When NaN is returned for a case, the gunwale pitch was too low to produce
% necessary depth for bouyancy while still keeping the cabin width as
% specified. 

% shouldnt make seat depth any larger than it needs to be (seat depth = geo
% depth. cabin height needs to be higher than waterline depth for
% flotation... Wan't CG below Moment Center for stability
StaticMargin=(MCH-CGH)./MCH*100; % static stab margin in percent moment center height
figure(1)
[cs,h]=contour(L,G,StaticMargin,[10:10:60],'b-'); % contours of 0, 10, 20, 30% static margin plotted
clabel(cs,h,'LabelSpacing',500)
hold on
[cs,h]=contour(L,G,SeatHeight,0:6,'r-'); % contours of seat level above water
clabel(cs,h,'LabelSpacing',500)
[cs,h]=contour(L,G,FloorWidth,[6,12,18,24],'k-'); % contours of floor width
clabel(cs,h,'LabelSpacing',500)
[cs,h]=contour(L,G,LegMargin,[-12,0,12],'g-'); % contours of legroom margin
clabel(cs,h,'LabelSpacing',500)
contour(L,G,WA+100*FA,10)  % some sort of drag scaling area
hold off
grid on
xlabel('Lbay (ft)')
ylabel('Gunwale Pitch (deg)')
title('Blue: Static Margin (%), Red: Seat Height (in), Black: Floor Width (in), Green: Legroom Margin (in), Colormap: Drag Area (ft^2)')



