#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd


# In[2]:


import os


# In[3]:


files = [file for file in os.listdir("E:\DATA_ANALYSIS\Pandas\Pandas-Data-Science-Tasks-master\SalesAnalysis\Sales_Data")]

all_months_data = pd.DataFrame()

for file in files:
    df = pd.read_csv("E:/DATA_ANALYSIS/Pandas/Pandas-Data-Science-Tasks-master/SalesAnalysis/Sales_Data/" + file)
    all_months_data = pd.concat([all_months_data, df])

all_months_data.to_csv("all_data.csv", index=False)    
    


# In[11]:


all_data = pd.read_csv("all_data.csv")
all_data.head(520)


# In[18]:


### Read in updated dataframe


# In[21]:


all_data_clean = all_data.dropna()
all_data_clean.head(400)

all_data_clean['Month'] = all_data_clean['Order Date'].str.split('/').str[0]
all_data_clean


# In[38]:


all_data_cleanest = all_data_clean.loc[:, ~all_data_clean.columns.duplicated()]
invalid_rows = all_data_cleanest[all_data_cleanest['Quantity Ordered'].isna()]
print(invalid_rows)


# In[25]:


all_data_cleanest = all_data_cleanest[all_data_cleanest['Month'] != 'Or']


# In[ ]:





# In[34]:


all_data_cleanest['Price Each'] = pd.to_numeric(all_data_cleanest['Price Each'], errors='coerce')
all_data_cleanest['Price Each'].dtype


# In[47]:


all_data_cleanest['Quantity Ordered'] = pd.to_numeric(all_data_cleanest['Quantity Ordered'], errors='coerce')
all_data_cleanest['Quantity Ordered'] = all_data_cleanest['Quantity Ordered'].astype('Int32', errors='ignore')
all_data_cleanest['Month'] = pd.to_numeric(all_data_cleanest['Month'], errors='coerce')
all_data_cleanest['Month'] = all_data_cleanest['Month'].astype('Int32', errors='ignore')
all_data_cleanest['Price Each'] = pd.to_numeric(all_data_cleanest['Price Each'], errors='coerce')
all_data_cleanest['Price Each'] = all_data_cleanest['Price Each'].astype('Int32', errors='ignore')
all_data_cleanest['Sale'] = all_data_cleanest['Quantity Ordered'] * all_data_cleanest['Price Each']


# In[48]:


results = all_data_cleanest.groupby('Month')['Sale'].sum().reset_index()
results['Sale'] = results['Sale'].astype('int32') 
results


# In[71]:


import matplotlib.pyplot as plt
import matplotlib as mpl
all_data_cleanest = all_data_cleanest.dropna()


# In[72]:


months = range(1,13)
plt.bar(results['Month'], results['Sale'])

plt.xticks(months)
plt.ylabel('Sales in USD ($)')
plt.xlabel('Month number')
plt.title('Monthly Sales')
plt.gca().yaxis.set_major_formatter(plt.matplotlib.ticker.StrMethodFormatter('{x:,.0f}'))
plt.show()


# ### What city had the highest number of sales

# In[75]:


def get_city(address):
    return address.split(',')[1]
def get_state(address):
    return address.split(',')[2].split(' ')[1]

all_data_cleanest['City'] = all_data_cleanest['Purchase Address'].apply(lambda x: f"{get_city(x)} ({get_state(x)})")


# In[76]:


results_city = all_data_cleanest.groupby('City')['Sale'].sum().reset_index()
results_city


# In[77]:


plt.bar(results_city['City'], results_city['Sale'])

plt.ylabel('Sales in USD ($)')
plt.xticks(results_city['City'], rotation = 'vertical')
plt.xlabel('City Name')
plt.title('Monthly Sales')
plt.gca().yaxis.set_major_formatter(plt.matplotlib.ticker.StrMethodFormatter('{x:,.0f}'))
plt.show()


# In[85]:


pd.options.mode.copy_on_write = True


# In[86]:


all_data_cleanest['Order Date'] = pd.to_datetime(all_data_cleanest['Order Date']) 


# In[87]:


#all_data_cleanest['Hour'] = all_data_cleanest['Order Date'].dt.hour
all_data_cleanest['Minute'] = all_data_cleanest['Order Date'].dt.minute


# In[84]:


all_data_cleanest


# In[95]:


hours = [hour for hour, df in all_data_cleanest.groupby('Hour')]

plt.plot(hours, all_data_cleanest.groupby(['Hour']).count())

plt.ylabel('Count of Sales')
plt.xticks(hours)
#plt.xlabel(all_data_cleanest.groupby('Hour'))
plt.title('Best Time for sales')
#plt.gca().yaxis.set_major_formatter(plt.matplotlib.ticker.StrMethodFormatter('{x:,.0f}'))
plt.grid()
plt.show()


# In[98]:


df = all_data_cleanest[all_data_cleanest['Order ID'].duplicated(keep=False)]
df['Grouped'] = df.groupby('Order ID')['Product'].transform(lambda x: ',' .join(x))

df = df[['Order ID', 'Grouped']].drop_duplicates()
df


# In[109]:


from itertools import combinations
from collections import Counter

count = Counter()

for row in df['Grouped']:
    row_list = row.split(',')
    count.update(Counter(combinations(row_list,2)))
count.most_common(10)    


# In[136]:


product_group = all_data_cleanest[['Product','Quantity Ordered']].groupby('Product')
quantity_ordered = product_group.sum()['Quantity Ordered']
products =[product for product, df in product_group]

plt.bar(products, quantity_ordered)
plt.ylabel('Quantity Ordered')
plt.xlabel('Product')
plt.xticks(products, rotation='vertical', size=8)
plt.show()


# In[146]:


# Convert 'Price Each' to numeric, handling errors with coerce to convert non-numeric values to NaN
all_data_cleanest['Price Each'] = pd.to_numeric(all_data_cleanest['Price Each'], errors='coerce')

# Group by 'Product' and calculate the mean of 'Price Each'
prices = all_data_cleanest.groupby('Product')['Price Each'].mean()

# Print the resulting Series with mean prices
fig, ax1 = plt.subplots()

ax2 = ax1.twinx()
ax1.bar(products, quantity_ordered, color='g')
ax2.plot(products, prices, 'b-')

ax1.set_xlabel('Product name')
ax1.set_ylabel('Quantity Ordered', color='g')
ax2.set_ylabel('Price $', color='b')
ax1.set_xticklabels(products, rotation='vertical', size=8)
plt.show()





