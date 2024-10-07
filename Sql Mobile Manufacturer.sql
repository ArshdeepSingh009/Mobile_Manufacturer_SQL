--SQL Advance Case Study

SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_DATE
SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM DIM_MODEL
SELECT * FROM FACT_TRANSACTIONS


--Q1--BEGIN
/*			1. List all the states in which we have customers who have bought cellphones 
			from 2005 till today.
*/       
SELECT L.State,sum(T.Quantity) as Total_By_State FROM DIM_CUSTOMER as C 
inner join FACT_TRANSACTIONS as T 
on C.IDCustomer = T.IDCustomer
inner join DIM_LOCATION as L 
on T.IDLocation = L.IDLocation
where T.Date > '2005-01-01'
group by L.State;





--Q1--END

--Q2--BEGIN
--			What state in the US is buying the most 'Samsung' cell phones?
          select top 1 L.State, sum(T.Quantity) as Total from DIM_LOCATION as L 
		  inner join FACT_TRANSACTIONS as T 
		  on L.IDLocation = T.IDLocation
		  inner join DIM_MODEL as M 
		  on t.IDModel = M.IDModel
		  inner join DIM_MANUFACTURER as DM 
		  on M.IDManufacturer = dm.IDManufacturer
		  where l.Country = 'US'and DM.idManufacturer = 12
		  Group By L.state;
	

--Q2--END

--Q3--BEGIN  
---			Show the number of transactions for each model per zip code per state.		

			select M.IDModel,L.State , sum(Ft.Quantity) as [Transaction] from DIM_LOCATION as L 
			inner join FACT_TRANSACTIONS As Ft 
			on L.idlocation = Ft. idlocation
			inner join DIm_model as M 
			on Ft.IDModel = M.IDModel
			group by L.State, M.IDModel ;

--Q3--END

--Q4--BEGIN
--			Show the cheapest cellphone (Output should contain the price also)

			select  top 1 * from DIM_MANUFACTURER as DM
			inner join DIM_MODEL as M 
			on Dm.IDManufacturer = M.IDManufacturer
			order by m.Unit_price ;

--Q4--END

--Q5--BEGIN
/*			 Find out the average price for each model in the top5 manufacturers in 
			 terms of sales quantity and order by average price.

*/       
        with manufacturer as (
       SELECT top 5 M.IDManufacturer,M.Manufacturer_Name , SUm(F.Quantity) as Total_qyt FROM DIM_MANUFACTURER as M
                     inner join DIM_MODEL as DM 
                     on M.IDManufacturer = Dm.IDManufacturer
					 inner join FACT_TRANSACTIONS as F
					 on Dm.IDModel = F.IDModel
					 group by M.IDManufacturer,M.Manufacturer_Name
					 order by Sum(F.Quantity) desc
                  ),
				  price as (
				  select idmodel,sum(Totalprice) as Total_price from FACT_TRANSACTIONS
				  group by idmodel
				  ),
				  Quantity as (
				   SELECT IDModel, SUM(Quantity) AS TOTAL_QUANTITY FROM FACT_TRANSACTIONS
			       GROUP BY IDModel
                  )
				  SELECT TOP 5 PRICE.IDModel, MANUFACTURER.Manufacturer_Name, DIM_MODEL.Model_Name 
			,TOTAL_PRICE / QUANTITY.TOTAL_QUANTITY AS AVERAGE  FROM PRICE
			INNER JOIN QUANTITY ON PRICE.IDMODEL = QUANTITY.IDMODEL
			INNER JOIN DIM_MODEL ON DIM_MODEL.IDModel = PRICE.IDModel
			INNER JOIN MANUFACTURER ON DIM_MODEL.IDManufacturer = MANUFACTURER.IDManufacturer
			ORDER BY QUANTITY.TOTAL_QUANTITY DESC;
--Q5--END

--Q6--BEGIN
--			 List the names of the customers and the average amount spent in 2009,  
--           where the average is higher than 500 .
              SELECT Distinct C.Customer_Name,T.date, Avg(T.Totalprice) as Avg_Amount FROM DIM_CUSTOMER as C 
               inner join  FACT_TRANSACTIONS as T
			   on C.IDCustomer = T.IDCustomer
			   where  T.Date >='2009' 
			   group by C.Customer_Name,T.Date
			   having Avg(T.Totalprice)>500 ;

			    



--Q6--END
	
