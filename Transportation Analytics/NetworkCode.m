cd 'C:\Users\justi\OneDrive\Desktop\Columbia\IEOR 4418 Transportation Analytics and Logistics\Project'
clear all; clc
time=csvread("aveduration_normaldays.csv");
time=round(time/60,2);
time(:,2)=round(csvread("aveduration1103.csv")/60,2);

s1=["116","116","152","152","42","42","41","41","166","41","41","74","24"...
    "24","41","151","151","238","238","239","239","239","142","143","48",...
    "142","48","48","142","142","230","230","161","162","161","162","162",...
    "163","163","229","229","140","140","141","141","237","237","43","43",...
    "75","75","75","262","263"];
t1=["152","42","42","166","41","74","166","74","24","24","75","75","151"...
    "43","43","43","238","239","43","43","142","143","143","50","50","48",...
    "230","163","163","43","161","163","162","163","163","229","237","237",...
    "43","141","140","141","262","237","263","43","236","236","75","236",...
    "263","262","263","236"];
G_full=graph(s1,t1,time(:,1));
clear s1 t1

G_reduced_1=rmnode(G_full,["74","75","236","237"]);
G_reduced_2=rmnode(G_full,["140","262"]);
G_reduced_3=rmnode(G_full,["43"]);
G_reduced_4=rmnode(G_full,["74","75","236","237","140","262","43"]);

% Plot Network Visualisations
% plot(G_full,'EdgeLabel',G_full.Edges.Weight)
% title('Full Network')
% 
% figure()
% subplot(2,2,1)
% plot(G_reduced_1)
% title('5th Avenue Closed, "74","75","236","237"')
% subplot(2,2,2)
% plot(G_reduced_2)
% title('1st Avenue Closed, "140","262"')
% subplot(2,2,3)
% plot(G_reduced_3)
% title('Central Park Closed, "43"')
% subplot(2,2,4)
% plot(G_reduced_4)
% title('1st Ave, 5th Ave, Central Park Closed')

%% 5th Ave Closure
n1=height(G_reduced_1.Nodes);
v1=1:n1;
x1=nchoosek(v1,2);

for i=1:length(x1)
    [P,d] = shortestpath(G_reduced_1,x1(i,1),x1(i,2));
    x1(i,3)=d;
end
clear i P d

for i=1:length(x1)
   a=G_reduced_1.Nodes(x1(i,1),'Name');
   b=G_reduced_1.Nodes(x1(i,2),'Name');
   for j=1:height(G_full.Nodes)
       check=G_full.Nodes(j,'Name');
       if isequal(a,check)==1
           index1=j;
       end
       if isequal(b,check)==1
           index2=j;
       end
   end
    [P,d] = shortestpath(G_full,index1,index2);
    x1(i,4)=d;
    x1(i,5)=x1(i,3)-x1(i,4);
end
clear i a b check d P index1 index2 j

histogram(x1(:,5),15)
title('Histogram of Increase in Travel Time Under 5th Ave Closure')

%find percentage of routes with increased travel time
nnz(x1(:,5))/length(x1)

%% Central Park Closure
n2=height(G_reduced_3.Nodes);
v2=1:n2;
x2=nchoosek(v2,2);

for i=1:length(x2)
    [P,d] = shortestpath(G_reduced_3,x2(i,1),x2(i,2));
    x2(i,3)=d;
end
clear i P d

for i=1:length(x2)
   a=G_reduced_3.Nodes(x2(i,1),'Name');
   b=G_reduced_3.Nodes(x2(i,2),'Name');
   for j=1:height(G_full.Nodes)
       check=G_full.Nodes(j,'Name');
       if isequal(a,check)==1
           index1=j;
       end
       if isequal(b,check)==1
           index2=j;
       end
   end
    [P,d] = shortestpath(G_full,index1,index2);
    x2(i,4)=d;
    x2(i,5)=x2(i,3)-x2(i,4);
end
clear i a b check d P j index1 index2

histogram(x2(:,5),15)
title('Histogram of Increase in Travel Time Under Central Park Closure')

%find percentage of routes with increased travel time
nnz(x2(:,5))/length(x2)

