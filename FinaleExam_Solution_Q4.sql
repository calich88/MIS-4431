/*
Scenario:
Use SQL statements to create a database named “BankingDB” and the four tables described below with appropriate data types and constraints. 
Ensure each table includes at least one primary key and the Transactions table includes foreign keys that reference the Customers and Accounts tables.
- Customers: Contains information about customers.
- Accounts: Contains details of the bank accounts.
- Transactions: Records each transaction made by the customers linking to the Customers and Accounts tables.
- Branches: Lists the branches of the bank.
*/

/*
Question 1 (10 marks):
Task: Create a database named BankingDB and the four tables Customers, Accounts, Transactions, and Branches using SQL statements. 
Ensure each table includes appropriate primary and foreign keys, and data types. Submit the SQL script as part of your answer.
Output: Provide the SQL statements used to create the database and tables.
*/

-- Create database
CREATE DATABASE BankingDB;

-- Connect to the created database
-- \c BankingDB;

-- Create Customers table
CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(50)
);

-- Create Branches table
CREATE TABLE Branches (
    BranchID SERIAL PRIMARY KEY,
    BranchName VARCHAR(100),
    BranchAddress VARCHAR(200)
);

-- Create Accounts table
CREATE TABLE Accounts (
    AccountID SERIAL PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(50),
    Balance DECIMAL(15, 2),
    BranchID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID) ON DELETE SET NULL
);

-- Create Transactions table
CREATE TABLE Transactions (
    TransactionID SERIAL PRIMARY KEY,
    CustomerID INT,
    AccountID INT,
    Amount DECIMAL(15, 2),
    TransactionDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID) ON DELETE CASCADE
);

-----------------------
-----------------------
-- IMPORT DATA
-----------------------
-----------------------
-- Import data into Customers table
COPY Customers(CustomerID, FirstName, LastName, Email, Phone)
FROM 'D:/MIS 443 - Business Data Management/Slide Teaching Q4 2023-2024/Final Exam/csv/Customers_final.csv'
DELIMITER ','
CSV HEADER;

-- Import data into Branches table
COPY Branches(BranchID, BranchName, BranchAddress)
FROM 'D:/MIS 443 - Business Data Management/Slide Teaching Q4 2023-2024/Final Exam/csv/Branches_final.csv'
DELIMITER ','
CSV HEADER;

-- Import data into Accounts table
COPY Accounts(AccountID, CustomerID, AccountType, Balance, BranchID)
FROM 'D:/MIS 443 - Business Data Management/Slide Teaching Q4 2023-2024/Final Exam/csv/Accounts_final.csv'
DELIMITER ','
CSV HEADER;

-- Import data into Transactions table
COPY Transactions(TransactionID, CustomerID, AccountID, Amount, TransactionDate)
FROM 'D:/MIS 443 - Business Data Management/Slide Teaching Q4 2023-2024/Final Exam/csv/Transactions_final.csv'
DELIMITER ','
CSV HEADER;

-- Check tables and attributes
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

/*
Question 2 (10 marks):
Task: List all transactions that occurred in the year 2024 displaying the TransactionID, CustomerID, AccountID, and TransactionDate. 
Arrange the results by TransactionDate in ascending order.
Output:
*/
SELECT TransactionID, CustomerID, AccountID, TransactionDate
FROM Transactions
WHERE EXTRACT(YEAR FROM TransactionDate) = 2024
ORDER BY TransactionDate ASC;

/*
Question 3 (20 marks):
Task: Calculate the total number of transactions made by each customer. Show the customer's ID, name, and their total number of transactions. 
Display the top 5 customers with the highest number of transactions. 
Order the results by the total number of transactions in descending order.
Output:
*/

SELECT Customers.CustomerID, Customers.FirstName, Customers.LastName, COUNT(Transactions.TransactionID) AS TotalTransactions
FROM Customers
JOIN Transactions ON Customers.CustomerID = Transactions.CustomerID
GROUP BY Customers.CustomerID, Customers.FirstName, Customers.LastName
ORDER BY TotalTransactions DESC
LIMIT 5;

/*
Question 4 (20 marks):
Taks: Display the top 5 customers who made the most recent transactions. 
Include the customer's ID, name, and the date of their most recent transaction. 
For customers who haven't made any transactions, their last transaction date should be shown as NULL. 
Order the list by the date of the last transaction in descending order. 
Notes: Using a Common Table Expression (CTE)
Output:
*/
-- Get top 5 customers with the latest transactions
SELECT Customers.CustomerID, Customers.FirstName, Customers.LastName, MAX(Transactions.TransactionDate) AS LastTransactionDate
FROM Customers
LEFT JOIN Transactions ON Customers.CustomerID = Transactions.CustomerID
GROUP BY Customers.CustomerID, Customers.FirstName, Customers.LastName
ORDER BY LastTransactionDate DESC
LIMIT 5;

-- Using a Common Table Expression (CTE) to get the latest transaction date per customer
WITH LatestTransaction AS (
    SELECT CustomerID, MAX(TransactionDate) AS LastTransactionDate
    FROM Transactions
    GROUP BY CustomerID
)
SELECT c.CustomerID, c.FirstName, c.LastName, lt.LastTransactionDate
FROM Customers c
LEFT JOIN LatestTransaction lt ON c.CustomerID = lt.CustomerID
ORDER BY lt.LastTransactionDate DESC
LIMIT 5;

/*
Question 5 (20 marks):
Task: List each transaction, including the customer's ID, name, account type, amount, and the transaction date. 
Order the results by transaction date in descending order.
Output:
*/
SELECT Customers.FirstName, Customers.LastName, Accounts.AccountType, Transactions.Amount, Transactions.TransactionDate
FROM Transactions
JOIN Customers ON Transactions.CustomerID = Customers.CustomerID
JOIN Accounts ON Transactions.AccountID = Accounts.AccountID
ORDER BY Transactions.TransactionDate DESC;

/*
Question 6 (20 marks):
Task: Rank the branches based on the total amount of transactions handled. Display the branch name, total transaction amount, and its rank. 
Branches with the same transaction amount should share the same rank.
*/
SELECT Branches.BranchName, SUM(Transactions.Amount) AS TotalTransactionAmount, 
	RANK() OVER (ORDER BY SUM(Transactions.Amount) DESC) AS Ranking
FROM Transactions
JOIN Accounts ON Transactions.AccountID = Accounts.AccountID
JOIN Branches ON Accounts.BranchID = Branches.BranchID
GROUP BY Branches.BranchID, Branches.BranchName
ORDER BY TotalTransactionAmount DESC;
