#portfolio_project
use project;

#Q1 - who is senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

#Q2 - which countries has most invoices?
select count(billing_country) as c, billing_country from invoice
group by billing_country
order by c desc;

#Q3 - what are top 3 values of invoices?
select * from invoice
order by total desc
limit 3;

#Q4 - which city has best customers? we would like to throw a music festival in the city we made the most money. write a query that returns one city that has highest total invoices.
#return both the city name and the and sum of all invoice total
select billing_city, sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc
limit 1;

#Q5 - who is the best customer? the customer who has spent the most money will be declared the best customer
#write a query that return the person who has spent the most money?
select customer.customer_id, customer.first_name , customer.last_name, sum(invoice.total) as total from customer 
join invoice on 
customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1;

#Q6 - write query to return the email, first name, last name ane genre of all rock music listeners
#return list orderes alphabatically by email starting with A?
select distinct email, first_name, last_name
from customer join invoice on
customer.customer_id = invoice.customer_id
join invoice_line on
invoice.invoice_id = invoice_line.invoice_id
where track_id in 
(select track_id from track 
join genre on
track.genre_id = genre.genre_id
where genre.name = 'rock')
order by email;

#Q7 - let's invite the artist who have written the most rock music in our dataset.
#write a query that returns the artist name and total track count of the top 10 rock bands?
select  artist.name, count(artist.artist_id) as total from artist
join album2 on
artist.artist_id = album2.album_id
join track on
album2.album_id = track.album_id
join genre on 
track.genre_id = genre.genre_id
where genre.name ='rock'
group by artist.name
order by total desc
limit 10;

#Q8 - return all the track names that have a song length longer than the average song length.
#return the name and milliseconds for each track. 
#order by the song length with the longest songs listed first?
select name, milliseconds from track
where milliseconds > (
select avg(milliseconds) from track)
order by milliseconds desc;

#Q9 - Find how much amount spent by each customers on artists? 
#write a query to return customer name, artist name and total spent.

 create temporary table temp_sales(
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales 
from invoice_line
join track on invoice_line.track_id = track.track_id
join album2 on track.album_id = album2.album_id
join artist on album2.artist_id = artist.artist_id
group by artist_id,artist_name
order by 3 desc
limit 1

);
select c.customer_id, c.first_name, c.last_name, artist_name ,sum(il.unit_price* il.quantity)
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track on il.track_id = track.track_id
join album2 on track.album_id = album2.album_id
join temp_sales as ts on album2.artist_id= ts.artist_id
group by 1,2,3,4
order by 5 desc
limit 1;

#Q10 - we want to find out the most popular music genre for each country.
#we determine the most popular genre as the genre witht he highest amount of purchases.
#write a query that returns each country along with the top genre. 
#for countries where the maximum number of purchases is shared return all genre?
create temporary table  sales_per_country As
( select count(*) as purchase_per_genre, customer.country, genre.name, genre.genre_id
from invoice_line join invoice on
invoice.invoice_id = invoice_line.invoice_Id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc);
create temporary table max_genre_per_country as (select max(purchase_per_genre) as max_genre, country
from sales_per_country
group by 2
order by 2 );
select sales_per_country.* from sales_per_country join max_genre_per_country 
on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchase_per_genre = max_genre_per_country.max_genre;
