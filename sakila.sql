USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor
ADD COLUMN actor_name varchar(50) DEFAULT NULL,
ALGORITHM=INPLACE, LOCK=NONE;
UPDATE actor SET actor_name = CONCAT(first_name, ' ', last_name);
SELECT actor_name AS 'Actor Name'
FROM actor;
ALTER TABLE actor DROP COLUMN actor_name;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
GROUP BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country, country_id
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description blob,
ALGORITHM=INPLACE, LOCK=NONE;
-- A BLOB can be 65535 bytes (64 KB) maximum
-- A MEDIUMBLOB for 16777215 bytes (16 MB)
-- A LONGBLOB for 4294967295 bytes (4 GB)

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Actors With Same Last Name'
FROM actor
GROUP BY actor.last_name DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor 
GROUP BY actor.last_name HAVING COUNT(*) >=2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name=REPLACE(first_name,'GROUCHO','HARPO') WHERE last_name = 'WILLIAMS';

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name=REPLACE(first_name,'HARPO','GROUCHO') WHERE last_name = 'WILLIAMS';

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- show schema and show table
-- create table
SHOW CREATE TABLE sakila.address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
 

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address 
FROM staff s
INNER JOIN address a
ON (s.address_id  = a.address_id);


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, amount, payment_date 
FROM staff s
INNER JOIN payment p
ON (s.staff_id  = p.staff_id)
WHERE p.payment_date LIKE "2005-08%";

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, COUNT(*) AS "Number Of Actors"
FROM film_actor fa
INNER JOIN film f
ON (fa.film_id  = f.film_id)
GROUP BY f.title DESC;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title,
( SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id ) AS 'Number of copies'
FROM film
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
 -- ![Total amount paid](Images/total_payment.png)
SELECT last_name, SUM(amount) AS "Total amount paid"
FROM customer c
INNER JOIN payment p
ON (c.customer_id  = p.customer_id)
GROUP BY c.last_name 
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title, `name` AS 'Film Langauge'
FROM film f
INNER JOIN `language` l
ON (f.language_id = l.language_id)
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND `name` = 'English';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
SELECT actor_id
FROM film_actor
WHERE film_id IN (
SELECT film_id
FROM film
WHERE title = 'ALONE TRIP'
));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
SELECT address_id
FROM address
WHERE city_id IN (
SELECT country_id
FROM city
WHERE country_id IN (
SELECT country_id
FROM country
WHERE country.country = 'Canada'
)));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN (
SELECT film_id
FROM film_category
WHERE category_id IN (
SELECT category_id
FROM category
WHERE `name` = 'Family'
));

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.title) AS 'popularity'
FROM rental AS r 
JOIN inventory AS i
ON r.inventory_id  = i.inventory_id 
JOIN film AS f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(f.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) as "Total Sales" 
FROM payment AS p
JOIN rental AS r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (i.inventory_id = r.inventory_id)
JOIN store AS s
ON (s.store_id = i.store_id)
GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT * FROM store;

SELECT store.store_id, city.city, country.country 
FROM store 
INNER JOIN address ON store.address_id = address.address_id 
INNER JOIN city ON address.city_id = city.city_id 
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category;


SELECT category.category_id, category.name AS 'GENRE', COUNT(payment.amount) AS 'GROSS REVENUE'
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id 
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category_id DESC
ORDER BY COUNT(payment.amount) DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS (
SELECT category.category_id, category.name AS 'GENRE', COUNT(payment.amount) AS 'GROSS REVENUE'
FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id 
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category_id DESC
ORDER BY COUNT(payment.amount) DESC
LIMIT 5 
);

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;







