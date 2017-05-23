
% Program to get the Gauss-Legendre Quadrature results (Vectorized)
clear;clc;

dbstop if error
format long e

[x]= [0.999305042	0.996340117	0.991013371	0.983336254	0.973326828	0.9610088	0.946411375	0.929569172	0.910522137...
    0.889315446	0.865999398	0.840629296	0.813265315	0.783972359	0.752819907	0.71988185	0.685236313	0.648965471...
    0.611155355	0.571895646	0.531279464	0.489403146	0.446366017	0.402270158	0.357220158	0.311322872	0.264687162...
    0.217423644	0.16964442	0.121462819	0.072993122	0.024350293	-0.024350293	-0.072993122	-0.121462819	-0.16964442...
    -0.217423644	-0.264687162	-0.311322872	-0.357220158	-0.402270158	-0.446366017	-0.489403146	-0.531279464...
    -0.571895646	-0.611155355	-0.648965471	-0.685236313	-0.71988185	-0.752819907	-0.783972359	-0.813265315...
    -0.840629296	-0.865999398	-0.889315446	-0.910522137	-0.929569172	-0.946411375	-0.9610088	-0.973326828...
    -0.983336254	-0.991013371	-0.996340117	-0.999305042];
[weight]=[0.001783281	0.004147033	0.006504458	0.00884676	0.011168139	0.013463048	0.01572603	0.017951716	0.020134823...
    0.022270174	0.024352703	0.02637747	0.028339673	0.030234657	0.032057928	0.033805162	0.035472213	0.037055129	0.038550153...
    0.039953741	0.041262563	0.042473515	0.043583725	0.044590558	0.045491628	0.046284797	0.046968183	0.047540166	0.047999389...
    0.048344762	0.048575467	0.048690957	0.048690957	0.048575467	0.048344762	0.047999389	0.047540166	0.046968183	0.046284797...
    0.045491628	0.044590558	0.043583725	0.042473515	0.041262563	0.039953741	0.038550153	0.037055129	0.035472213	0.033805162...
    0.032057928	0.030234657	0.028339673	0.02637747	0.024352703	0.022270174	0.020134823	0.017951716	0.01572603	0.013463048...
    0.011168139	0.00884676	0.006504458	0.004147033	0.001783281];
% [x]=xlsread('Gauss-Legendre Quadrature','Sheet1','b1:z1');
% [weight]=xlsread('Gauss-Legendre Quadrature','Sheet1','b2:z2');

E=191e9;               %Young's modulus
nu=0.38;                 %poisson's ratio
k=1e9;                  %hardening parameter
b=1.5;                      %weakening scales distribution exponent (between 1 and 2)
y=1080e6;            %macroscopic yield stress
sigu=1200e6;             %ultimite stress
ff=690e6;              %bending fatigue limit
tt=428e6;                  %torsion fatigue limit

gam=b+1;              %material parameter from Chaboche law(Wohler curve exponent)

load=5e8;            %cyclic load
loadtensor= [load 0 0;0 0 0;0 0 0];
stepnumber=32;        %devide one cycle in 200 parts
f=50;                            %frequency of load
steptime=1/f/stepnumber;
delta=(b+1)/(b-1);
alp=0.5;
WF=5e8;             %dissipated energy to failure per unit volume
n0=3;                   %number of initial local defects
lam=0.3;               %hydrostatic pressure sensitivity
m=3e8;                   % mean stress
hydrofix=1/3*(sum(diag(loadtensor))); 
dev=loadtensor-hydrofix*eye(3); %mean stress does not change deviatoric stress!!!!!!!!

%---------------------Plot 3 methods-----------------------------
%---------------------1 Chaboche method-----------------------------
Dcha(1)=0;             %initial damage
n=1;       %initial recording point
G = (1 - (1 - Dcha(1)).^(gam + 1)).^(1-alp);
M=5.019*ff*(1-3*hydrofix/sigu); %chaboche mean stress
sqrj1=1/2*sqrt(1/2)*norm(dev,'fro');
while G<1
    NF=1/((gam+1)*(1-alp))*(sqrj1/M)^(-gam);
    G = G+(1-alp)*(gam + 1)/stepnumber/NF; %increament at each step
    Dcha(n+1)=1-(1-G.^(1/(1-alp))).^(1/(gam + 1));
    %   t=n/stepnumber*1/f;
    n=n+1;
end
n
figure(1);
hold on;
DamageCha=plot ((1:n).*stepnumber^-1,Dcha(1:n), 'LineStyle', 'none','LineWidth', 1.2, 'Marker', 'o', 'MarkerSize', 10, ...
    'MarkerEdgeColor',  'g', 'MarkerFaceColor','none');

