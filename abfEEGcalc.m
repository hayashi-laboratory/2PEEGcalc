function [delta2thetaratio] = abfEEGcalc(file_name,a,b)
% a= 1st image no.;  b= last image no.
% abfEEGcalc(17616000,11,34)

% load raw data from pclampx
[d,si,h]=abfload(strcat(num2str(file_name),'.abf'),'start',0,'stop','e');
% [n,deltaratio,thetaratio, emgpower,states]=sleepscore(17619004,3,24);

%% pick up scans
scanvec=d(:,3);
scan=scanvec;

% find scan area (scan=1, non-scan=0, )
scan_2=scan>9;
% count=scan(scan>9);

% for i=1:length(scan)
%     if scan(i)<9
%         scan(i)=0;
%     else
%         scan(i)=1;
%     end
% end

% find scan region
[r,c]=find(scan_2==1);  
count=[r];
% (r= no. of datapoints, c=1)


%find the discontinuous region
n=1; 
Lcount(1)=count(1);
for j=1:length(count)-1;
    if count(j+1)-count(j)>1000
        n=n+1;
        
        Lcount(n)=count(j+1);
        Ucount(n-1)=count(j);
        scan_length(n-1)=Ucount(n-1)-Lcount(n-1);
        % scan_length= the number of datapoints in one scans
    end
    
end
% define the last one; 
% n= the number of scans in this file
Ucount(n)=count(length(count));
scan_length(n)=Ucount(n)-Lcount(n);


%% calculate power spectrum

% sr=sampling rate; interval:sec
sr=2000;

% defind calculated area  
epochs=zeros(length(Lcount),length(Ucount));
epochs=[Lcount-10000;Ucount+10000];
% epochs(1,1)=1; % if 1st scan < 5s (<10000 datapoints), then start clacultate from 1st datapoint
% epochs(2,n)=epochs(2,n)-4000; % if the last scan <5% (<10000 datapoint,then calculate only 3 sec for example.

deltapower=zeros(n,1);
deltaratio=zeros(n,1);
thetaratio=zeros(n,1);
delta2thetaratio=zeros(n,1);
emgpower=zeros(n,1);

for ii=1:n
    eegbit=d(epochs(1,ii):epochs(2,ii),1);
    emgbit=d(epochs(1,ii):epochs(2,ii),2);
    
    thisdeltapower=bandpower(eegbit, sr, [0.5,4]);
    thisgammapower=bandpower(eegbit, sr, [25,100]);
    thisthetapower=bandpower(eegbit, sr, [6,10]);
     
    thisdeltaratio=thisdeltapower/thisgammapower;
    thisthetaratio=thisthetapower/thisgammapower;
    thisdelta2thetaratio=thisdeltapower/thisthetapower;
    
    thisemgpower=bandpower(emgbit, sr, [50,200]);
    
    deltapower(ii,1)=thisdeltapower;
    deltaratio(ii,1)=thisdeltaratio;
    thetaratio(ii,1)=thisthetaratio;
    delta2thetaratio(ii,1)= thisdelta2thetaratio;
    emgpower(ii,1)=thisemgpower;
    
end
%% plot
figure
subplot(3,1,1)
plot(deltaratio, 'b.-');
hold on;
plot(thetaratio, 'r.-');
% ldg_1=legend('delta ratio','theta ratio');
% ldg_1.FontWeight='bold';
% title(ldg_1,num2str(file_name));
title(strcat(num2str(file_name),[' \color{blue}deltaratio \color{red}thetaratio']))

% label each sample point
x=(1:n);
y_1=deltaratio;
y_2=thetaratio;
labels=cellstr(num2str([a:b]'));
text(x,y_1,labels)
text(x,y_2,labels)

% plot delta/theta ratio
subplot(3,1,2)
plot(delta2thetaratio,'b.-')
line([1 n],[1 1],'LineWidth',2)
title(strcat(num2str(file_name),[' \color{blue}delta/thetaratio']))
% label each sample point
x=(1:n);
y_3=delta2thetaratio;
labels=cellstr(num2str([a:b]'));
text(x,y_3,labels)
% % plot each value
% label_value=cellstr(num2str([delta2thetaratio]));
% text(x,y_3-0.2,label_value,'Color','blue')


% plot EMG power
subplot(3,1,3)
plot(emgpower, 'k.-');
% ldg_2=legend('emgpower');
% ldg_2.FontWeight='bold';
% title(ldg_2,num2str(file_name))
title(strcat(num2str(file_name),['\color{black}emgpower']))
% label each sample point
x=(1:n);
y_4=emgpower;
labels=cellstr(num2str([a:b]'));
text(x,y_4,labels,'color','b')
saveas(gcf,strcat('abfEEGcalc_',num2str(file_name)),'tif')


end


