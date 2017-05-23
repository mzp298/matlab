clc;
clear;
close all;
% steel 10HNAP data from Jabbado thesis
%-------------------------------------------------bending--------------------------------
y=1080e6;
k=800e6;
E=215e9;
nu=0.3;                     %poisson's ratio
a=0.1;
W0=2e9;
lam=3.7;
b=4.6;
fb=b;
m=1e6.*[75 150 225 300];%mean tension
marker=['o' 'p' '^' '+'];
linestyle=['-' '--' ':' '-.'];
color=[[208 32 144]/255; [255 140 0]/255; [255 215 0]/255; [0 139 139]/255];
%---------------a b correspond to high and low bounds of cyclic load, 1 2
%correspond to  different parameters comparison------------------
NF=[1.00E+05 2.00E+05 3.00E+05 4.00E+05 5.00E+05 6.00E+05  7.00E+05 8.00E+05 9.00E+05 1.00E+06] ;
stressben=1e6.*[311.30 289.36 276.53 267.43 260.37 254.60 249.72 245.49 241.77 238.43;...
281.77 267.18 258.64 252.58 247.89 244.05 240.80 237.99 235.51 233.29; ...
257.98 242.47 233.40 226.96 221.97 217.89 214.44 211.46 208.82 206.47;...
251.82 224.42 208.40 197.03 188.21 181.00 174.91 169.63 164.97 160.81];%to get Smaxben
n=1;
i=1;
for i=1:4;
for n=1:length(stressben)
hydro=1/3*sum(stressben(i,n)+m(i) +0+0);
dev1=[stressben(i,n)+m(i) 0 0 ;0 0 0 ;0 0 0 ]-hydro*eye(3);
Smaxben(i,n)=norm(dev1,'fro');
%--------to get average smin--------
hydromax=1/3.*(stressben(i,n)+m(i));
yieldmin=y-lam.*hydromax;
sminmin=yieldmin.*Smaxben(i,n).^-1;

hydromin=1/3.*(-stressben(i,n)+m(i));
yieldmax=y-lam.*hydromin;
sminmax=yieldmax.*Smaxben(i,n).^-1;

yieldm=(yieldmin+yieldmax)/2;
alphamax=(1-a.*(sminmax-1).^-fb);
alphamin=(1-a.*(sminmin-1).^-fb);
alpm_ben(i,n)=(alphamax+alphamin)/2;
%--------use average smin to get NF--------
NFben_num(i,n)=(1-alpm_ben(i,n)).^-1*W0*E*(E+k*nu)*b*(b+1)*((4*(E-k)*(1+nu)*(b-1)))^-1.*yieldm.^(b-1).*Smaxben(i,n).^(-b-1);
n=n+1;
end
figure(1);
hold on;
ben_exp(i)=semilogx(NF,Smaxben(i,:),marker(i),'MarkerSize',12,'LineWidth', 3,'MarkerEdgeColor',color(i,:), 'MarkerFaceColor','none');
NFben_num(i,:)=(1-alpm_ben(i,:)).^-1*W0*E*(E+k*nu)*b*(b+1)*((4*(E-k)*(1+nu)*(b-1)))^-1.*yieldm.^(b-1).*Smaxben(i,:).^(-b-1);
ben_num(i)=semilogx(NFben_num(i,:),Smaxben(i,:),linestyle(i),'color',color(i,:),'LineWidth', 3);
figure(2);
err_ben_m(i) = loglog(NF,NFben_num(i,:),marker(i),'MarkerSize',12,'LineWidth', 3,'MarkerEdgeColor',color(i,:), 'MarkerFaceColor','none');
hold on;
i=i+1;
end
%% 

figure(1);
set(gca ,'FontSize',30);
hXLabel = xlabel('NF_{num}','Fontsize',30, 'FontWeight' , 'bold');
hYLabel = ylabel('S_{max}','Fontsize',30, 'FontWeight' , 'bold');
hLegend=legend([ben_exp(1),ben_exp(2),ben_exp(3),ben_exp(4),ben_num(1),ben_num(2),ben_num(3),ben_num(4)],...
    'Bending experimental result with \sigma_m=75 MPa','Bending experimental result with \sigma_m=150 MPa',...
    'Bending experimental result with \sigma_m=225 MPa','Bending experimental result with \sigma_m=300 MPa',...
    'Bending numerical result with \sigma_m=75 MPa','Bending numerical result with \sigma_m=150 MPa',...
    'Bending numerical result with \sigma_m=225 MPa','Bending numerical result with \sigma_m=300 MPa',...
'location','bestoutside');
set(hLegend, 'FontSize', 18);
set(hLegend,'Box','on');
set(hLegend,'EdgeColor',[1 1 1]); %set the edge colour of the legend to white 
% Adjust font
set(gca, 'FontName', 'Helvetica')
% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'XGrid', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
    'LineWidth', 1)
set(gcf,'color','w'); %set figure background transparent
set(gca,'color','w'); %set axis transparent
% Maximize print figure
set(gcf,'outerposition',get(0,'screensize'));
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'points'); %[ {inches} | centimeters | normalized | points ]
set(gcf, 'PaperPosition', [0 0 1800 1000]); %set(gcf,'PaperPosition',[left,bottom,width,height])

%% 
figure(2);
set(gca ,'FontSize',30);
hXLabel = xlabel('NF_{exp}','Fontsize',30, 'FontWeight' , 'bold');
hYLabel = ylabel('NF_{num}','Fontsize',30, 'FontWeight' , 'bold');
x=1e4:1e5:1e8;
y0=x;
hold on;
py0=loglog(x,y0,'k','LineWidth',3);
y1=2.*x;
y2=0.5.*x;
py1=loglog(x,y1, '--k','LineWidth',3);
py2=loglog(x,y2, '--k','LineWidth',3);
axis equal;
axis([1e4 1e7 1e4 1e7]);
set(gca,'xtick',[1e4 1e5 1e6 1e7]); 
set(gca,'ytick',[1e4 1e5 1e6 1e7]); 
hLegend=legend([err_ben_m(1),err_ben_m(2),err_ben_m(3),err_ben_m(4),],...
    'Bending test with mean stress \sigma_m=75 MPa on 10HNAP','Bending test with mean stress \sigma_m=150 MPa on 10HNAP',...
'Bending test with mean stress \sigma_m=225 MPa on 10HNAP','Bending test with mean stress \sigma_m=300 MPa on 10HNAP',...
'location','bestoutside');
set(hLegend, 'FontSize', 18);
set(hLegend,'Box','on');
set(hLegend,'EdgeColor',[1 1 1]); %set the edge colour of the legend to white 
% Adjust font
set(gca, 'FontName', 'Helvetica')
% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'XGrid', 'on',...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
    'LineWidth', 1)
set(gcf,'color','w'); %set figure background transparent
set(gca,'color','w'); %set axis transparent
% Maximize print figure
set(gcf,'outerposition',get(0,'screensize'));
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'points'); %[ {inches} | centimeters | normalized | points ]
set(gcf, 'PaperPosition', [0 0 1800 1000]); %set(gcf,'PaperPosition',[left,bottom,width,height])
% figure(1);
% saveas(gcf,'F:\Git\Anew\figures\b1D_m_10HNAP_sn.png');
% figure(2);
% saveas(gcf,'F:\Git\Anew\figures\b1D_m_10HNAP_err1.png');

sp=actxserver('SAPI.SpVoice');
sp.Speak('done done done');
% figure(2);
% plot(alpm_ben,'b')
% hold on 
% plot(Smaxben,'b')

