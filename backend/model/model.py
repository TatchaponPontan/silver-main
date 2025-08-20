#Import Python Library
import numpy as np
from sklearn import linear_model
from sklearn.model_selection import train_test_split
import pandas as pd
import joblib
from django.db import models

#Load Data
data = pd.read_csv('LBMA-SILVER.csv')

data['year'] = pd.to_datetime(data['Date']).dt.year
data['month'] = pd.to_datetime(data['Date']).dt.month
x = data[['year', 'month']]
y = data['USD']  # เปลี่ยนจาก 'Price' เป็น 'USD' หรือเลือก 'GBP', 'EURO' ตามต้องการ

# ลบแถวที่มี missing ใน x หรือ y
data_clean = pd.concat([x, y], axis=1).dropna()
x = data_clean.iloc[:, :-1]
y = data_clean.iloc[:, -1]

# แปลง y ให้เป็น 1D array
y = np.array(y).ravel()

# ตรวจสอบ missing values
assert not x.isnull().any().any(), "Missing values in x"
assert not np.isnan(y).any(), "Missing values in y"

#Divide Training/Test Data แบบ Hold out
x_train, x_test, y_train, y_test = train_test_split(x, y,
                                                    test_size=0.3,
                                                    random_state=0)
#Build Model
net=linear_model.LinearRegression()
net.fit(x_train, y_train)

#Test Model
y_pred=net.predict(x_test)

#Evaluate Models
mape=np.mean(np.absolute(y_test - y_pred) / y_test * 100)
print('MAPE :', np.round(mape,2))

#Export Model
joblib.dump(net,"LBMA-SILVER-model.pkl")