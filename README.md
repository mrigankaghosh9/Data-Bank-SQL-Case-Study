# CACE STUDY : DATA BANK CHALLENGE

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/0180e55b-52c3-40f2-a2b8-8d2d54c267f2)


Please check the challenge here: [Data Bank](http://https://8weeksqlchallenge.com/case-study-4/)


# **1. Introduction**

There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team needs your help!

The management team at Data Bank wants to increase their total customer base - but also needs some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth, and helping the business analyze their data in a smart way to better forecast and plan for their future developments!

* Available Data
The Data Bank team have prepared a data model for this case study as well as a few example rows from the complete dataset below to get you familiar with their tables.

---------**Entity Relationship Diagram**----------
![image](https://github.com/ThuHuong-Gina/Data-Bank_-8-week-SQL-Challenge/assets/141025228/e555a140-8874-4ff9-a5f7-ffd974f11bd2)

> The management team at Data Bank wants to increase its total customer base — but also needs some help tracking just how much data storage its customers will need.

# **2. DataBank Structure**

## 2.1 Table 1: Region
Data Bank is run off a network of nodes where both money and data are stored across the globe. In a traditional banking sense — you can think of these nodes as bank branches

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/2031ff05-3f26-4849-b689-3464fc4bffbb)

## 2.2 Table 2: Customer Nodes
Customers are randomly distributed across the nodes according to their region — this also specifies exactly which node contains both their cash and data.
> This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customers’ money and data!

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/1322b91b-7559-451b-b8e2-86d6eb7b40bb)

## 2.3 Table 3: Customer transactions
This table stores all customer deposits, withdrawals, and purchases made using their Data Bank debit card.

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/29ded528-41af-4c78-9120-19695c054b1c)

# **3. DataBank Vizualization**

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/e4154be0-51c9-4f8b-a814-f55483def0f2)

![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/4d115c6d-6a4a-4adb-9031-8a91ef147aff)


# **4. Case Study Questions**
The following case study questions include some general data exploration analysis for the nodes and transactions before diving right into the core business questions and finishes with a challenging final request!

## A. Customer Nodes Exploration
 A financial technology company that helps its consumers with transactional banking services in a novel, more convenient way. 
- DataBank offers banking services like:
  * Deposits
  * Withdrawals
  * Purchases
- DataBank operates in 5 regions: Australia, America, Africa, Asia, and Europe
- There are 5 nodes (or branches) in the data bank system
- 3 regions have the most branches: Australia, America, and Europe. There are also the highest numbers of customers allocated, respectively.
- On average, It takes  14 days for customers to be allocated
- Median, 80th and 95th percentiles for this same reallocation days metric for each region
  
  ![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/c951ab52-309d-4e61-b245-3ee3a0a280d4)
  
* Sercurity
  - DataBank operates on a global network of nodes for secure customer information distribution.
  - Customer data and funds are frequently updated and distributed to reduce risks like online hacking and digital identity risks.
  - Customer allocation is random based on region for an extra layer of security.
  - DataBank continuously improves and refines protocols based on reallocated metrics.
    
## B. Customer Transactions


## C. Data Allocation
In order to expand its customer base, DataBank tested hypotheses and experimented with allocating data to different customer groups using 3 options:
  
    - Option 1: data is allocated based off the amount of money at the end of the previous month
    - Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
    - Option 3: data is updated real-time
    
_Question: How much data would have been required for each option on a monthly basis?_

- Option 1:
  
![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/2ba1c1ea-671d-4809-a897-4fee057b076e)

--> Insight: 
   * There are more deposits than withdrawals and purchases  in all the months which led to lower or negative customer balances   

   * DataBank can leverage this information to identify customer behavious and usage patterns, such as identifying customers who consistently have high data storage needs and target them with promotional offers and special servicea.

- Option 2:
  
![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/fe600bcb-b976-450a-ab47-863c0a96294c)

--> Insight: 
   * There are more withdrawals and purchases than deposits in all the months, which led to lower or negative customer balances which led to lower customer's balances
   * Using this approach may not be suffient becasue the average balance over the previous 30 days is decreasing over time
   * Databank should consider re-evalute their allocation strategy for these customers or consider providing additional data allowances to prevent negative customer experiences.

- Option 3:
  
![image](https://github.com/ThuHuong-Gina/Data-Bank_8-week-SQL-Challenge/assets/141025228/aa1bdcbe-e508-4680-9f4c-617628e70f6b)

--> Insight: 
   * Almost the same as option 2
   * In terms of the allocation of data to customers, this output suggests that more data may be required for the first 2 months of the year.

# 3. Conclusion

`DataBank offers the most advanced security system, making it more safe for customers and enhancing swift and secure transactions.
It can also carry out more tested hypotheses to increase customer base and understand customer's behavious, needs and expectations.`
