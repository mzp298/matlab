clear;clc;
dbstop if error
format long e

load('FX_RAVG.mat');
signal.data=double(signal.data);
forcex= transpose(signal.data);
load('FY_RAVG.mat');
signal.data=double(signal.data);
forcey= transpose(signal.data);
load('FZ_RAVG.mat');
signal.data=double(signal.data);
forcez= transpose(signal.data);
copy=3;
forcex=repmat(forcex,copy,1);
forcey=repmat(forcey,copy,1);
forcez=repmat(forcez,copy,1);

%---------------------Arithmetic sequence between every recorded points---------------------
ari=2; %insert (ari-1) points between the two limits
for i=2:(copy*802805)
    %force(1+ari*(i-1):1+ari*i)=linspace(forceorigin(i),forceorigin(i+1),ari+1);
    forcelx(1+ari*(i-2):1+ari*(i-1))=linspace(forcex(i-1),forcex(i),ari+1);
    forcely(1+ari*(i-2):1+ari*(i-1))=linspace(forcey(i-1),forcey(i),ari+1);
    forcelz(1+ari*(i-2):1+ari*(i-1))=linspace(forcez(i-1),forcez(i),ari+1);
end;
%  ari*(i-1)+1 ;%the number of points

%------------------------build the stress tensor---------------------
A=6.45e-5;
% A=1/6e4;
cx=10;
cy=60;
thetax=0.5;
thetay=0.6;
phix=0.3;
phiy=0.4;
stress11=1/A*(forcelz+cx*forcelx*cos(thetax)^2+cy*forcely*cos(thetay)^2);
stress12=1/A*(cx*forcelx*cos(thetax)*sin(thetax)*cos(phix)+cy*forcely*cos(thetay)*sin(thetay)*cos(phiy));
stress13=1/A*(cx*forcelx*cos(thetax)*sin(thetax)*sin(phix)+cy*forcely*cos(thetay)*sin(thetay)*sin(phiy));
stress21=stress12;
stress22=1/A*(cx*forcelx*sin(thetax)^2*cos(phix)^2+cy*forcely*sin(thetay)^2*cos(phiy)^2);
stress23=1/A*(cx*forcelx*sin(thetax)^2*cos(phix)*sin(phix)+cy*forcely*sin(thetay)^2*cos(phiy)*sin(phiy));
stress31=stress13;
stress32=stress23;
stress33=1/A*(cx*forcelx*sin(thetax)^2*sin(phix)^2+cy*forcely*sin(thetay)^2*sin(phiy)^2);
% [max(stress11) max(stress12) max(stress13);
% max(stress12) max(stress22) max(stress23);
% max(stress23) max(stress13) max(stress33);]
% [mean(stress11) mean(stress12) mean(stress13);
% mean(stress12) mean(stress22) mean(stress23);
% mean(stress23) mean(stress13) mean(stress33);]

x= [-0.99555697 -0.976663921 -0.942974571 -0.894991998 -0.833442629 -0.759259263 -0.673566368...
    -0.57766293 -0.473002731 -0.361172306 -0.243866884 -0.122864693 0 0.122864693 0.243866884 0.361172306...
    0.473002731 0.57766293 0.673566368 0.759259263 0.833442629 0.894991998 0.942974571 0.976663921...
    0.99555697];
weight=[0.011393799	0.026354987	0.040939157	0.054904696	0.068038334	0.0801407	0.091028262...
    0.100535949	0.108519624	0.114858259	0.119455764	0.122242443	0.123176054	0.122242443	0.119455764...
    0.114858259	0.108519624	0.100535949	0.091028262	0.0801407	0.068038334	0.054904696	0.040939157...
    0.026354987	0.011393799];
% x=xlsread('Gauss-Legendre Quadrature','Sheet1','b1:z1');
% weight=xlsread('Gauss-Legendre Quadrature','Sheet1','b2:z2');
y=6.38e8;           %macroscopic yield stress
lam=0.5;             %hydrostatic pressure sensitivity
E=2e11;              %Young��s modulus
k=6e8;                 %hardening parameter
b=3;                    %weakening scales distribution exponent
nu=0.3;                     %poisson's ratio
tt=2e8;                 %torsion fatigue limit
ff=2.5e8;              %bending fatigue limit
ac=(tt-ff/sqrt(3))/(ff/3); %crossland criterial constant
bc=tt;                     %crossland criterial constant
sigu=8e8;             %ultimite stress
gam=0.5;                %material parameter from Chaboche law(Wohler curve exponent)
samplerate=256;   %recorded samples per second


