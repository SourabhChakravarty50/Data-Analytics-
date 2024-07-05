Select* From employee;

-- Q1: Who is the senior most employee based on job title?
Select*From employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices? 
Select* from invoice;

Select count(*) as Count_invoice, billing_country
	from invoice
	group by billing_country
	order by Count_invoice desc ;

--Q3: What are the top 3 values of total invoices?
Select total 
from invoice 
order by total desc
limit 3;

--Q4: Which city has the best customers ? (city name & total invoice)
SELECT sum(total) as invoice_total, billing_city
FROM invoice
group by billing_city
order by invoice_total desc;

--Q5: who is the best customer ?(customer who have spent the most money)
select*from invoice;

Select sum(total) as invoice_total, customer_id
from invoice
group by customer_id
order by invoice_total desc;

Select*from customer;

Select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total
From customer
Join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
--     email in alphabatical order, first_name,last_name,genre rock music listener, 

Select*from customer;
Select*from invoice;
select*from invoice_line;
Select*from track;
Select*from genre;

Select genre_id from genre where name like 'Rock';
Select distinct track_id from track where genre_id ='1';

Select Distinct email, first_name, last_name
from customer
Join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in
(
	Select distinct track_id 
	from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'   

)
order by email asc;

--Q7: Write a query that returns the Artist name and total track count of the top 10 rock bands.
--    Artist name ,total track count . top 10 rock bands , genre is rock ?
Select*from artist;
Select*from album;
Select*from track;


Select artist.artist_id,artist.name, count(artist.artist_id) as Number_of_songs
	from track
	join album on album.album_id= track.album_id
	join artist on artist.artist_id= album.artist_id
	join genre on genre.genre_id= track.genre_id
where track_id in
(
	Select distinct track_id 
	from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'   

)
Group by artist.artist_id
order by Number_of_songs desc
Limit 10; 

-- Q8: Return all the track names that have a song length longer than the average song length.
-- Track name which have song length larger than the average song length ,(name , milliseconds)
Select*from Track;

Select name, milliseconds
from track
where milliseconds > ( Select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;

--Q9:Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

-- best selling artist_id, artist name and total_sales
WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS Artist_ID,
        artist.name AS Artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON album.album_id = track.album_id
    JOIN 
        artist ON album.artist_id = artist.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_sales DESC
    LIMIT 1
)
-- amount spent by each customer 
	
SELECT 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM 
    invoice
JOIN 
    customer ON customer.customer_id = invoice.customer_id
JOIN 
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN 
    track ON track.track_id = invoice_line.track_id
JOIN 
    album ON album.album_id = track.album_id
JOIN 
    best_selling_artist ON best_selling_artist.Artist_ID = album.artist_id
GROUP BY 
    customer.customer_id, customer.first_name, customer.last_name
ORDER BY 
    total_spent DESC;

--Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--     with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--     the maximum number of purchases is shared return all Genres.

WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchase,
        customer.country,
        genre.genre_id,
        genre.name,
        ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no
    FROM 
        invoice_line
    JOIN 
        invoice ON invoice_line.invoice_id = invoice.invoice_id
    JOIN 
        customer ON invoice.customer_id = customer.customer_id
    JOIN 
        track ON invoice_line.track_id = track.track_id
    JOIN 
        genre ON track.genre_id = genre.genre_id
    GROUP BY 
        customer.country, genre.genre_id, genre.name
	ORDER BY country ASC, purchase DESC
)
SELECT * 
FROM popular_genre 
	WHERE row_no<=1
;

--Q3: Write a query that determines the customer that has spent the most on music for each country. 
--    Write a query that returns the country along with the top customer and how much they spent. 
--    For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_with_country AS(
	SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	ROW_NUMBER()OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS Row_no
	FROM invoice
	JOIN customer ON customer.customer_id= invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT*FROM customer_with_country WHERE Row_no<=1;