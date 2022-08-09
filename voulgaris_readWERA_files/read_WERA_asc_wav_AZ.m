clear;
HS = []; IX = []; IY = []; SPEC = [];l=0; NEW = [];

for i = 1:24 % hours in the filename
    
    for k=1:5 % minutes in the file name for integration time of 12 min
    
        if k==5; % full hour condition
            k=0;
        end
l=l+1;        
n = sprintf('%02d',i-1); m = sprintf('%02d',k*12); % convert hours and minutes numbers to 2 digits string, factor of 12 for integration time

[fid, message]=fopen(['2019358',n,m,'_izr.wav_asc'],'r'); % open file

a = fgetl(fid);
NStations  = str2double(a);
Lat        = zeros(1,NStations);
Lon        = zeros(1,NStations);

for Ist = 1:NStations
    b                = fgetl(fid);
    time(Ist)        = datenum(b(2:18));
    St_name(Ist,1:10)= b(25:34);
    Lon(Ist)         = str2double(b(38:45));
    Lat(Ist)         = str2double(b(54:61));
    ew               = b(63);
    if ew=='W' || ew =='w'
        Lat(Ist)=-Lat(Ist);
    end
end

junk = fgetl(fid);
junk = fgetl(fid);
junk = fgetl(fid);

d  = fgetl(fid);

LAT0 = str2double(d(3:10));
LON0 = str2double(d(13:21));
DGT  = str2double(d(25:30));
NX   = str2double(d(33:35));
NY   = str2double(d(38:40));

junk = fgetl(fid);
nos  = fgetl(fid);
N    = str2double(nos);

Spec = [];
Hs = [];
Ix = [];
Iy = [];
New = [];
% loop
for j = 1:N
    
f = fgetl(fid);
ix = str2double(f(1:4));
iy = str2double(f(5:8));
nbins = str2double(f(10:12));

cell = fscanf(fid,'%15f %15f %4i \n',[3,nbins]);
cell = cell';
spec = mat2cell(cell,nbins,3);
hs = trapz(spec{1,1}(:,1),spec{1,1}(:,2));
junk = fgetl(fid);
new = str2double(junk(1:9));

Spec {j} = spec;
Hs {j} = hs;
Ix {j}= ix;
Iy {j}= iy;
New {j} = new;


%g = fgetl(fid);
%unknown = str2double(g(10:12));

end

HS{l} = Hs; IX{l} = Ix; IY{l} = Iy; SPEC{l} = Spec; NEW{l} = New;
    end
end

fclose('all')
%%
for i=1:120

[xq,yq] = meshgrid(0:200,0:200);
vq = griddata(cell2mat(IX{1,i}),cell2mat(IY{1,i}),cell2mat(NEW{1,i}),xq,yq);  %(x,y,v) being your original data for plotting points
mesh(xq,yq,vq)
xlim([60 200]); 
ylim([120 200]);
colorbar
view(2);
pause(0.2)

end
close
%%
H_ser = []; H_Ser = [];
for j=1:4
    
for i = 1:120
[M1,N1]=find(cell2mat(IX{1,i})==118+j);
[M2,N2]=find(cell2mat(IY{1,i})==143);
if isempty(N1) || isempty(N2)
    continue
end
s = ismember(N1,N2); 
if s==0
    continue
end
Index = N1(s==1);
H_ser(i)=cell2mat(NEW{1,i}(1,Index));
end

H_Ser (j,:)= H_ser;

end
%%
plot(H_Ser(4,:))
%%
HHs = mean(H_Ser);
plot(HHs);
%%
hold on
%plot3(x,y,v,'o')
%xlim([-2.7 2.7])
%ylim([-2.7 2.7])
H_S = cell2mat(HS);
%surf(IX,IY,H_S)
scatter3(IX, IY, H_S, 'o');
colorbar
view(2);
%%
t2 = 0:24/numel(HS2):24-24/numel(HS2);
t1 = 0:24/numel(HHs):24-24/numel(HHs)
figure;plot(t1,HHs,t2,HS2);