%---------------------Vecterization-----------------------------

WF=3e6;             %dissipated energy to failure per unit volume
alp=0.8;
D=0;             %initial damage
n=1;                      %initial recording point
step=1/samplerate/ari;
t=n*step;
G = (1 - (1 - D).^(gam + 1)).^(1-alp);
yield = zeros(size(forcelx)); %Pre-allocate memory for vector
D = yield;
normSb = zeros(length(forcelx),length(x));
normtrial = normSb;

%---------------------to get the the first Sb-----------------------------
m=1/3*sum(stress11(1)+stress22(1)+stress33(1));
yield(1)=y-lam*m; %macro yield strength considering mean stress effect
dev1=[stress11(1) stress12(1) stress13(1);stress21(1) stress22(1) stress23(1);stress31(1) stress32(1) stress33(1)]-m*eye(3);
dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);
dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);

trial11=dev11; trial12=dev12; trial13=dev13;
trial21=dev21; trial22=dev22; trial23=dev23;
trial31=dev31; trial32=dev32; trial33=dev33;
trialtensor=[trial11; trial12; trial13; trial21; trial22; trial23;trial31; trial32; trial33];
normtrial(1,1:length(x))=sqrt(sum(trialtensor.^2));
s= (x/2+1/2).^(1/(1-b)); %1*25
eta=bsxfun(@minus,bsxfun(@times,normtrial(1,1:length(x))/yield(1),s),1); %1*25
eta(eta<0)=0;

Sb11=bsxfun(@rdivide,trial11,bsxfun(@plus,eta,1));Sb12=bsxfun(@rdivide,trial12,bsxfun(@plus,eta,1));Sb13=bsxfun(@rdivide,trial13,bsxfun(@plus,eta,1));
Sb21=bsxfun(@rdivide,trial21,bsxfun(@plus,eta,1));Sb22=bsxfun(@rdivide,trial22,bsxfun(@plus,eta,1));Sb23=bsxfun(@rdivide,trial23,bsxfun(@plus,eta,1));
Sb31=bsxfun(@rdivide,trial31,bsxfun(@plus,eta,1));Sb32=bsxfun(@rdivide,trial32,bsxfun(@plus,eta,1));Sb33=bsxfun(@rdivide,trial33,bsxfun(@plus,eta,1));
%1*25 for each Sb element
Sbtensor=[Sb11; Sb12; Sb13; Sb21; Sb22; Sb23;Sb31; Sb32; Sb33];
normSb(1,:)=sqrt(sum(Sbtensor.^2));
Ws=(bsxfun(@minus,normtrial(1,1:length(x)),bsxfun(@rdivide, yield(1),s))<=0).*...
    (0)+...
    (bsxfun(@minus,normtrial(1,1:length(x)),bsxfun(@rdivide, yield(1),s))>0).*...
    ((E-k)*(1+nu)/(2*E*(E+k*nu))*bsxfun(@times,weight,bsxfun(@rdivide,bsxfun(@times,bsxfun(@minus,normtrial(1,1:length(x)),bsxfun(@rdivide, yield(1),s)),yield(1)),s)));
W= sum(Ws);
G = G+W/WF; %1.322163316411401e-03
D(1)=1-(1-G.^(1/(1-alp))).^(1/(gam + 1));

