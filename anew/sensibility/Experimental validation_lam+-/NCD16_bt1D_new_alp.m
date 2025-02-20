% steel AL6082T6 data from Jabbado thesis
%-------------------------------------------------bending--------------------------------
load('NCD16.mat');
load('gaussian.mat');
m=0;%mean tension
NFben=[51000 
80000 
90000 
95000 
100000 
120000 
140000 
200000 
210000 
230000 
250000] ;
stressben=[8.2e8 
7.95e8 
7.9e8 
7.85e8 
7.8e8 
7.65e8 
7.52e8 
7.25e8 
7.20e8 
7.15e8 
7.08e8];%to get Smaxben

for  i=1:length(NFben)
    n=1;       %initial recording point
    tensor = [stressben(i)*sind(n*360/stepnumber)+m 0 0 ;...
        0 0 0 ;...
        0 0 0 ];
    run('Damiter1.m')
    while n<cycles*stepnumber
        tensor = [stressben(i)*sind(n*360/stepnumber)+m, 0, 0 ;...
            0, 0, 0 ;...
            0, 0, 0 ; ];
        hydro(n)=1/3*trace(tensor);
        dev1=tensor-hydro(n)*eye(3);
        dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);
        dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
        dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
        tensor = [stressben(i)*sind((n+1)*360/stepnumber)+m, 0, 0 ;...
            0, 0,  0 ;...
            0, 0,  0 ; ];
        run('Damiter2.m')
        n=n+1;
    end
    Smax_ben(i)=(max(Smax)-min(Smax))/2; %sqrt(2/3).*stressben
    alp_ben(i)=mean(alp);
    hydroplus(i)=mean(hydro(find(hydro>0)));
    hydrominus(i)=mean(hydro(find(hydro<0)));
end
%% 
%-------------------------------------------------torsion--------------------------------
NFtor=NFben;
stresstor=[5.27e8 
5.05e8 
5e8 
4.97e8 
4.95e8 
4.82e8 
4.7e8 
4.5e8 
4.46e8 
4.45e8 
4.4e8];%to get Smaxtor

for  i=1:length(NFtor)
    n=1;       %initial recording point
    tensor = [0 stresstor(i)*sind(n*360/stepnumber) 0 ;...
        stresstor(i)*sind(n*360/stepnumber) 0  0 ;...
        0 0 0 ];
     run('Damiter1.m')
      
    while n<cycles*stepnumber
        tensor = [0, stresstor(i)*sind(n*360/stepnumber), 0 ;...
            stresstor(i)*sind(n*360/stepnumber), 0,  0 ;...
            0,0, 0; ];
        hydro=1/3*trace(tensor);
        dev1=tensor-hydro*eye(3);
        dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);%to give \dot{dev\Sigma}dt
        dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
        dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
        tensor = [0, stresstor(i)*sind((n+1)*360/stepnumber), 0 ;...
            stresstor(i)*sind((n+1)*360/stepnumber), 0,  0 ;...
            0, 0, 0; ];
    run('Damiter2.m')
              n=n+1;
    end
    Smax_tor(i)=max(Smax); %sqrt(2/3)*stresstor
    alp_tor(i)=mean(alp);
end



