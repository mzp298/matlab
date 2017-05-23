clc;
clear;
close all;
% steel 30 NCD 16 data from Jabbado thesis
%-------------------------------------------------bending--------------------------------
y=1080e6;
k=1e9;
E=191e9;
nu=0.3;                     %poisson's ratio
a=0.1;
W0=44e9;
lam=0.85;
b=1.85;
fb=b;
m=1e6.*[ 0 0 290 450  450 450 290];%mean tension
%---------------a b correspond to high and low bounds of cyclic load, 1 2
%correspond to  different parameters comparison------------------
Smax=4e8:1000:y;
NF=[80000 200000 120000 120000 250000 95000 120000] ;
stressben=1e6.*[600,548,0,0,0,490,500];%to get Smaxben
stresstor=1e6.*[335,306,460,460,430,285,290];%to get Smaxtor
n=1;
while n<length(stressben)+1
hydro=1/3*sum(stressben(n)+m(n) +0+0);
dev1=[stressben(n)+m(n) stresstor(n) 0 ;0 stresstor(n) 0 ;0 0 0 ]-hydro*eye(3);
Smaxbt(n)=norm(dev1,'fro');
Smaxbt_VM(n)=VM_Stress(stressben(n), 0, 0, stresstor(n), 0, 0);
%--------to get average smin--------
hydromax=1/3.*(stressben(n)+m(n));
yieldmin=y-lam.*hydromax;
sminmin=yieldmin.*Smaxbt(n).^-1;

hydromin=1/3.*(-stressben(n)+m(n));
yieldmax=y-lam.*hydromin;
sminmax=yieldmax.*Smaxbt(n).^-1;

yieldm=(yieldmin+yieldmax)/2;
alphamax=(1-a.*(sminmax-1).^-fb);
alphamin=(1-a.*(sminmin-1).^-fb);
alpm_bt(n)=(alphamax+alphamin)/2;
%--------use average smin to get NF--------
NFbt_num(n)=(1-alpm_bt(n)).^-1*W0*E*(E+k*nu)*b*(b+1)*((4*(E-k)*(1+nu)*(b-1)))^-1.*yieldm.^(b-1).*Smaxbt(n).^(-b-1);
NFbt_num_VM(n)=(1-alpm_bt(n)).^-1*W0*E*(E+k*nu)*b*(b+1)*((4*(E-k)*(1+nu)*(b-1)))^-1.*yieldm.^(b-1).*Smaxbt_VM(n).^(-b-1);
n=n+1;
end

figure(1);
smax_exp=semilogx(NF,Smaxbt,'o','MarkerSize',12,'LineWidth', 3,'MarkerEdgeColor',[208 32 144]/255, 'MarkerFaceColor','none');
hold on;
bt_num=(1-alpm_bt).^-1*W0*E*(E+k*nu)*b*(b+1)*((4*(E-k)*(1+nu)*(b-1)))^-1.*yieldm.^(b-1).*Smaxbt.^(-b-1);
smax_num=semilogx(bt_num,Smaxbt,'-r','LineWidth', 3);

set(gca ,'FontSize',30);
hXLabel = xlabel('NF_{num}','Fontsize',30, 'FontWeight' , 'bold');
hYLabel = ylabel('S_{max}','Fontsize',30, 'FontWeight' , 'bold');
hLegend=legend([smax_exp,smax_num],...
    'Bending-torsion experimental result','Bending-torsion numerical result','location','bestoutside');
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
saveas(gcf,'F:\Git\Anew\figures\bt2D_m_30NCD16_sn.png');
%% 
figure(2);
err_bt = loglog(NF,NFbt_num,'o','MarkerSize',12,'LineWidth', 3,'MarkerEdgeColor',[	139 69 19]/255, 'MarkerFaceColor','none');
hold on;
err_bt_VM = loglog(NF,NFbt_num_VM,'^','MarkerSize',12,'LineWidth', 3,'MarkerEdgeColor','c', 'MarkerFaceColor','none');
set(gca ,'FontSize',30);
hXLabel = xlabel('NF_{exp}','Fontsize',30, 'FontWeight' , 'bold');
hYLabel = ylabel('NF_{num}','Fontsize',30, 'FontWeight' , 'bold');
x=1e4:1000:1e6;
y0=x;
hold on;
py0=loglog(x,y0,'k','LineWidth',3);
y1=2.*x;
y2=0.5.*x;
py1=loglog(x,y1, '--k','LineWidth',3);
py2=loglog(x,y2, '--k','LineWidth',3);
axis equal;
axis([1e4 1e6 1e4 1e6]);
set(gca,'xtick',[1e4 1e5 1e6]); 
set(gca,'ytick',[1e4 1e5 1e6]); 
hLegend=legend([err_bt,err_bt_VM],...
    'Bending-torsion test on 30NCD16(R=-1)',...
    'Bending-torsion test on 30NCD16 with Von Mises stress(R=-1)','location','bestoutside');
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
saveas(gcf,'F:\Git\Anew\figures\bt2D_m_30NCD16_err1.png');

sp=actxserver('SAPI.SpVoice');
sp.Speak('done done done');
% figure(2);
% plot(alpm_bt,'b')

% figure(3);
% plot(Smaxben,'b')
% hold on 
% plot(Smaxtor,'r')
