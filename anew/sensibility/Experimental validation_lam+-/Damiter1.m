%---------------------repeated code to get the the first Sb-----------------------------
hydro(1)=1/3*trace(tensor);
if hydro(1)>=0
yield(1)=y-lamplus.*hydro(1); %micro yield strength at n=1
else
yield(1)=y-lamminus.*hydro(1);    
end
dev1=tensor-hydro(1)*eye(3);
dev11=dev1(1,1); dev12=dev1(1,2); dev13=dev1(1,3);
dev21=dev1(2,1); dev22=dev1(2,2); dev23=dev1(2,3);
dev31=dev1(3,1); dev32=dev1(3,2); dev33=dev1(3,3);
Smax=1/sqrt(2).*norm(dev1,'fro');
%1*64

trial11=dev11; trial12=dev12; trial13=dev13;
trial21=dev21; trial22=dev22; trial23=dev23;
trial31=dev31; trial32=dev32; trial33=dev33;

Smaxtrial=1/sqrt(2).*norm([trial11, trial12, trial13; trial21, trial22, trial23;trial31, trial32, trial33],'fro');
s= (x/2+1/2).^(1/(1-b));
eta=bsxfun(@minus,bsxfun(@times,Smaxtrial/yield(1),s),1); %compare Smaxtrial with yield/s
eta(eta<0)=0; %only keep Smaxtrials which are larger than yield/s

Sb11=bsxfun(@rdivide,trial11,bsxfun(@plus,eta,1));Sb12=bsxfun(@rdivide,trial12,bsxfun(@plus,eta,1));Sb13=bsxfun(@rdivide,trial13,bsxfun(@plus,eta,1));
Sb21=bsxfun(@rdivide,trial21,bsxfun(@plus,eta,1));Sb22=bsxfun(@rdivide,trial22,bsxfun(@plus,eta,1));Sb23=bsxfun(@rdivide,trial23,bsxfun(@plus,eta,1));
Sb31=bsxfun(@rdivide,trial31,bsxfun(@plus,eta,1));Sb32=bsxfun(@rdivide,trial32,bsxfun(@plus,eta,1));Sb33=bsxfun(@rdivide,trial33,bsxfun(@plus,eta,1));

Ws=(bsxfun(@minus,Smaxtrial,bsxfun(@rdivide, yield(1),s))<=0).*...
    (0)+...
    (bsxfun(@minus,Smaxtrial,bsxfun(@rdivide, yield(1),s))>0).*...
    ((E-k)*(1+nu)*(2*E*(E+k*nu))^-1*bsxfun(@times,weight,bsxfun(@rdivide,bsxfun(@times,bsxfun(@minus,Smaxtrial,bsxfun(@rdivide, yield(1),s)),yield(1)),s)));

W= sum(Ws);
W_accumulate=W;
sequence=((Smax*yield(1)^-1)*(1-Smax*yield(1)^-1)^-1)^b;
sequence(sequence<0)=0;
alp=1-a*sequence;

alp_ref=alp;
n_ref=n;
W_ref=W_accumulate;