%---------------------2 Cyclic load calculation-----------------------------
Dcyc(1)=0;
n=1;
Gcyc = (1 - (1 - Dcyc(1)).^(gam + 1)).^(1-alp);
Smax=norm(dev,'fro'); 
yield=y-lam*1/3*m; %mean value of hydro is 1/3*m
Wcyc=4*(E-k)*(1+nu)*(b-1)/(E*(E+k*nu)*b*(b+1))*Smax.^(b+1)*yield.^(1-b) ;
while Gcyc< 1
    Gcyc = Gcyc+n0*(1-alp)*(gam + 1)*Wcyc/stepnumber/WF; %increament at each step
    Dcyc(n+1)=1-(1-Gcyc^(1/(1-alp)))^(1/(gam + 1));
    n=n+1;
end
n
hold on;
Damagecyc=plot ((1:n).*stepnumber^-1,Dcyc(1:n),'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 8, ...
    'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'b');

%---------------------3 Numerical method-----------------------------
D=0;
G = (1 - (1 - D).^(gam + 1)).^(1-alp);
D= zeros(1,1e6); %Pre-allocate memory for vectors
n=1;       %initial recording point
%---------------------to get the the first Sb-----------------------------
stress11=m+load*sind(n*360/stepnumber);
hydro=1/3*sum(stress11+0+0); %mean value of hydro is 1/3*m
yield=y-lam*hydro; 
dev1=[stress11 0 0 ;0 0 0 ;0 0 0 ]-hydro*eye(3);
dev11=dev1(1,1); dev12=dev1(1,3); dev13=dev1(1,3);
dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
Smax=norm(dev1,'fro');
s= (x/2+1/2).^(1/(1-b)); %1*64

trial11=dev11; trial12=dev12; trial13=dev13;
trial21=dev21; trial22=dev22; trial23=dev23;
trial31=dev31; trial32=dev32; trial33=dev33;

normtrial(1)=norm([trial11, trial12, trial13; trial21, trial22, trial23;trial31, trial32, trial33],'fro');

eta=bsxfun(@minus,bsxfun(@times,normtrial(1)/yield,s),1); %compare normtrial with yield/s
eta(eta<0)=0; %only keep normtrials which are larger than yield/s

Sb11=bsxfun(@rdivide,trial11,bsxfun(@plus,eta,1));Sb12=bsxfun(@rdivide,trial12,bsxfun(@plus,eta,1));Sb13=bsxfun(@rdivide,trial13,bsxfun(@plus,eta,1));
Sb21=bsxfun(@rdivide,trial21,bsxfun(@plus,eta,1));Sb22=bsxfun(@rdivide,trial22,bsxfun(@plus,eta,1));Sb23=bsxfun(@rdivide,trial23,bsxfun(@plus,eta,1));
Sb31=bsxfun(@rdivide,trial31,bsxfun(@plus,eta,1));Sb32=bsxfun(@rdivide,trial32,bsxfun(@plus,eta,1));Sb33=bsxfun(@rdivide,trial33,bsxfun(@plus,eta,1));
%1*64 for each Sb element
Sbtensor=[Sb11; Sb12; Sb13; Sb21; Sb22; Sb23;Sb31; Sb32; Sb33];
normSb=sqrt(sum(Sbtensor.^2)); %sum(a) sums all the colume

% existsOnGPU(normSb)
Ws=(bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s))<=0).*...
    (0)+...
    (bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s))>0).*...
    ((E-k)*(1+nu)*(2*E*(E+k*nu))^-1*bsxfun(@times,weight,bsxfun(@rdivide,bsxfun(@times,bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s)),yield),s)));

W= sum(Ws);
G = G+n0*(1-alp)*(gam + 1)*W/WF;
D(1)=1-(1-G.^(1/(1-alp))).^(1/(gam + 1));
%%

