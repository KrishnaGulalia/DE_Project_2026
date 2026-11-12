SET search_path TO mmt;

-- R23 optimized
-- Sign-in: find the customer by email, ignoring case
-- Optimization: functional index on LOWER(email).
SELECT customer_id, full_name, loyalty_tier
FROM customers
WHERE LOWER(email) = 'siddharth.sharma1021@rediffmail.com';