%% Full Road Closure
n3=height(G_reduced_4.Nodes);
v3=1:n3;
x3=nchoosek(v3,2);

for i=1:length(x3)
    [P,d] = shortestpath(G_reduced_4,x3(i,1),x3(i,2));
    x3(i,3)=d;
end
clear i P d

for i=1:length(x3)
   a=G_reduced_4.Nodes(x3(i,1),'Name');
   b=G_reduced_4.Nodes(x3(i,2),'Name');
   for j=1:height(G_full.Nodes)
       check=G_full.Nodes(j,'Name');
       if isequal(a,check)==1
           index1=j;
       end
       if isequal(b,check)==1
           index2=j;
       end
   end
    [P,d] = shortestpath(G_full,index1,index2);
    x3(i,4)=d;
    x3(i,5)=x3(i,3)-x3(i,4);
end
clear i a b check d P j index1 index2

figure()
histogram(x3(:,5),15)
title('Histogram of Increase in Travel Time Under Full Road Closure')

%find percentage of routes with increased travel time
nnz(x3(:,5))/length(x3)

%% MeanDemandByZones
dd=table2array(readtable('MeanDemandByZones.csv'));
nn=table2array(readtable('node_numbers.csv'));

% Add Node Names
for i=1:length(x1)
    x1(i,6)=nn(x1(i,1),1);
    x1(i,7)=nn(x1(i,2),1);
end

for i=1:length(x2)
    x2(i,6)=nn(x2(i,1),2);
    x2(i,7)=nn(x2(i,2),2);
end

for i=1:length(x3)
    x3(i,6)=nn(x3(i,1),3);
    x3(i,7)=nn(x3(i,2),3);
end
clear i

%Find Ave Travel Time for Rides Originating from each Node
traveltime1=zeros(length(nn),1);
traveltime2=zeros(length(nn),1);
traveltime3=zeros(length(nn),1);

for i=1:length(nn)
    index1=nn(i,1);
    count=0;
    for j=1:length(x1)
        if x1(j,6)==index1
            count=count+x1(j,5);
        end
        if x1(j,7)==index1
            count=count+x1(j,5);
        end
        traveltime1(i,1)=count;
    end
end
traveltime1=traveltime1/n1;
traveltime1(:,2)=nn(:,1);

for i=1:length(nn)
    index2=nn(i,2);
    count=0;
    for j=1:length(x2)
        if x2(j,6)==index2
            count=count+x2(j,5);
        end
        if x2(j,7)==index2
            count=count+x2(j,5);
        end
        traveltime2(i,1)=count;
    end
end
traveltime2=traveltime2/n2;
traveltime2(:,2)=nn(:,2);

for i=1:length(nn)
    index3=nn(i,3);
    count=0;
    for j=1:length(x3)
        if x3(j,6)==index3
            count=count+x3(j,5);
        end
        if x3(j,7)==index3
            count=count+x3(j,5);
        end
        traveltime3(i,1)=count;
    end
end
traveltime3=traveltime3/n3;
traveltime3(:,2)=nn(:,3);

clear index1 index2 index3 count i j

traveltime1(24:26,:)=[];
traveltime3(21:26,:)=[];

%% Calculate Mean Increase in Travel Time
for i=1:length(traveltime1)
    [~,d]=size(traveltime1);
    for j=1:length(dd)
        if traveltime1(i,2)==dd(j,1)
            traveltime1(i,3:7)=dd(j,2:6);
        end
    end
end

for i=1:length(traveltime2)
    [~,d]=size(traveltime2);
    for j=1:length(dd)
        if traveltime2(i,2)==dd(j,1)
            traveltime2(i,3:7)=dd(j,2:6);
        end
    end
end

for i=1:length(traveltime3)
    [~,d]=size(traveltime3);
    for j=1:length(dd)
        if traveltime3(i,2)==dd(j,1)
            traveltime3(i,3:7)=dd(j,2:6);
        end
    end
end

