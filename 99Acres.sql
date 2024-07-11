-- Table1 Queries

-- 1. Retrieve properties with balconies, sorted by the number of bedrooms in descending order.
SELECT *
FROM Table1
WHERE Balcony > 0
ORDER BY Beds DESC;

-- 2. Find the top 5 cities with the highest average number of bedrooms per property.
SELECT City, AVG(Beds) AS Avg_Beds
FROM Table1
GROUP BY City
ORDER BY Avg_Beds DESC
LIMIT 5;

-- 3. Count the number of properties in each city.
SELECT City, COUNT(*) AS Property_Count
FROM Table1
GROUP BY City;

-- 4. Retrieve all properties with at least 3 bedrooms and 2 bathrooms.
SELECT *
FROM Table1
WHERE Beds >= 3 AND Bathroom >= 2;

-- 5. Find properties in a specific state with a certain landmark.
SELECT *
FROM Table1
WHERE State_code = 'KA' AND Landmarks LIKE '%Park%';

-- Table2 Queries

-- 1. Calculate the average price per square foot for properties built before 2010.
SELECT AVG(price_per_square_feet) AS Avg_Price_Per_SqFt
FROM Table2
WHERE Year_Built < 2010;

-- 2. Find the total number of properties on each floor.
SELECT floor, COUNT(*) AS Property_Count
FROM Table2
GROUP BY floor;

-- 3. Retrieve properties with a carpet area greater than 1000 square feet and a status of 'Under Construction'.
SELECT *
FROM Table2
WHERE carpetarea > 1000 AND status = 'Under Construction';

-- 4. Calculate the average price per square foot for each transaction type.
SELECT transaction_type, AVG(price_per_square_feet) AS Avg_Price_Per_SqFt
FROM Table2
GROUP BY transaction_type;

-- 5. Find the properties with the highest price per square foot, sorted in descending order.
SELECT *
FROM Table2
ORDER BY price_per_square_feet DESC;

-- Table3 Queries

-- 1. Retrieve all properties with a furnished status of 'Fully Furnished' and a facing direction of 'East'.
SELECT *
FROM Table3
WHERE furnished_status = 'Fully Furnished' AND facing = 'East';

-- 2. Calculate the average booking amount for properties with and without car parking.
SELECT 
    CASE WHEN Car_Parking > 0 THEN 'With Car Parking' ELSE 'Without Car Parking' END AS Parking_Status,
    AVG(booking_amount) AS Avg_Booking_Amount
FROM Table3
GROUP BY Car_Parking > 0;

-- 3. Find the total price of properties with different types of ownership.
SELECT Type_of_ownership, SUM(buy_total_price) AS Total_Price
FROM Table3
GROUP BY Type_of_ownership;

-- 4. Retrieve properties with a booking amount greater than 50000 and a furnished status of 'Semi Furnished'.
SELECT *
FROM Table3
WHERE booking_amount > 50000 AND furnished_status = 'Semi Furnished';

-- 5. Find the property with the highest booking amount.
SELECT *
FROM Table3
ORDER BY booking_amount DESC
LIMIT 1;

-- Join Queries

-- 1. Retrieve properties from Table1 that have a higher price per square foot than the average price per square foot in Table2.
SELECT t1.*
FROM Table1 t1
JOIN Table2 t2 ON t1.Sno = t2.Sno
WHERE t2.price_per_square_feet > (SELECT AVG(price_per_square_feet) FROM Table2);

-- 2. Find the properties in Table1 that are located in cities where the average price per square foot in Table2 is higher than the overall average price per square foot.
SELECT t1.*
FROM Table1 t1
WHERE t1.City IN (
    SELECT City
    FROM Table2 t2
    JOIN Table1 t1 ON t2.Sno = t1.Sno
    GROUP BY City
    HAVING AVG(t2.price_per_square_feet) > (SELECT AVG(price_per_square_feet) FROM Table2)
);

-- 3. Retrieve properties from Table1 with a certain landmark that have a lower price per square foot than the average price per square foot for properties with the same landmark in Table2.
SELECT t1.*
FROM Table1 t1
JOIN Table2 t2 ON t1.Sno = t2.Sno
WHERE t1.Landmarks LIKE '%Park%'
  AND t2.price_per_square_feet < (
      SELECT AVG(t2_inner.price_per_square_feet)
      FROM Table2 t2_inner
      JOIN Table1 t1_inner ON t2_inner.Sno = t1_inner.Sno
      WHERE t1_inner.Landmarks LIKE '%Park%'
  );

-- 4. Retrieve properties from Table2 with a price per square foot higher than the average booking amount in Table3.
SELECT t2.*
FROM Table2 t2
WHERE t2.price_per_square_feet > (SELECT AVG(booking_amount) FROM Table3);

-- 5. Count the number of properties in Table2 with more bedrooms than the maximum number of bedrooms in Table3.
SELECT COUNT(*)
FROM Table2 t2
JOIN Table1 t1 ON t2.Sno = t1.Sno
WHERE t1.Beds > (SELECT MAX(Beds) FROM Table3);

-- 6. Find the cities where the average booking amount in Table3 is higher than the overall average booking amount, and retrieve properties from Table1 located in those cities.
SELECT t1.*
FROM Table1 t1
WHERE t1.City IN (
    SELECT t1.City
    FROM Table1 t1
    JOIN Table3 t3 ON t1.Sno = t3.Sno
    GROUP BY t1.City
    HAVING AVG(t3.booking_amount) > (SELECT AVG(booking_amount) FROM Table3)
);

-- 7. Retrieve properties from Table1 with a furnished status of 'Unfurnished' and a facing direction that does not exist in Table3.
SELECT t1.*
FROM Table1 t1
WHERE t1.Sno IN (
    SELECT t3.Sno
    FROM Table3 t3
    WHERE t3.furnished_status = 'Unfurnished' 
      AND t3.facing NOT IN (SELECT DISTINCT facing FROM Table3)
);