tic;
while G<1
    stress11=m+load*sind(n*360/stepnumber);
    hydro=1/3*sum(stress11+0+0);
    yield=y-lam*hydro;
    dev1=[stress11 0 0 ;0 0 0 ;0 0 0 ]-hydro*eye(3);
    dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);
    dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
    dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
    
    stress11=m+load*sind((n+1)*360/stepnumber);
    hydro=1/3*sum(stress11+0+0);
    devn=[stress11 0 0;0 0 0;0 0 0]-hydro*eye(3);
    dev11g=devn(1,1); dev12g=devn(1,2); dev13g=devn(1,3);
    dev21g=devn(2,1); dev22g=devn(2,2); dev23g=devn(2,3);
    dev31g=devn(3,1); dev32g=devn(3,2); dev33g=devn(3,3);
    Smax=norm(devn,'fro');
    
    trial11=bsxfun(@plus,Sb11,(dev11g-dev11)); trial12=bsxfun(@plus,Sb12,(dev12g-dev12));trial13=bsxfun(@plus,Sb13,(dev13g-dev13));
    trial21=bsxfun(@plus,Sb21,(dev21g-dev21)); trial22=bsxfun(@plus,Sb22,(dev22g-dev22));trial23=bsxfun(@plus,Sb23,(dev23g-dev23));
    trial31=bsxfun(@plus,Sb31,(dev31g-dev31)); trial32=bsxfun(@plus,Sb32,(dev32g-dev32));trial33=bsxfun(@plus,Sb33,(dev33g-dev33));
    trialtensor=[trial11; trial12; trial13; trial21; trial22; trial23;trial31; trial32; trial33];
    normtrial=sqrt(sum(trialtensor.^2));

    eta=bsxfun(@minus,bsxfun(@times,normtrial/yield,s),1); %1*64
    eta(eta<0)=0;
    
    Sb11=bsxfun(@rdivide,trial11,bsxfun(@plus,eta,1));Sb12=bsxfun(@rdivide,trial12,bsxfun(@plus,eta,1));Sb13=bsxfun(@rdivide,trial13,bsxfun(@plus,eta,1));
    Sb21=bsxfun(@rdivide,trial21,bsxfun(@plus,eta,1));Sb22=bsxfun(@rdivide,trial22,bsxfun(@plus,eta,1));Sb23=bsxfun(@rdivide,trial23,bsxfun(@plus,eta,1));
    Sb31=bsxfun(@rdivide,trial31,bsxfun(@plus,eta,1));Sb32=bsxfun(@rdivide,trial32,bsxfun(@plus,eta,1));Sb33=bsxfun(@rdivide,trial33,bsxfun(@plus,eta,1));
    %1*64 for each Sb element
    Sbtensor=[Sb11; Sb12; Sb13; Sb21; Sb22; Sb23;Sb31; Sb32; Sb33];
    normSb=sqrt(sum(Sbtensor.^2)); %sum(a) sums all the colume
    
    Ws=(bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s))<=0).*...
        (0)+...
        (bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s))>0).*...
        ((E-k)*(1+nu)*(2*E*(E+k*nu))^-1*bsxfun(@times,weight,bsxfun(@rdivide,bsxfun(@times,bsxfun(@minus,normtrial,bsxfun(@rdivide, yield,s)),yield),s)));
    
    W= sum(Ws);
    G = G+n0*(1-alp)*(gam + 1)*W/WF;
    D(n+1)=1-(1-G.^(1/(1-alp))).^(1/(gam + 1));
    
    %     figure(2);
    %         hold on;
    %         yield1=plot (n+1,yield*s(33).^-1, 'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 8, ...
    %             'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'c');
    %         yield1n= plot (n+1,-yield*s(33).^-1, 'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 8, ...
    %             'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'c');
    %         Trial1=plot (n+1,sign(trial11(33))*normtrial(33),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize', 10, ...
    %             'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    %         Sb1=plot (n+1,sign(Sb11(33))*normSb(33),'LineStyle', 'none','LineWidth', 1,'Marker', 'v', 'MarkerSize', 10, ...
    %             'MarkerEdgeColor','g', 'MarkerFaceColor','g');
    %             dev=plot (n+1,sign(sind((n+1)*360/stepnumber))*Smax,'LineStyle', 'none','LineWidth', 1,'Marker', 's', 'MarkerSize', 11, ...
    %                 'MarkerEdgeColor','none', 'MarkerFaceColor',[238 18 137]/255);
    %         yield8=plot (n+1,yield*s(40).^-1,'LineStyle', 'none','LineWidth', 1,'Marker', 'o', 'MarkerSize', 8, ...
    %             'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'b');
    %                 yield8n=plot (n+1,-yield*s(40).^-1,'LineStyle', 'none','LineWidth', 1,'Marker', 'o', 'MarkerSize', 8, ...
    %             'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'b');
    %         Trial8=plot (n+1,sign(trial11(40))*normtrial(40),'LineStyle', 'none','LineWidth', 1,'Marker', '^', 'MarkerSize', 10, ...
    %             'MarkerEdgeColor', [1 0.5 0], 'MarkerFaceColor',[1 0.5 0]);
    %         Sb8=plot (n+1,sign(Sb11(40))*normSb(40),'LineStyle', 'none','LineWidth', 1,'Marker', 'v', 'MarkerSize', 10, ...
    %             'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    
    n=n+1;
end
toc;
n
t=n/stepnumber*1/f;
disp(['Time to failure is ' num2str(t) ' s.']);
Nf=n*stepnumber^-1;
disp(['Cycles to failure is ' num2str(Nf) ' cycles.']);


% %---------------------Plot 3 methods damage evo-----------------------------
figure(1);
hold on;
DamageN=plot ((1:n).*stepnumber^-1,D(1:n),'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 6, ...
    'MarkerEdgeColor',  'none', 'MarkerFaceColor' , 'm');
% %---------------------3 methods damage evolution plot settings-----------------------------
grid on;
grid minor;
hTitle = title('Damage evolution comparison of three methods' ,'Fontsize' ,35);
hXLabel = xlabel('Number of cycles' ,'Fontsize' ,35);
hYLabel = ylabel('Damage', 'Fontsize' ,35);
hLegend=legend([DamageN,DamageCha,Damagecyc],'Numerical method','Chaboche method',...
    'Cyclic load calculation','Location','best');
set([hLegend, gca], 'FontSize', 25)
set(hLegend,'Box','on');
set(hLegend,'EdgeColor',[1 1 1]); %set the edge colour of the legend to white

% Adjust font
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
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
% saveas(gcf,'F:\Git\Anew\figures\damagesin.png');


% % %---------------------in loop 2 scales plot settings-----------------------------
% figure(2);
% grid on;
% grid minor;
% set(gca ,'FontSize',30);
% hXLabel = xlabel('Time step(1/200 s)' ,'Fontsize' ,30);
% hYLabel = ylabel('Stress(Pa)', 'Fontsize' ,30);
% hTitle = title('Microscopic stress evolution at 2 scales' ,'Fontsize' ,30);
% set(hTitle, 'FontSize', 30, 'FontWeight' , 'bold')
% hLegend=legend([dev,yield1,Sb1,Trial1,yield8,Sb8,Trial8],'S_{max}=dev\Sigma','(\sigma_y-\lambda\Sigma_H)/s_{33}     at scale s_{33}','||S-b||                at scale s_{33}',...
%     '||S-b||_{trial}           at scale s_{33}', '(\sigma_y-\lambda\Sigma_H)/s_{40}     at scale s_{40}',...
%     '||S-b||                at scale s_{40}','||S-b||_{trial}           at scale s_{40}','Location','Best');
% set([hLegend, gca], 'FontSize', 20)
% set(hLegend,'Box','on');
% set(hLegend,'EdgeColor',[1 1 1]); %set the edge colour of the legend to white
% % Adjust font
% set(gca, 'FontName', 'Helvetica')
% set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
% % Adjust axes properties
% set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
%     'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
%     'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
%     'LineWidth', 1)
% set(gcf,'color','w'); %set figure background transparent
% set(gca,'color','w'); %set axis transparent
% % Maximize print figure
% set(gcf,'outerposition',get(0,'screensize'));
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'points'); %[ {inches} | centimeters | normalized | points ]
% set(gcf, 'PaperPosition', [0 0 1920 1080]); %set(gcf,'PaperPosition',[left,bottom,width,height])
% % saveas(gcf,'F:\Git\Anew\figures\trialsin.png');
%



% % %---------------------Difference between cyclic load calculation and numerical method as function of time-----------------------------
% figure(3);
%      hold on
%      Damagediff=plot ((Dcyc(1:n-600)-D(1:n-600)).*Dcyc(1:n-600).^-1,'LineStyle', 'none','LineWidth', 1, 'Marker', 'o', 'MarkerSize', 6, ...
%        'MarkerEdgeColor',  'k', 'MarkerFaceColor' , 'k');
% grid on;
% grid minor;
% set(gca ,'FontSize',25);
% hTitle = title('Relative difference between cyclic load calculation and numerical method' ,'Fontsize' ,35);
% hXLabel = xlabel('Number of steps' ,'Fontsize' ,30);
% hYLabel = ylabel('Relative difference', 'Fontsize' ,30);
% % Adjust font
% set(gca, 'FontName', 'Helvetica')
% set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
% % Adjust axes properties
% set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
%     'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
%     'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
%     'LineWidth', 1)
% set(gcf,'color','w'); %set figure background transparent
% set(gca,'color','w'); %set axis transparent
% % Maximize print figure
% set(gcf,'outerposition',get(0,'screensize'));
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'points'); %[ {inches} | centimeters | normalized | points ]
% set(gcf, 'PaperPosition', [0 0 1920 1080]); %set(gcf,'PaperPosition',[left,bottom,width,height])
% %   saveas(gcf,'F:\Git\Anew\figures\Damagediff.png');



%sp=actxserver('SAPI.SpVoice');
% sp.Speak('Fuck that I finished all this shit finally');
%mail2me('job finished',['Elapsed time is ' num2str(toc) ' seconds. Real test time is ' testtime ' seconds. Number of points to failure is ' NF ' points.']);