%multiply demand rates by time increase to find time increase per hour for
%each time zone
for i=1:length(traveltime1)
    traveltime1(i,8)=traveltime1(i,1)*traveltime1(i,3);
    traveltime1(i,9)=traveltime1(i,1)*traveltime1(i,4);
    traveltime1(i,10)=traveltime1(i,1)*traveltime1(i,5);
    traveltime1(i,11)=traveltime1(i,1)*traveltime1(i,6);
    traveltime1(i,12)=traveltime1(i,1)*traveltime1(i,7);
end

for i=1:length(traveltime2)
    traveltime2(i,8)=traveltime2(i,1)*traveltime2(i,3);
    traveltime2(i,9)=traveltime2(i,1)*traveltime2(i,4);
    traveltime2(i,10)=traveltime2(i,1)*traveltime2(i,5);
    traveltime2(i,11)=traveltime2(i,1)*traveltime2(i,6);
    traveltime2(i,12)=traveltime2(i,1)*traveltime2(i,7);
end

for i=1:length(traveltime3)
    traveltime3(i,8)=traveltime3(i,1)*traveltime3(i,3);
    traveltime3(i,9)=traveltime3(i,1)*traveltime3(i,4);
    traveltime3(i,10)=traveltime3(i,1)*traveltime3(i,5);
    traveltime3(i,11)=traveltime3(i,1)*traveltime3(i,6);
    traveltime3(i,12)=traveltime3(i,1)*traveltime3(i,7);
end

for i=1:5
   hourly_increase(i,1)=sum(traveltime1(:,i+7));
   hourly_increase(i,2)=sum(traveltime2(:,i+7));
   hourly_increase(i,3)=sum(traveltime3(:,i+7));
end


c = categorical({'0000-0800','0801-1000','1001-1600','1700-1900','1900-2359'});
bpcombined = [hourly_increase(:,1), hourly_increase(:,2), hourly_increase(:,3)];
hb = bar(c, bpcombined, 'grouped')
title('Global Increase in Taxi Travel Time Per hr')
legend('5th Ave', 'Central Park', 'All')
ylabel('Time Increase per hour/ Min')
xlabel('Time Period')

% Find absolute time increase
for i=1:length(traveltime1)
    traveltime1(i,13)=traveltime1(i,8)*8;
    traveltime1(i,14)=traveltime1(i,9)*2;
    traveltime1(i,15)=traveltime1(i,10)*5;
    traveltime1(i,16)=traveltime1(i,11)*2;
    traveltime1(i,17)=traveltime1(i,12)*4;
    traveltime1(i,18)=sum(traveltime1(i,13:15));
end
sum(traveltime1(:,18));
sum(traveltime1(:,18))/(sum(traveltime1(:,3))*8+sum(traveltime1(:,4))*2+...
    sum(traveltime1(:,5))*5+sum(traveltime1(:,6))*2+sum(traveltime1(:,7))*4)

for i=1:length(traveltime2)
    traveltime2(i,13)=traveltime2(i,8)*8;
    traveltime2(i,14)=traveltime2(i,9)*2;
    traveltime2(i,15)=traveltime2(i,10)*5;
    traveltime2(i,16)=traveltime2(i,11)*2;
    traveltime2(i,17)=traveltime2(i,12)*4;
    traveltime2(i,18)=sum(traveltime2(i,13:15));
end
sum(traveltime2(:,18));
sum(traveltime2(:,18))/(sum(traveltime2(:,3))*8+sum(traveltime2(:,4))*2+...
    sum(traveltime2(:,5))*5+sum(traveltime2(:,6))*2+sum(traveltime2(:,7))*4)

for i=1:length(traveltime3)
    traveltime3(i,13)=traveltime3(i,8)*8;
    traveltime3(i,14)=traveltime3(i,9)*2;
    traveltime3(i,15)=traveltime3(i,10)*5;
    traveltime3(i,16)=traveltime3(i,11)*2;
    traveltime3(i,17)=traveltime3(i,12)*4;
    traveltime3(i,18)=sum(traveltime3(i,13:15));
end
sum(traveltime3(:,18));
sum(traveltime3(:,18))/(sum(traveltime3(:,3))*8+sum(traveltime3(:,4))*2+...
    sum(traveltime3(:,5))*5+sum(traveltime3(:,6))*2+sum(traveltime3(:,7))*4)