tic;
while G<0.1
    m=1/3*sum(stress11(n)+stress22(n)+stress33(n));
    dev1=[stress11(n) stress12(n) stress13(n);stress21(n) stress22(n) stress23(n);stress31(n) stress32(n) stress33(n)]-m*eye(3);
    dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);
    dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
    dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
    
    m=1/3*sum(stress11(n+1)+stress22(n+1)+stress33(n+1));
    yield(n+1)=y-lam*m; %macro yield strength considering mean stress effect
    yield(yield<0)=0;
    devn=[stress11(n+1) stress12(n+1) stress13(n+1);stress21(n+1) stress22(n+1) stress23(n+1);stress31(n+1) stress32(n+1) stress33(n+1)]-m*eye(3);
    dev11g=devn(1,1); dev12g=devn(1,2); dev13g=devn(1,3);
    dev21g=devn(2,1); dev22g=devn(2,2); dev23g=devn(2,3);
    dev31g=devn(3,1); dev32g=devn(3,2); dev33g=devn(3,3);
    
    trial11=bsxfun(@plus,Sb11,(dev11g-dev11)); trial12=bsxfun(@plus,Sb12,(dev12g-dev12));trial13=bsxfun(@plus,Sb13,(dev13g-dev13));
    trial21=bsxfun(@plus,Sb21,(dev21g-dev21)); trial22=bsxfun(@plus,Sb22,(dev22g-dev22));trial23=bsxfun(@plus,Sb23,(dev23g-dev23));
    trial31=bsxfun(@plus,Sb31,(dev31g-dev31)); trial32=bsxfun(@plus,Sb32,(dev32g-dev32));trial33=bsxfun(@plus,Sb33,(dev33g-dev33));
    trialtensor=[trial11; trial12; trial13; trial21; trial22; trial23;trial31; trial32; trial33];
    normtrial(n+1,:)=sqrt(sum(trialtensor.^2));
    eta=bsxfun(@minus,bsxfun(@times,normtrial(n+1,:)/yield(n+1),s),1); %1*25
    eta(eta<0)=0;
    
    Sb11=bsxfun(@rdivide,trial11,bsxfun(@plus,eta,1));Sb12=bsxfun(@rdivide,trial12,bsxfun(@plus,eta,1));Sb13=bsxfun(@rdivide,trial13,bsxfun(@plus,eta,1));
    Sb21=bsxfun(@rdivide,trial21,bsxfun(@plus,eta,1));Sb22=bsxfun(@rdivide,trial22,bsxfun(@plus,eta,1));Sb23=bsxfun(@rdivide,trial23,bsxfun(@plus,eta,1));
    Sb31=bsxfun(@rdivide,trial31,bsxfun(@plus,eta,1));Sb32=bsxfun(@rdivide,trial32,bsxfun(@plus,eta,1));Sb33=bsxfun(@rdivide,trial33,bsxfun(@plus,eta,1));
    %1*25 for each Sb element
    Sbtensor=[Sb11; Sb12; Sb13; Sb21; Sb22; Sb23;Sb31; Sb32; Sb33];
    
    normSb(n+1,:)=sqrt(sum((Sbtensor.^2)));
    
    Ws=(bsxfun(@minus,normtrial(n+1,:),bsxfun(@rdivide, yield(n+1),s))<=0).*...
        (0)+...
        (bsxfun(@minus,normtrial(n+1,:),bsxfun(@rdivide, yield(n+1),s))>0).*...
        ((E-k)*(1+nu)/(2*E*(E+k*nu))*bsxfun(@times,weight,bsxfun(@rdivide,bsxfun(@times,bsxfun(@minus,normtrial(n+1,:),bsxfun(@rdivide, yield(n+1),s)),yield(n+1)),s)));
    W= sum(Ws);
    G = G+W/WF;
    D(n+1)=1-(1-G.^(1/(1-alp))).^(1/(gam + 1));
    t=n*step;
