CREATE DATABASE IF NOT EXISTS gambling_db;

use gambling_db;

-- Question 01: Using the customer table or tab, please write an SQL query that shows Title, First Name and Last Name and Date of Birth for each of the customers.

SELECT
  CONCAT(Title, ' ', FirstName, ' ', LastName) AS FullName,
  DateOfBirth
FROM
  Customer;

-- Question 02: Using customer table or tab, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold). I can see visually that there are 4 Bronze, 3 Silver and 3 Gold but if there were a million customers how would I do this in Excel?
SELECT
  CustomerGroup,
  COUNT(*) AS NumberOfCustomers
FROM
  Customer
GROUP BY
  CustomerGroup;    

-- Question 03: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table but I need to add the currencycode of each player so she will be able to send the right offer in the right currency. Note that the currencycode does not exist in the customer table but in the account table. Please write the SQL that would facilitate this.
-- BONUS: How would I do this in Excel if I had a much larger data set?

SELECT
  c.*,
  a.CurrencyCode
FROM
  Customer c
JOIN
  Account a ON c.CustomerID = a.CustomerID; 

-- Question 04: Now I need to provide a product manager with a summary report that shows, 
-- by product and by day how much money has been bet on a particular product. 
-- PLEASE note that the transactions are stored in the betting table and there is a product code in that table that is required to be looked up (classid & categortyid) to determine which product family this belongs to. Please write the SQL that would provide the report.
-- BONUS: If you imagine that this was a much larger data set in Excel, how would you provide this report in Excel?

SELECT
    b.BetDate,
    p.ProductName,
    SUM(b.Bet_Amt) AS Total_Bet_Amount
FROM
    Betting as b
JOIN
    Product p ON b.ClassID = p.ClassID AND b.CategoryID = p.CategoryID
GROUP BY
    p.Product
    b.BetDate,
ORDER BY
    p.Product
    b.BetDate,;  

-- Question 05: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. 
-- Can you please amend the summary report so that it only summarizes transactions that occurred on or after 1st November 
-- and he only wants to see Sportsbook transactions.Again, please write the SQL below that will do this.
-- BONUS: If I were delivering this via Excel, how would I do this?
 
 SELECT
    b.BetDate,
    p.Product,
    SUM(b.Bet_Amt) AS Total_Bet_Amount
FROM
    Betting as b
JOIN
    Product p ON b.ClassID = p.CLASSID AND b.CategoryID = p.CATEGORYID
WHERE
  b.BetDate >= '2024/11/01' AND p.Product = 'Sportsbook'
GROUP BY
    b.BetDate,
    p.Product
ORDER BY
    b.BetDate,
    p.Product; 
  
-- Question 06: As often happens, the product manager has shown his new report to his director and now he also wants different version of this report. 
-- This time, he wants all of the products but split by the currencycode and customergroup of the customer, 
-- rather than by day and product. 
-- He would also only like transactions that occurred after 1st December. Please write the SQL code that will do this.

 SELECT
    a.CurrencyCode,
    c.CustomerGroup,
    b.BetDate,
    p.Product,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM
    Betting as b
JOIN
  Account AS a
  ON b.AccountNo = a.AccountNo
JOIN
  Customer AS c
  ON a.CustId = c.CustId
JOIN
  Product AS p
  ON b.ClassID = p.ClassID AND b.CategoryID = p.CategoryID
WHERE
  b.BetDate >= '2024/12/01'
GROUP BY
    a.CurrencyCode,
    c.CustomerGroup,
    b.BetDate,
    p.Product
ORDER BY
    a.CurrencyCode,
    c.CustomerGroup,
    p.Product,
    b.BetDate;

-- Question 07: Our VIP team have asked to see a report of all players 
-- regardless of whether they have done anything in the complete timeframe or not. 
-- In our example, it is possible that not all of the players have been active. 
-- Please write an SQL query that shows all players Title, First Name and Last Name 
-- and a summary of their bet amount for the complete period of November.

SELECT
    c.Title,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    SUM(b.Bet_Amt) AS Total_Bet_Amount
FROM
  Customer AS c
LEFT JOIN
  Account AS a ON a.CustId = c.CustId
LEFT JOIN
  Betting AS b ON b.AccountNo = a.AccountNo
WHERE
  c.Status = 'A' AND b.BetDate >= '2024/11/01' AND b.BetDate <= '2024/11/31'
GROUP BY c.FirstName, c.LastName, b.BetDate
ORDER BY
  c.FullName, b.BetDate;

-- Question 08: Our marketing and CRM teams want to measure 
-- the number of players who play more than one product. 
-- Can you please write 2 queries, one that shows the number of products per player 