--Q7--BEGIN  
/* 			List if there is any model that was in the top 5 in terms of quantity,  
			simultaneously in 2008, 2009 and 2010. 
*/      
                WITH tOP_MODEL_2008 AS
				(
                 select TOP 5  M.Model_Name,M.IDModel,YEAR(f.DATE) AS [YEAR],SUM(f.QUANTITY) AS tOTAL from Dim_model as M
				 INNER JOIN FACT_TRANSACTIONS AS f
		         ON M.IDModel = f.IDModel
				 WHERE YEAR(f.Date) = '2008'
				 GROUP BY M.Model_Name,M.IDModel,YEAR(F.Date)
				 ORDER BY SUM(f.QUANTITY) DESC
				 ),
				 tOP_MODEL_2009 AS (
				 select TOP 5  M.Model_Name,M.IDModel,YEAR(f.DATE) AS [YEAR],SUM(f.QUANTITY) AS tOTAL from Dim_model as M
				 INNER JOIN FACT_TRANSACTIONS AS f
		         ON M.IDModel = f.IDModel
				 WHERE YEAR(f.Date) = '2009'
				 GROUP BY M.Model_Name,M.IDModel,YEAR(F.Date)
				 ORDER BY SUM(f.QUANTITY) DESC
	             ),
				 top_model_2010 as (
				 select TOP 5  M.Model_Name,M.IDModel,YEAR(f.DATE) AS [YEAR],SUM(f.QUANTITY) AS tOTAL from Dim_model as M
				 INNER JOIN FACT_TRANSACTIONS AS f
		         ON M.IDModel = f.IDModel
				 WHERE YEAR(f.Date) = '2010'
				 GROUP BY M.Model_Name,M.IDModel,YEAR(F.Date)
				 ORDER BY SUM(f.QUANTITY) DESC
			    ),
				Common_model as (
				Select Model_name from tOP_MODEL_2008
				intersect
		        Select Model_name from tOP_MODEL_2009
				intersect
				Select Model_name from top_model_2010
				)

				select Model_name from Common_model;
--Q7--END	
--Q8--BEGIN
--			Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer
--          with the 2nd top sales in the year of 2010
			 
			WITH MANUFACTURER_2009 AS (
			SELECT M.Manufacturer_Name,SUM(FT.Quantity) AS TOTAL_QTY FROM DIM_MANUFACTURER as M
			 inner join DIM_MODEL as DM 
			 ON M.IDMANUFACTURER = DM.IDMANUFACTURER
              INNER JOIN  FACT_TRANSACTIONS AS FT 
			  ON DM.IDMODEL = FT.IDMODEL
			  WHERE YEAR(FT.DATE) = '2009'
			  GROUP BY M.Manufacturer_Name
			  ORDER BY suM(FT.QUANTITY) DESC
			  OFFSET 1 ROWS
			FETCH NEXT 1 ROWS ONLY
			),
			 MANUFACTURER_2010 AS (
			 
			SELECT M.Manufacturer_Name,SUM(FT.Quantity) AS TOTAL_QTY FROM DIM_MANUFACTURER as M
			 inner join DIM_MODEL as DM 
			 ON M.IDMANUFACTURER = DM.IDMANUFACTURER
              INNER JOIN  FACT_TRANSACTIONS AS FT 
			  ON DM.IDMODEL = FT.IDMODEL
			  WHERE YEAR(FT.DATE) = '2010'
			  GROUP BY M.Manufacturer_Name
			  ORDER BY suM(FT.QUANTITY) DESC
			  OFFSET 1 ROWS
			FETCH NEXT 1 ROWS ONLY
			  )
           SELECT '2009' AS [YEAR],
         MANUFACTURER_NAME ,TOTAL_QTY  FROM  MANUFACTURER_2009 AS SECOND_top_MANUFACTURER
	   UNION
	   SELECT '2010' AS [YEAR],
	   MANUFACTURER_NAME ,TOTAL_QTY FROM  MANUFACTURER_2010  AS SECOND_top_MANUFACTURER;

--Q8--END
--Q9--BEGIN
---			Show the manufacturers that sold cellphones in 2010 but did not in 2009. 
			
			SELECT M.Manufacturer_Name FROM DIM_MANUFACTURER AS M 
            INNER JOIN DIM_MODEL AS DM 
			ON M.IDManufacturer = DM.IDManufacturer
            INNER JOIN  FACT_TRANSACTIONS AS FT 
			ON DM.IDModel = FT.IDModel
			WHERE YEAR(DATE) = '2010' AND 
			M.Manufacturer_Name NOT IN (
			SELECT M.Manufacturer_Name FROM DIM_MANUFACTURER AS M 
            INNER JOIN DIM_MODEL AS DM 
			ON M.IDManufacturer = DM.IDManufacturer
            INNER JOIN  FACT_TRANSACTIONS AS FT 
			ON DM.IDModel = FT.IDModel
			WHERE YEAR(DATE) = '2009'
			);
			
			

--Q9--END

--Q10--BEGIN
	--		Find top 100 customers and their average spend, average quantity by each year. 
	--       Also find the percentage of change in their spend.	
            
			WITH CustomerYearlyData AS (
			SELECT TOP 100 IDCUSTOMER,
			YEAR(Date) AS purchase_year,
			AVG(TotalPrice) AS avg_spend,
			AVG(quantity) AS avg_quantity
			FROM FACT_TRANSACTIONS
			GROUP BY IDCUSTOMER, YEAR(date)																					  
			)
			SELECT IDCUSTOMER, purchase_year, avg_spend, avg_quantity,
			LAG(avg_spend) OVER (PARTITION BY IDCUSTOMER ORDER BY purchase_year) AS previous_avg_spend,
			((avg_spend - LAG(avg_spend) OVER (PARTITION BY IDCUSTOMER ORDER BY purchase_year)) / 
			LAG(avg_spend) OVER (PARTITION BY IDcustomer ORDER BY purchase_year)) * 100 AS spend_change_percentage
			FROM CustomerYearlyData
			ORDER BY avg_spend DESC
			
			
			

--Q10--END
	
