clc;
close all;
%Calculated noise gains for desired SNR
SNR=1;       % SNR= 0dB
%SNR=1.4;      % SNR= ~3dB  
%SNR=2;       % SNR= ~6dB
%SNR=3;       % SNR= ~10dB
%SNR=1/1.4;   % SNR= ~-3dB
%SNR=1/2;    %  SNR= ~-6dB
%SNR=1/3;    % SNR= -10dB
[orig, Fs1] = audioread('original.wav');
rms_orig=rms(orig);
orig=orig/rms_orig;
[n, Fs2] = audioread('noise.wav');
rms_noise=rms(n);
mu0=1e-6;
mu=mu0*2/rms_noise;
noise=n/rms_noise;
noise=noise*SNR;                                      
[Ref, Fs3]=audioread('Ref.wav');
rms_Ref=rms(Ref);
Ref=Ref/rms_Ref;
Ref=Ref*SNR;

d=orig+noise;  %corrupted primary signal

M=20;   %Order of FIR filter



L=length(orig); %Lenght of samples. All are same lenght.
W=zeros(M,1);  %FIR filter coeficients
y=zeros(L,1);  %LMS filter output
e=zeros(L,1);  %Estimation error of LMS filter

for i=1:1:L
 U=zeros(M,1);  % Storing last M samples of Reference for LMS input for every output sample
     for k=1:1:M  
     if  (i-k) > 0
         U(k)=Ref(i-k);     
     end
     for k=1:1:M               %calculating output of filter
        y(i)=y(i)+(W(k)*U(k));
     end
     
    e(i)=d(i)-y(i);  %estimation error
    for j=1:M
       W(j)=W(j)+(mu*e(i)*U(j));
    end
    end  
    
end

fs=Fs1;
audiowrite('enhanced.wav',e,fs);  %This will give a warning about wave sound clipping, meaning amplitude surpasses 1. It can be ignored
%audiowrite('corrupted.wav',d,fs);
%save('enahnced.mat','e','fs');  %To avoid any possible problem with wave clipping, I stored the array as is in a *.mat file
SNR_noise=snr(orig,noise)   %SNR between clean speech and noise
SNR_e=snr(orig,e)   %SNR between clean speech and enhanced signal
variance=var(noise)

%plotting Time domain

dt=1/fs;
t = 0:dt:(length(y)*dt)-dt;

subplot(611);
plot(t,e);
xlabel('Seconds'); ylabel('Amplitude');
title('e(t)- enhanced signal');
subplot(612);
plot(t,y);
xlabel('Seconds'); ylabel('Amplitude');
title('y(t)- output of LMS filter');
subplot(613);
plot(t,d);
xlabel('Seconds'); ylabel('Amplitude');
title('d(t)- primary signal');
subplot(614);
plot(t,Ref);
xlabel('Seconds'); ylabel('Amplitude');
title('u(t) input of LMS Filter - Reference Signal');
subplot(615);
plot(t,orig);
xlabel('Seconds'); ylabel('Amplitude');
title('Original Clean Sample');
subplot(616);
plot(t,noise);
xlabel('Seconds'); ylabel('Amplitude');
title('n(t) - Noise ');
sgtitle(['Time Domain SNR=',num2str(SNR_noise),'  SNR to enhanced=',num2str(SNR_e),' Var=',num2str(variance)]);



%plotting in frequency domain using FFT of wave signals.

d_dft = fft(d);
e_dft = fft(e);
n_dft= fft(noise);
orig_dft=fft(orig);
d_dft = d_dft(1:L/2+1);
e_dft = e_dft(1:L/2+1);
n_dft = n_dft(1:L/2+1);
orig_dft = orig_dft(1:L/2+1);

freq = 0:fs/L:fs/2;
figure;
subplot(811);
plot(freq,abs(e_dft));
xlabel('Hz');
ylabel('Magnitude');
title('e - Enhanced Signal');
subplot(812);
plot(freq,unwrap(angle(e_dft))); 
xlabel('Hz');
ylabel('Phase');
title('e - Enhanced Signal');

subplot(813);
plot(freq,abs(d_dft));
xlabel('Hz');
ylabel('Magnitude');
title('d - Corrupted signal');
subplot(814);
plot(freq,unwrap(angle(d_dft))); 
xlabel('Hz');
ylabel('Phase');
title('d - Corrupted signal');



subplot(815);
plot(freq,abs(n_dft));
xlabel('Hz');
ylabel('Magnitude');
title('Noise');
subplot(816);
plot(freq,unwrap(angle(n_dft))); 
xlabel('Hz');
ylabel('Phase');
title('Noise');


subplot(817);
plot(freq,abs(orig_dft));
xlabel('Hz');
ylabel('Magnitude');
title('Original Signal');
subplot(818);
plot(freq,unwrap(angle(orig_dft))); 
xlabel('Hz');
ylabel('Phase');
title('Original Signal');
sgtitle(['Frequency Domain SNR=',num2str(SNR_noise),' SNR to enhanced=',num2str(SNR_e),' Var=',num2str(variance)]);



