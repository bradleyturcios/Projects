# -*- coding: utf-8 -*-
"""
Created on Thu Apr 30 09:33:18 2020

@author: Administrator
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
%matplotlib

file = r"F:\Transportation\GroupProject\OurProject\trip_data_2019"
df1 = pd.read_csv(file+"\yellow_tripdata_2019-11-03.csv")
df2 = pd.read_csv(file+"\yellow_tripdata_2019-11-10.csv")
df3 = pd.read_csv(file+"\yellow_tripdata_2019-11-17.csv")
df4 = pd.read_csv(file+"\yellow_tripdata_2019-11-24.csv")
df = pd.concat([df1,df2,df3,df4])

# some pre-work
df = df[df["passenger_count"]>0]
df['PUDateTime'] = pd.to_datetime(df['tpep_pickup_datetime'], format="%Y/%m/%d %H:%M:%S")
df['DODateTime'] = pd.to_datetime(df['tpep_dropoff_datetime'], format="%Y/%m/%d %H:%M:%S")
df = df[df["PUDateTime"]>'2019-11-03 02:00:00']

df["Duration"] = (df['DODateTime'] - df['PUDateTime']) / np.timedelta64(1, 's')
df["pickup_hour"] = df["tpep_pickup_datetime"].str[11:13]

# split the data into marathon day df_m and normal Sundays df_n
df_m = df[df["pickup_date"]=="2019-11-03"]
df_n = df[(df["pickup_date"]=='2019-11-10')|(df["pickup_date"]=='2019-11-17')|(df["pickup_date"]=='2019-11-24')]


#### compute the duration between zones
## on marathon day
duration_m = pd.DataFrame(columns=np.unique(df_m["pickup_hour"].values))
for a,b in edges: 
    f1 = (df_m["PULocationID"] == a) & (df_m["DOLocationID"] == b) 
    f2 = (df_m["PULocationID"] == b) & (df_m["DOLocationID"] == a)
    sub = df_m[f1|f2]
    mean_d = sub[["Duration","pickup_hour"]].groupby('pickup_hour').mean()
    mean_d = mean_d.T
    mean_d["edges"] = [(a,b)]
    duration_m = pd.concat([duration_m,mean_d])

duration_m["avg"] = duration_m.median(axis=1)
duration_m = duration_m.reset_index(drop=True)

path = r"F:\Transportation\GroupProject\OurProject\output"
duration_m.to_csv(path+"\duration1103.csv")

## on normal Sundays
duration_n = pd.DataFrame(columns=np.unique(df_n["pickup_hour"].values))
for a,b in edges: 
    f1 = (df_n["PULocationID"] == a) & (df_n["DOLocationID"] == b) 
    f2 = (df_n["PULocationID"] == b) & (df_n["DOLocationID"] == a)
    sub = df_n[f1|f2]
    mean_d = sub[["Duration","pickup_hour"]].groupby('pickup_hour').mean()
    mean_d = mean_d.T
    mean_d["edges"] = [(a,b)]
    duration_n = pd.concat([duration_n,mean_d])
    
duration_n["avg"] = duration_n.median(axis=1)
duration_n = duration_n.reset_index(drop=True)
duration_n.to_csv(path+"\duration_normaldays.csv")

### plot 
time,cnt = np.unique(df1["pickup_hour"].values,return_counts=True)
time2,cnt2 = np.unique(df2["pickup_hour"].values,return_counts=True)
time3,cnt3 = np.unique(df3["pickup_hour"].values,return_counts=True)
time4,cnt4 = np.unique(df4["pickup_hour"].values,return_counts=True)

plt.plot(time,cnt,label="11-03")
plt.plot(time2,cnt2,label="11-10")
plt.plot(time3,cnt3,label="11-17")
plt.plot(time4,cnt4,label="11-24")
plt.legend()
plt.xlabel("time")
plt.ylabel("trip cnts")
plt.title("Yellow Taxi Trip Pick-Up in 2019 Nov. by hours")
plt.show()

### ### trip distance
distance1 = df1[["trip_distance","pickup_hour"]].groupby("pickup_hour").mean()
distance2 = df2[["trip_distance","pickup_hour"]].groupby("pickup_hour").mean()
distance3 = df3[["trip_distance","pickup_hour"]].groupby("pickup_hour").mean()
distance4 = df4[["trip_distance","pickup_hour"]].groupby("pickup_hour").mean()
x = np.arange(2,24,1)
plt.plot(x,distance1["trip_distance"].values,label="11-03")
plt.plot(x,distance2["trip_distance"].values,label="11-10")
plt.plot(x,distance3["trip_distance"].values,label="11-17")
plt.plot(x,distance4["trip_distance"].values,label="11-24")
plt.legend()
plt.xlabel("time")
plt.ylabel("avg trip distance")
plt.title("Yellow Taxi Average Trip Distance in 2019 Nov. by hours")
plt.show()

# estimate demand by zones
df = pd.concat([df2,df3,df4])
df = df[df["passenger_count"]>0]
df['PUDateTime'] = pd.to_datetime(df['tpep_pickup_datetime'], format="%Y/%m/%d %H:%M:%S")
df['DODateTime'] = pd.to_datetime(df['tpep_dropoff_datetime'], format="%Y/%m/%d %H:%M:%S")
df["Duration"] = (df['DODateTime'] - df['PUDateTime']) / np.timedelta64(1, 's')
df["pickup_hour"] = df['PUDateTime'].dt.hour

zones = [116,152,42,166,41,74,24,151,238,239,142,143,50,48,230,161,162,163,229,237,141,140,
         262,263,236,75,43]

df = df[df['PULocationID'].isin(zones)]

df["t1"] = (df['pickup_hour']<8)*1
df["t2"] = ((df['pickup_hour']>=8)&(df['pickup_hour']<10))*1
df["t3"] = ((df['pickup_hour']>=10)&(df['pickup_hour']<16))*1
df["t4"] = ((df['pickup_hour']>=16)&(df['pickup_hour']<19))*1
df["t5"] = ((df['pickup_hour']>=19)&(df['pickup_hour']<24))*1


result = df[['t1','t2','t3','t4','t5','PULocationID','pickup_date']].groupby(['PULocationID','pickup_date']).sum()
result = result.reset_index()

result2 = result[['t1','t2','t3','t4','t5','PULocationID']].groupby('PULocationID').mean()
result2['t1'] = result2['t1']/8
result2['t2'] = result2['t2']/2
result2['t3'] = result2['t3']/6
result2['t4'] = result2['t4']/2
result2['t5'] = result2['t5']/5

path = r"F:\Transportation\GroupProject\OurProject\output"
result.to_csv(path)

result2.to_csv(path+'\MeanDemandByZones.csv')
