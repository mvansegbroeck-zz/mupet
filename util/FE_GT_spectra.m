% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function [lp,Xf,E_low, E_usv,T]=FE_GT_spectra(sam,fs,FrameLen,FrameShift,Nfft,Nmin,Nmax,W,M)

GTfloor=1e-3; 

if ~exist('W', 'var')
    W=gammatone_matrix_sigmoid(Nfft*2,fs);
end
if ~exist('M', 'var')
    M=1;
end

% truncate as in ReadWave
NbFr=floor( (length(sam)-FrameLen+FrameShift)/FrameShift);
sam=sam(1:NbFr*FrameShift+FrameLen-FrameShift);

% % Low pass removal
% fmax=0.99*fs/2;
% sam=[0 reshape(sam,1,length(sam))];
% T=length(sam);

% Low pass removal
fmin=25000;
fmax=0.99*fs/2;
[b,a] = cheby1(8,  0.5, [fmin fmax]/(fs/2));
sam=filter(b, a, [0 reshape(sam,1,length(sam))]);
T=length(sam);

% framing
ind1=1:FrameShift:length(sam)-1-FrameLen+FrameShift;

% new
win=hamming(FrameLen);
Xf=zeros(Nfft,NbFr);
for k=1:NbFr
    x=sam(ind1(k):ind1(k)+FrameLen-1)';
    xwin=win.*x;
    X=fft(xwin,2*Nfft);
    Xf(:,k)=X(1:Nfft);
end
Xf=abs(Xf).^2;

% Energy and norm
E_low=sum(Xf(1:Nmin,:))./Nmin;
E_usv=sum(Xf(Nmin+1:Nmax,:))./(Nmax-Nmin);

% GT
Xf_hp=Xf;
Xf_hp(1:Nmin,:)=0;
lp=max(W*Xf_hp,GTfloor);
lp=log(lp);
lp=arma2(lp,M);
