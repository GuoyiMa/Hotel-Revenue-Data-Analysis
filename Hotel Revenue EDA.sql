USE projects;

/*
	Baseline Query to consolidate data across all tables
*/

with hotels as (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`)
SELECT *
FROM hotels as h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal;

/*
	EDA to build upon consolidated query to answer the question: "Is our hotel revenue growing by year"
*/

-- EDA Query of to single out all important columns for revenue calculation
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
)
SELECT reservation_status, stays_in_week_nights, stays_in_week_nights, 
		(stays_in_week_nights + stays_in_week_nights) AS Number_of_Rooms_Sold,
		adr, c.meal, c.Cost, m.market_segment, Discount
FROM hotels as h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal;


/*
	EDA to investigate data discrepancy in ADR [Used to construct CASE WHEN statement in final query]
*/
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
)
SELECT reservation_status,
		(stays_in_week_nights + stays_in_week_nights) AS Number_of_Rooms_Sold,
		adr, c.meal, c.Cost, m.market_segment, Discount
FROM hotels as h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal
WHERE (adr = 0 OR ADR < 0) AND m.market_segment NOT IN ('Complementary') AND (stays_in_week_nights + stays_in_week_nights) > 0 -- Want to single out ADR = 0, -ve ADR values for Number_of_Rooms_Sold >0 , which is unusual in nature for non-100% discounted customers as typically revenue should be made for such customers and adr should be > 0
ORDER BY adr ASC, Number_of_Rooms_Sold DESC;
/*
	Conclusion: For ADR < 0 -- Highly likely a calculation error/ data discrepancy has occurred. By definition, ADR is a measure of the hotel's revenue and should represent a positive value.
	  For reservation_status = 'Check-Out' OR 'No-Show' OR adr = 0 -- Highly likely that there's a problem with data collection. For example, if ADR = 0, it'll be either that:
				-- 1) Total Room Revenue is zero: This would mean that no revenue was generated from room sales. This is highly unlikely as it indicates an underlying flaw in the pricing model especially when no 100% discount is given to the customers
				-- 2) Number of Rooms Sold is zero even though the guest has either 'Check-Out','No-Show' or 'Canceled' : This is also highly strange as each row entry in the database would constitute as a hotel room being booked. This would imply that a record was made in the database even though no rooms were booked by the guest. As such, it is highly likely a calculation error/ data discrepancy has occurred
		These data discrepancy in ADR will be considered during construction of CASE WHEN to give an accurate revenue calculation
*/

/*
	Query to generate hotel revenue across years by hotel_type with adr column
*/
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
)
SELECT hotel,arrival_date_year,reservation_status, stays_in_weekend_nights, stays_in_week_nights, 
		(stays_in_week_nights + stays_in_weekend_nights) AS Number_of_Rooms_Sold,
		adr, c.meal, c.Cost, m.market_segment, Discount,
		CASE
                WHEN reservation_status = 'Canceled' THEN 0 -- Validated it's 0
				WHEN ADR < 0 THEN 0 -- Validated it's 0
				WHEN (reservation_status = 'Check-Out' OR reservation_status = 'No-Show') AND (adr = 0 OR adr < 0) THEN 0 -- Validated it's 0. If a customer has checked out or no show, ADR should not be less than or equal to 0 as the customer should be billed for such cases and thus will generate revenue for the company.
                ELSE
				( ((stays_in_week_nights + stays_in_weekend_nights) * (adr) * (1 - Discount)) - c.Cost )
            END AS revenue
FROM hotels AS h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal;


/*
	Consolidated query to answer the question: "Is our hotel revenue growing by year", using nested CTEs. Yes, we saw revenue growth from 2018 to 2019, but from 2019 to 2020, we see a decrease in revenue from $11.7M to .$7.2M. This may be due to the influence of COVID-19 pandemic which impacted the hospitality industry [first recorded case of COVID-19 death in Portugal was recorded on 16 MAR 2020]. Alternatively, the dataset is incomplete & does not have complete booking information across the 3 years
*/
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
),
hotel_revenue AS (
SELECT hotel,arrival_date_year,reservation_status,
		(stays_in_week_nights + stays_in_weekend_nights) AS Number_of_Rooms_Sold,
		adr, Discount,
		CASE
                WHEN reservation_status = 'Canceled' THEN 0 -- Validated it's 0. Here we assume that customers who Canceled the reservation did so within the full return window, hence no revenue is generated from such transcations.
				WHEN ADR < 0 THEN 0 -- Validated it's 0. As concluded earlier. For ADR < 0, it's highly likely a calculation error/ data discrepancy has occurred.
				WHEN (reservation_status = 'Check-Out' OR reservation_status = 'No-Show') AND (adr = 0 OR adr < 0) THEN 0 -- Validated it's 0. If a customer has checked out or no show, ADR should not be less than or equal to 0 as the customer should be billed for such cases and thus will generate revenue for the company.
                ELSE
				( ((stays_in_week_nights + stays_in_weekend_nights) * (adr) * (1 - Discount)) - c.Cost )
            END AS revenue
FROM hotels AS h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal
)
SELECT DISTINCT arrival_date_year,
		SUM(revenue) OVER (PARTITION BY arrival_date_year) AS Revenue_by_Year,
		FORMAT(SUM(revenue) OVER (PARTITION BY arrival_date_year),'$0,,.00M') AS Revenue_by_Year_FormattedInMillions
FROM hotel_revenue
ORDER BY arrival_date_year;

/*
	Consolidated query to find the total revenue generated from 2018 - 2020:
*/
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
),
hotel_revenue AS (
SELECT hotel,arrival_date_year,reservation_status,
		(stays_in_week_nights + stays_in_weekend_nights) AS Number_of_Rooms_Sold,
		adr, Discount,
		CASE
                WHEN reservation_status = 'Canceled' THEN 0 -- Validated it's 0. Here we assume that customers who Canceled the reservation did so within the full return window, hence no revenue is generated from such transcations.
				WHEN ADR < 0 THEN 0 -- Validated it's 0. As concluded earlier. For ADR < 0, it's highly likely a calculation error/ data discrepancy has occurred.
				WHEN (reservation_status = 'Check-Out' OR reservation_status = 'No-Show') AND (adr = 0 OR adr < 0) THEN 0 -- Validated it's 0. If a customer has checked out or no show, ADR should not be less than or equal to 0 as the customer should be billed for such cases and thus will generate revenue for the company.
                ELSE
				( ((stays_in_week_nights + stays_in_weekend_nights) * (adr) * (1 - Discount)) - c.Cost )
            END AS revenue
FROM hotels AS h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal
)
SELECT SUM(revenue) AS Total_Revenue,
	FORMAT(SUM(revenue),'$0,,.00M') AS Total_Revenue_FormattedInMillions
FROM hotel_revenue;