%            hold on;
%         yield1=plot (n,yield(n)*s(1).^-1, 'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 10, ...
%             'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'c');
%         Trial1=plot (n,normtrial(n,1),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize', 10, ...
%             'MarkerEdgeColor','r', 'MarkerFaceColor','r');
%         Sb1=plot (n,normSb(n,1),'LineStyle', 'none','LineWidth', 1,'Marker', 'v', 'MarkerSize', 10, ...
%             'MarkerEdgeColor','g', 'MarkerFaceColor','g');
%         yield8=plot (n,yield(n)*s(8).^-1,'LineStyle', 'none','LineWidth', 1,'Marker', 'o', 'MarkerSize', 10, ...
%             'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'b');
%         Trial8=plot (n,normtrial(n,8),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize',10, ...
%             'MarkerEdgeColor', [1 0.5 0], 'MarkerFaceColor',[1 0.5 0]);
%         Sb8=plot (n,normSb(n,8),'LineStyle', 'none','LineWidth', 1,'Marker', 'v', 'MarkerSize', 10, ...
%             'MarkerEdgeColor','k', 'MarkerFaceColor','k');

    
    % DamageN=plot (t,D,'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize',10, ...
    %    'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'r');
    n=n+1;
end;
toc;
disp(['Number of test points is ' num2str(n/ari+1) ' points.']);
disp(['Number of test time is ' num2str(t) ' points.']);
testtime=num2str(t)
sp=actxserver('SAPI.SpVoice');
sp.Speak('I finished all the work finally. oh la la');

 hold on;

  Trial8=plot ((1:n)*step,normtrial(1:n,8),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize',10, ...
    'MarkerEdgeColor','r', 'MarkerFaceColor','none');
   Sb8=plot ((1:n)*step,normSb(1:n,8),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize', 6, ...
    'MarkerEdgeColor','none', 'MarkerFaceColor',[96 96 96]/255);
  yield8=plot ((1:n)*step,yield(1:n)*s(8).^-1,'LineStyle', 'none','LineWidth', 1,'Marker', 'o', 'MarkerSize', 6, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor','b');
  Trial1=plot ((1:n)*step,normtrial(1:n,1),'LineStyle', 'none','LineWidth', 1,'Marker', 's', 'MarkerSize',10, ...
    'MarkerEdgeColor', [1 0.5 0], 'MarkerFaceColor','none');
    Sb1=plot ((1:n)*step,normSb(1:n,1),'LineStyle', 'none','LineWidth', 1,'Marker', 's', 'MarkerSize',6, ...
    'MarkerEdgeColor','none', 'MarkerFaceColor','g');
  yield1=plot ((1:n)*step,yield(1:n)*s(1).^-1, 'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 6, ...
    'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'c');

% DamageN=plot ((1:n)*step,D(1:n),'LineStyle', 'none','LineWidth', 2, 'Marker', 'o', 'MarkerSize', 10, ...
%    'MarkerEdgeColor',  'r' , 'MarkerFaceColor' ,'none');

%---------------------plot settings-----------------------------
grid on;
grid minor;
set(gca ,'FontSize',25);
hXLabel = xlabel('t(s)' ,'Fontsize' ,25);

%  hTitle =title('Damage evolution under multidimensional stress' ,'Fontsize' ,25);
%  hYLabel =ylabel('D', 'Fontsize' ,25);

hTitle = title('Microscopic stress evolution at 2 scales' ,'Fontsize' ,25);
hYLabel = ylabel('Stress(Pa)', 'Fontsize' ,25);
hLegend=legend([yield1,Sb1,Trial1,yield8,Sb8,Trial8],'(\sigma_y-\lambda\Sigma_H)/s_1     at scale s_1','||S-b||              at scale s_1',...
    '||S-b||_{trial}         at scale s_1', '(\sigma_y-\lambda\Sigma_H)/s_8     at scale s_{8}','||S-b||              at scale s_{8}','||S-b||_{trial}         at scale s_{8}');
set([hLegend, gca], 'FontSize', 25)

% Adjust font
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
set([hXLabel, hYLabel], 'FontSize', 25)
set(hTitle, 'FontSize', 25, 'FontWeight' , 'bold')

% Adjust axes properties
set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
    'LineWidth', 1)

set(gcf,'color','w'); %set figure background transparent
set(gca,'color','w'); %set axis transparent
% Maximize print figure
set(gcf,'outerposition',get(0,'screensize'));
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'points'); %[ {inches} | centimeters | normalized | points ]
set(gcf, 'PaperPosition', [0 0 1920 1080]); %set(gcf,'PaperPosition',[left,bottom,width,height])
%  saveas(gcf,'damage3d.png');
saveas(gcf,'trialreal3d.png');


% mail2me('job finished',['Elapsed time is ' num2str(toc) ' seconds. Real test time is ' testtime ' seconds. Number of test points is ' num2str(n/ari+1) ' points.']);
%