SELECT 
    c.Title,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    COUNT(p.Product) AS number_products
FROM Product AS p
RIGHT JOIN Betting AS b ON p.ClassID = b.ClassID AND p.CategoryID = b.CategoryID
RIGHT JOIN Account AS a ON b.AccountNo = a.AccountNo
RIGHT JOIN Customer AS c ON a.CustId = c.CustId
GROUP BY c.FirstName, c.LastName
HAVING COUNT(p.Product) > 1
ORDER BY FullName;

-- and another that shows players who play both Sportsbook and Vegas.

SELECT 
    c.Title,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    COUNT(p.Product) AS number_products
FROM Product AS p
RIGHT JOIN Betting AS b ON p.ClassID = b.ClassID AND p.CategoryID = b.CategoryID
RIGHT JOIN Account AS a ON b.AccountNo = a.AccountNo
RIGHT JOIN Customer AS c ON a.CustId = c.CustId
GROUP BY c.FirstName, c.LastName, c.Title
HAVING SUM(CASE WHEN p.Product = 'Sportsbook' THEN 1 ELSE 0 END) > 0
  AND SUM(CASE WHEN p.Product = 'Vegas' THEN 1 ELSE 0 END) > 0
ORDER BY FullName;

-- Question 09: Now our CRM team want to look at players who only play one product, 
-- please write SQL code that shows the players who only play at sportsbook, use the bet_amt > 0 as the key. 
-- Show each player and the sum of their bets for both products.

SELECT 
    c.Title,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    SUM(b.bet_amt) as Total_Bets
FROM Customer as c
INNER JOIN Account AS a ON a.CustId = c.CustId
INNER JOIN Betting AS b ON b.AccountNo = a.AccountNo
INNER JOIN Product AS p ON p.ClassID = b.ClassID AND p.CategoryID = b.CategoryID
WHERE b.bet_amt > 0
GROUP BY c.FirstName, c.LastName, c.Title
HAVING COUNT(DISTINCT p.Product) = 1
   AND p.Product = 'Sportsbook' 
ORDER BY FullName;

-- Question 10: The last question requires us to calculate and determine a player’s favorite product. 
-- This can be determined by the most money staked. 
-- Please write a query that will show each players favorite product.

SELECT
    Title,
    FullName,
    Product AS favorite_product,
    total_staked
FROM (
    SELECT
        c.Title,
        CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
        p.Product,
        SUM(b.Bet_Amt) AS total_staked,
        ROW_NUMBER() OVER ( -- It ranks separately each player and then order it. ROW_NUMBER assigns a number in a predefined order, useful for rankings. ORDER BY order the whole table, but this allows us to order inside the group
            PARTITION BY c.CustId 
            ORDER BY SUM(b.Bet_Amt) DESC
        ) AS ranking
    FROM Customer AS c
    INNER JOIN Account AS a ON a.CustId = c.CustId
    INNER JOIN Betting AS b ON b.AccountNo = a.AccountNo
    INNER JOIN Product AS p ON p.ClassID = b.ClassID AND p.CategoryID = b.CategoryID
    GROUP BY c.CustId, c.Title, c.FirstName, c.LastName, p.Product
) AS ranked_products
WHERE ranking = 1
ORDER BY FullName;

-- Looking at the abstract data on the "Student_School" tab into the Excel spreadsheet
-- This file cannot be used or imported like this. It needs to be separated in two columns using the headers in row 2 and deleting the third row. We can do this with python, stocking the data in two differents df, or Excel. 
-- Once the file is treated, we can import it, so the headers are at first row which MySQL should select the header.

-- Question 11: Write a query that returns the top 5 students based on GPA.

select 
  CONCAT(student_id, ' ', student_name) as Student
  GPA
from student
order by GPA DESC
LIMIT 5;

-- Question 12: Write a query that returns the number of students in each school. 
-- (a school should be in the output even if it has no students!).

select
  CONCAT(sc.school_id, " ", sc.school_name) as School,
  count(s.student_id) as nb_Students
from student as s 
RIGHT JOIN school as sc on sc.school_id = s.school_id 
group by sc.school_id, sc.school_name
order by nb_Students DESC;

-- Question 13: Write a query that returns the top 3 GPA students' name from each university.

select
  CONCAT(sc.school_id, ' ', sc.school_name) as School,
  CONCAT(s.student_id, ' ', s.student_name) as Student,
  s.GPA
from (select s.*, ROW_NUMBER() OVER (PARTITION BY school_id ORDER BY GPA DESC) as rank from student s) s 
JOIN school sc on sc.school_id = s.school_id 
where s.rank <= 3
order by sc.school_name, s.GPA DESC;
