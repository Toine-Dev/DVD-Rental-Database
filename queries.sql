/* Query 1 - query used for the first slide. */

SELECT
    DATE_PART('month', r.rental_date) AS rental_month,
    DATE_PART('year', r.rental_date) AS rental_year,
    i.store_id AS store_id,
    COUNT(*) AS count_rentals
FROM
    inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY
    DATE_PART('month', r.rental_date),
    DATE_PART('year', r.rental_date),
    i.store_id
ORDER BY
    COUNT(*) DESC;



/* Query 2 - query used for the second slide. */

WITH t1 AS (
    SELECT
        c.customer_id AS customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        SUM(p.amount) AS total_spent
    FROM
        payment p
        JOIN customer c ON p.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.first_name
    ORDER BY
        SUM(p.amount)
        DESC
    LIMIT 10
)
SELECT
    DATE_TRUNC('month', p.payment_date) AS pay_month,
t1.full_name,
COUNT(*) AS pay_countpermonth,
SUM(p.amount) AS pay_amount
FROM
    t1
    JOIN customer c ON t1.customer_id = c.customer_id
    JOIN payment p ON p.customer_id = c.customer_id
GROUP BY
    DATE_TRUNC('month', p.payment_date),
t1.full_name
ORDER BY
    t1.full_name,
    DATE_TRUNC('month', p.payment_date);



/* Query 3 - query used for the third slide. */

WITH t1 AS (
    SELECT
        c.customer_id AS customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        SUM(p.amount) AS total_spent
    FROM
        payment p
        JOIN customer c ON p.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.first_name || ' ' || c.last_name
    ORDER BY
        SUM(p.amount) DESC
    LIMIT 10),
t2 AS (
    SELECT
        DATE_TRUNC('month', p.payment_date) AS pay_month,
        t1.full_name AS full_name,
        COUNT(*) AS pay_countpermonth,
        SUM(p.amount) AS pay_amount
    FROM
        t1
        JOIN customer c ON t1.customer_id = c.customer_id
        JOIN payment p ON p.customer_id = c.customer_id
    GROUP BY
        DATE_TRUNC('month', p.payment_date),
        t1.full_name
    ORDER BY
        t1.full_name,
        DATE_TRUNC('month', p.payment_date)),
t3 AS (
    SELECT
        t2.pay_month AS pay_month,
        t2.full_name AS full_name,
        t2.pay_amount - LAG(t2.pay_amount)
        OVER (PARTITION BY
                t2.full_name
            ORDER BY
                t2.pay_month) AS pay_month_diff
        FROM
            t2
)
SELECT
    t3.pay_month,
    t3.full_name,
    COALESCE(t3.pay_month_diff, 0) AS pay_month_diff
FROM
    t3
ORDER BY
    COALESCE(t3.pay_month_diff, 0) DESC;



/* Query 4 - query used for the fourth slide. */

WITH t1 AS (
    SELECT
        f.film_id AS film_id,
        f.title AS film_title,
        COUNT(*) AS rental_count
    FROM
        film f
        JOIN inventory i ON i.film_id = f.film_id
        JOIN rental r ON r.inventory_id = i.inventory_id
    GROUP BY
        f.film_id,
        f.title
)
SELECT
    t1.film_title AS film_title,
    c.NAME AS category_name,
    t1.rental_count AS rental_count
FROM
    t1
    JOIN film_category fc ON t1.film_id = fc.film_id
    JOIN category c ON c.category_id = fc.category_id
WHERE
    c.NAME IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY
    c.NAME,
    t1.film_title;
