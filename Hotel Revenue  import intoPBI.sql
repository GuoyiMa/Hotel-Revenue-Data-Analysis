USE projects;

/*
	Final SQL Query #1 to import into PowerBI for dashboard creation. Includes all 5 categorical query output and every single column existing within the original dataset, also lumps data from 2018-2020 together via UNION ALL.
*/
-- Final Query lump:
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
),
hotel_all_column_amalgated AS (
SELECT
-- Selecting all original columns
hotel, is_canceled,	lead_time,	arrival_date_year,	arrival_date_month,	arrival_date_week_number,	arrival_date_day_of_month,	stays_in_weekend_nights,	stays_in_week_nights,
adults,	children	,babies	, h.meal	,country,	h.market_segment,	distribution_channel,	is_repeated_guest,	previous_cancellations,	previous_bookings_not_canceled,	reserved_room_type,	assigned_room_type,	booking_changes,	deposit_type,	agent,	company	days_in_waiting_list,	customer_type,	adr,	required_car_parking_spaces,	total_of_special_requests,	reservation_status,	reservation_status_date, Cost, Discount,

-- guest_type column creation
		CASE
				WHEN adults = 1 AND children = 0 AND babies = 0 THEN 'Single'
				WHEN adults = 2 AND children = 0 AND babies = 0 THEN 'Couple'
				WHEN adults > 2 AND children = 0 AND babies = 0 THEN 'Group'
				ELSE 'Family'
		END AS guest_type,
		
-- region column creation
		CASE 
        WHEN country IN ('ISR', 'SYR', 'JOR', 'SAU', 'ARE', 'LBN', 'IRQ', 'KWT', 'QAT', 'OMN', 'BHR', 'PSE', 'YEM', 'TUR','IRN') THEN 'Middle East'
        WHEN country IN ('BOL', 'CHL', 'COL', 'AND', 'ARG', 'PRY', 'URY', 'VEN', 'BRA', 'PER', 'ECU', 'BHS', 'BLZ', 'CRI', 'CUB', 'DOM', 'SLV', 'GRD', 'GTM', 'HTI', 'HND', 'JAM', 'MEX', 'NIC', 'PAN', 'TTO', 'ATG', 'BRB', 'DMA', 'VCT', 'GUY', 'SUR') THEN 'South America'
        WHEN country IN ('USA', 'CAN', 'MEX', 'PRI', 'CRI') THEN 'North America'
        WHEN country IN ('CHN', 'HKG', 'MAC', 'TWN', 'PRK', 'KOR', 'JPN', 'MNG', 'CN', 'TWN', 'PRK', 'KOR', 'JPN', 'MNG') THEN 'East Asia'
        WHEN country IN ('KHM', 'LAO', 'THA', 'VNM', 'IDN', 'PHL', 'BRN', 'MYS', 'SGP', 'LKA', 'VNM', 'THA', 'IDN','MMR','TMP') THEN 'Southeast Asia'
        WHEN country IN ('AUS', 'NZL', 'FJI', 'PNG','ASM') THEN 'Oceania'
        WHEN country IN ('GBR', 'FRA', 'DEU', 'ESP', 'ITA', 'NLD', 'BEL', 'PRT', 'CHE', 'AUT', 'SWE', 'DNK', 'NOR', 'FIN', 'IRL', 'POL', 'CZE', 'HUN', 'SVK', 'SVN', 'GRC', 'ROU', 'BGR', 'EST', 'LVA', 'LTU', 'LUX', 'HRV', 'MLT', 'CYP', 'MKD', 'SMR', 'BIH', 'ALB', 'MNE', 'GIB', 'GGY', 'JEY', 'IMN', 'RUS','ARM') THEN 'Europe'
        WHEN country IN ('DEU', 'POL', 'CZE', 'SVK', 'AUT', 'HUN', 'SVN', 'FIN', 'NLD', 'CHE', 'LIE') THEN 'Central Europe'
        WHEN country IN ('GBR', 'IRL', 'NLD', 'BEL', 'LUX', 'PRT') THEN 'Western Europe'
        WHEN country IN ('POL', 'CZE', 'SVK', 'HUN', 'SVN', 'EST', 'LVA', 'LTU', 'BLR','UKR') THEN 'Eastern Europe'
        WHEN country IN ('FRA', 'ESP', 'AND', 'MCO', 'ITA') THEN 'Southern Europe'
        WHEN country IN ('NOR', 'SWE', 'DNK', 'FIN', 'ISL', 'EST', 'LVA', 'LTU') THEN 'Northern Europe'
        WHEN country IN ('ZAF', 'NGA', 'EGY', 'DZA', 'KEN', 'ETH', 'GHA', 'MAR', 'UGA', 'CMR', 'TUN', 'SEN', 'CIV', 'NER', 'MLI', 'AGO', 'TZA', 'MOZ', 'ZMB', 'MUS', 'SDN', 'RWA', 'BEN', 'TGO', 'SSD', 'BFA', 'NAM', 'GIN', 'MWI', 'COG', 'GAB', 'STP', 'ZWE', 'TCD', 'SOM', 'LBY', 'SWZ', 'LSO', 'GMB', 'GNB', 'CPV', 'CIV', 'TGO', 'SLE', 'TUN', 'MAR', 'DZA', 'LBY', 'EGY','CAF') THEN 'Africa'
        WHEN country IN ('TUN', 'MAR', 'DZA', 'LBY', 'EGY') THEN 'North Africa'
        WHEN country IN ('ZAF', 'NAM', 'BWA', 'LSO', 'SWZ', 'MOZ', 'ZMB') THEN 'Southern Africa'
        WHEN country IN ('KEN', 'UGA', 'TZA', 'RWA', 'BDI', 'SSD', 'DJI', 'SOM', 'ETH', 'ERI', 'COM') THEN 'East Africa'
        WHEN country IN ('NGA', 'GHA', 'CIV', 'BFA', 'SEN', 'GIN', 'MLI', 'TGO', 'BEN', 'NER', 'GMB', 'GNB', 'MLI','MRT') THEN 'West Africa'
		WHEN country IN ('BGD','IND','MDV','NPL','PAK') THEN 'South Asia'
		WHEN country IN ('KAZ', 'AZE','TJK','UZB') THEN 'Central Asia'
        WHEN country IN ('FRO') THEN 'Nordic Countries'
        WHEN country IN ('GEO') THEN 'Caucasus'
		WHEN country IN ('KIR','NCL','PLW','PYF','UMI') THEN 'Oceania' 
        WHEN country IN ('MDG','MYT','SYC') THEN 'East Africa' 
        WHEN country IN ('SRB') THEN 'Balkans'
        WHEN country IN ('ABW', 'CYM', 'GLP', 'KNA', 'LCA', 'PRI', 'BRB', 'VGB', 'BLZ', 'VCT', 'GRD', 'DMA', 'CUW', 'MTQ', 'MSR', 'AIA', 'TCA', 'ATG', 'SXM', 'KNA', 'MAF', 'BRB','VGB') THEN 'Caribbean'
		WHEN country IN ('NULL','ATA','ATF') THEN 'Unknown' -- NULL values, here the field is literally called NULL, so I can't use IS NULL here. ATA is Antarctica and ATF is French Southern and Antartic Islands
		ELSE 'Other'
    END AS region,
	
-- seasons column creation
		CASE
				WHEN arrival_date_month IN ('December', 'January', 'February') THEN 'Winter'
				WHEN arrival_date_month IN ('March', 'April', 'May') THEN 'Spring'
				WHEN arrival_date_month IN ('June', 'July', 'August') THEN 'Summer'
				WHEN arrival_date_month IN ('September', 'October', 'November') THEN 'Autumn'
		END AS seasons,
		
-- arrival_date and day_of_week columns creation
 
		STR_TO_DATE(CONCAT(arrival_date_year, '-', arrival_date_month, '-', arrival_date_day_of_month), '%Y-%m-%d') AS arrival_date, -- concat and convert year,month, day of month into date format
    CASE DAYOFWEEK(STR_TO_DATE(CONCAT(arrival_date_year, '-', arrival_date_month, '-', arrival_date_day_of_month), '%Y-%m-%d'))
		WHEN 1 THEN 'Sunday'
		WHEN 2 THEN 'Monday'
		WHEN 3 THEN 'Tuesday'
		WHEN 4 THEN 'Wednesday'
		WHEN 5 THEN 'Thursday'
		WHEN 6 THEN 'Friday'
		WHEN 7 THEN 'Saturday'
		ELSE 'Invalid Day'
	END AS day_of_week,
	
-- Number_of_Rooms_Sold and revenue columns creation

	(stays_in_week_nights + stays_in_weekend_nights) AS Number_of_Rooms_Sold,
		CASE
                WHEN reservation_status = 'Canceled' THEN 0 -- Validated it's 0. Here we assume that customers who Canceled the reservation did so within the full return window, hence no revenue is generated from such transcations.
				WHEN ADR < 0 THEN 0 -- Validated it's 0. As concluded earlier. For ADR < 0, it's highly likely a calculation error/ data discrepancy has occurred.
				WHEN (reservation_status = 'Check-Out' OR reservation_status = 'No-Show') AND (adr = 0 OR adr < 0) THEN 0
                ELSE
				( ((stays_in_week_nights + stays_in_weekend_nights) * (adr) * (1 - Discount)) - c.Cost )
            END AS revenue
			

FROM hotels AS h
LEFT JOIN market_segment AS m ON h.market_segment = m.market_segment
LEFT JOIN meal_cost AS c ON h.meal = c.meal
)
SELECT *
FROM hotel_all_column_amalgated;

/*
	QUERY END
*/

/*
	Final SQL Query #2 imported into PowerBI for dashboard creation. Provides the count of rows of reservation status for Parking Percentage Calculation.
*/
WITH hotels AS (
	select * from `2018`
	union
	select * from `2019`
	union
	select * from `2020`
),
hotel_all_columns_with_revenue AS (
SELECT hotel, is_canceled,	lead_time,	arrival_date_year,	arrival_date_month,	arrival_date_week_number,	arrival_date_day_of_month,	stays_in_weekend_nights,	stays_in_week_nights,
 (stays_in_week_nights + stays_in_weekend_nights) AS Number_of_Rooms_Sold,
adults,	children	,babies	, h.meal	,country,	h.market_segment,	distribution_channel,	is_repeated_guest,	previous_cancellations,	previous_bookings_not_canceled,	reserved_room_type,	assigned_room_type,	booking_changes,	deposit_type,	agent,	company	days_in_waiting_list,	customer_type,	adr,	required_car_parking_spaces,	total_of_special_requests,	reservation_status,	reservation_status_date, Cost, Discount,
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
SELECT * 
FROM hotel_all_columns_with_revenue
