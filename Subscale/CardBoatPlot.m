clear; 
close all;

% Utils path
path('../',path);

% Plot out boat dimensions and calc relevant figures
Nbay=1; % num of bays (rowers)
BayLength=18; % length of bays (in)
GunwalePitch=55; % deg

CabinWidth=12; %in, generally needs to be fixed for decent ability to row with a kayak paddle, but generally less width => less drag but less stability...
SeatDepth=.375; % in, below waterline
GunwaleMargin=1.875; %in, gunwale height margin above waterline...
PersonWeight=8.5; %lbs
PersonScale=.3636; % length scale for legroom and person CG metrics...

EndPitch=35; % deg
EndHeight=5; % in

%-----
CabinLength=Nbay*BayLength; % ft, overall boat length minus components from bow and stern (Nbays * BayLength)

% Calc parameters
[TotalWeight,StructureWeight,CGH,MCH,GunwaleHeight,WaterLineHeight,FloorWidth,LegMargin,FA,WA,SeatHeight]=CalcCBParams(BayLength,GunwalePitch,CabinWidth,GunwaleMargin,PersonWeight,SeatDepth,Nbay,PersonScale);

StabMargin=(MCH-CGH)/MCH*100 %Roll stab margin, might want 40-50% or so...
SeatH=SeatHeight
LegMargin % legroom - legroom required for straight upper leg (in)
FloorWidth
GunwaleHeight
TotalWeight
StructureWeight

% Check
GL=GunwaleHeight/sin(GunwalePitch/180*pi); % Length of Gunwale piece
EL=EndHeight/sin(EndPitch/180*pi); % length of end piece
GW=GL*cos(GunwalePitch/180*pi);
if 2*GW>CabinWidth
    error('CBP:e1','Gunwale width is larger than specified overall cabin width.')
end

TempW=FloorWidth+2*GL; % Overall template width
TempL=CabinLength+2*EL; % Overall template length
BoatLength=CabinLength+2*EL*cos(EndPitch/180*pi); % Overall boat length

% % test plot theta contours in gunwale and end pitch angles
% GPtest=0:90;
% EPtest=0:90;
% [GPT,EPT]=meshgrid(GPtest,EPtest);
% TT=acos(sin(GPT/180*pi).*sin(EPT/180*pi))/pi*180;
% figure(3)
% contour(GPT,EPT,TT,20);

% Calc template folds
CPoints=[CabinLength/2,-FloorWidth/2,0   % Floor corner
        BoatLength/2,-FloorWidth/2,EndHeight    % End corner
        CabinLength/2,-CabinWidth/2,GunwaleHeight]; % Gunwale corner
PNorm=cross(CPoints(2,:)-CPoints(1,:),CPoints(3,:)-CPoints(1,:));
PNorm=PNorm/sqrt(PNorm*PNorm');
% Calc outer edge direction in plane w.r.t. end edges
Edge=CPoints(3,:)-CPoints(2,:);
% w.r.t end edge
TDir=CPoints(2,:)-CPoints(1,:);
TDir=TDir/sqrt(TDir*TDir');
NDir=cross(PNorm,TDir);
Edge2=Edge*[TDir',NDir']; % 1 is along, 2 is into corner

% Plot Template in cm
CornerPoint=[CabinLength/2,FloorWidth/2];
EPoint=[TempL/2,FloorWidth/2];
GPoint=[CabinLength/2,TempW/2];
FoldP=EPoint+Edge2;
MFoldP=(GPoint+FoldP)/2;

CornerFoldPoints=[FoldP;CornerPoint;MFoldP];
   
EdgePoints=[TempL/2,FloorWidth/2
            FoldP(1),FoldP(2)
            CabinLength/2,TempW/2
            -CabinLength/2,TempW/2
            -FoldP(1),FoldP(2)
            -TempL/2,FloorWidth/2
            -TempL/2,-FloorWidth/2
            -FoldP(1),-FoldP(2)
            -CabinLength/2,-TempW/2
            CabinLength/2,-TempW/2
            FoldP(1),-FoldP(2)            
            TempL/2,-FloorWidth/2
            TempL/2,FloorWidth/2];
        
FoldPoints=[TempL/2,FloorWidth/2
            -TempL/2,FloorWidth/2
            TempL/2,-FloorWidth/2
            -TempL/2,-FloorWidth/2
            CabinLength/2,-TempW/2
            CabinLength/2,TempW/2
            -CabinLength/2,-TempW/2
            -CabinLength/2,TempW/2];
            
figure(1)
hold on
plot(EdgePoints(:,2)*2.54,EdgePoints(:,1)*2.54,'b-')

plot(FoldPoints(1:2,2)*2.54,FoldPoints(1:2,1)*2.54,'b--')
plot(FoldPoints(3:4,2)*2.54,FoldPoints(3:4,1)*2.54,'b--')
plot(FoldPoints(5:6,2)*2.54,FoldPoints(5:6,1)*2.54,'b--')
plot(FoldPoints(7:8,2)*2.54,FoldPoints(7:8,1)*2.54,'b--')

plot(CornerFoldPoints(:,2)*2.54,CornerFoldPoints(:,1)*2.54,'b--')

hold off
grid on
title('Template (cm)')
set(gca,'DataAspectRatio',[1,1,1])

% plot completed boat form
figure(2)
Points=[BoatLength/2,-FloorWidth/2,EndHeight    % Front and rear
        BoatLength/2,FloorWidth/2,EndHeight  
        -BoatLength/2,-FloorWidth/2,EndHeight
        -BoatLength/2,FloorWidth/2,EndHeight
        CornerPoint,0                         % Floor
        -CornerPoint(1),CornerPoint(2),0
        -CornerPoint,0
        CornerPoint(1),-CornerPoint(2),0
        CabinLength/2,-CabinWidth/2,GunwaleHeight % Sides
        CabinLength/2,CabinWidth/2,GunwaleHeight
        -CabinLength/2,-CabinWidth/2,GunwaleHeight
        -CabinLength/2,CabinWidth/2,GunwaleHeight];

    
Tri=delaunay(Points(:,1),Points(:,2));
Color=[3 3 3 3 2 2 4 4 1 1 2 2 4 4];
trisurf(Tri,Points(:,1),Points(:,2),Points(:,3),Color)
title('Boat (in)')
set(gca,'DataAspectRatio',[1,1,1])
xlabel('x')
ylabel('y')
zlabel('z')



