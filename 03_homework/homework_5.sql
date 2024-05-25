
-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

SELECT 
	vendor_name,
	product_name,
	original_price * 5 * number_of_customers as earning_per_product 
FROM (
	SELECT DISTINCT 
		vendor_id,
		product_id,
		original_price,
		number_of_customers
	FROM
		vendor_inventory as vi
	CROSS JOIN (
		SELECT 
		count(DISTINCT (customer_id)) AS number_of_customers
		FROM customer ) as nc
) as a

INNER JOIN product as p
ON a.product_id = p.product_id
INNER JOIN vendor as v
ON v.vendor_id = a.vendor_id


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS product_units;
CREATE TABLE IF NOT EXISTS product_units AS
SELECT 
    product_id,
    product_name,
    product_size,
    product_category_id,
    product_qty_type,
    CURRENT_TIMESTAMP AS snapshot_timestamp
FROM 
    product
WHERE 
    product_qty_type = 'unit'


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units
VALUES(
	(SELECT product_id FROM product WHERE lower(product_name) = 'apple pie'),
	'Apple Pie',
	'10"',
	(SELECT product_category_id FROM product_category WHERE lower(product_category_name) = 'packaged prepared food'),
	'unit',
	CURRENT_TIMESTAMP
	)


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE from product_units
WHERE product_name = 'Apple Pie'
	AND snapshot_timestamp = (
		SELECT MIN(snapshot_timestamp)
		FROM product_units
		WHERE product_name = 'Apple Pie')


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */


UPDATE product_units
SET current_quantity = COALESCE((
        SELECT quantity
        FROM vendor_inventory
        WHERE product_id = product_units.product_id
        ORDER BY market_date DESC
        LIMIT 1
    ), 0)