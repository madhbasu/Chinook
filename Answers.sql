select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

1) Find the artist who has contributed with the maximum no of albums. 
Display the artist name and the no of albums.

select artist_name, no_of_albums from
(select a.name as artist_name,count(*) as no_of_albums,
rank() over(order by count(*) desc) as rnk
from artist a
join album alb
on a.artistid=alb.artistid
group by a.name) x
where x.rnk = 1

2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select concat (c.firstname,' ',c.lastname) as full_name,email,country,g.name as genre_name
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
join Invoice i on i.invoiceid = il.invoiceid
join customer c on c.customerid = i.customerid
where g.name in ('Jazz','Rock','Pop')

3) Find the employee who has supported the most no of customers. Display the employee name and designation

select employee_name, designation from
(select concat (e.firstname, ' ',e.lastname)as employee_name,e.title as designation,count(*) as no_of_customer,
rank() over(order by count(*) desc) as rnk
from employee e
join customer c
on e.employeeid=c.supportrepid
group by e.firstname,e.lastname,e.title)
where rnk=1

4) Which city corresponds to the best customers?

select city from
(select i.billingcity as city, sum(total) as most_spend,
rank() over(order by sum(total) desc) as rnk
from invoice i
join customer c
on c.customerid=i.customerid
group by billingcity)
where rnk=1

5) The highest number of invoices belongs to which country?
select country from
(select billingcountry as country,count(*) as no_of_invoice,
rank() over(order by count(*) desc) rnk
from invoice
group by 1)
where rnk = 1

6) Name the best customer (customer who spent the most money).

select customer_name from
(select concat(c.firstname,' ',c.lastname) as customer_name,sum(total) as most_spend,
rank() over(order by sum(total) desc) as rnk
from customer c
join invoice i
on c.customerid=i.customerid
group by 1)
where rnk = 1

7) Suppose you want to host a rock concert in a city and want to know which location should host it.
select city from
(select i.billingcity as city, count(*) as no_of_fans,
rank() over(order by count(*) desc) as rnk
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
join Invoice i on i.invoiceid = il.invoiceid
where g.name in ('Rock')
group by 1)
where rnk = 1


8) Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.
	
select a.name as artist_name,alb.title as album_name, count(*) as no_of_tracks
from artist a
join album alb
on a.artistid=alb.artistid
join track t
on t.albumid=alb.albumid
group by 1,2
having count(*) < 5

9) Display the track, album, artist and the genre for all tracks which are not purchased.

select a.name as artist_name,alb.title as album_name,g.name as genre_name,t.name as track_name
from album alb
join artist a on alb.artistid=a.artistid
join track t on t.albumid=alb.albumid
join genre g on g.genreid=t.genreid
where not exists (select * from invoiceline il
                     where il.trackid = t.trackid)

10) Find artist who have performed in multiple genres. Diplay the artist name and the genre. --doubt
select * from Artist;
select * from Genre;

with cte as
(select distinct a.name as artist_name,g.name as genre
from artist a
join album alb
on a.artistid=alb.artistid
join track t on t.albumid=alb.albumid
join genre g on g.genreid=t.genreid
order by 1,2)
, final_cte as
(select artist_name,count(*)
from cte
group by 1 
having count(*) > 1)
select cte.*
from final_cte
join cte on cte.artist_name = final_cte.artist_name



11) Which is the most popular and least popular genre?
Popularity is defined based on how many times it has been purchased.

select genre_name,rnk from (select g.name as genre_name, count(*) as no_of_purchase,
rank() over(order by count(*) desc) as rnk
from genre g
join track t
on g.genreid=t.genreid
join invoiceline il on il.trackid=t.trackid
group by 1
union all
select g.name as genre_name, count(*) as no_of_purchase,
rank() over(order by count(*) asc) as rnk
from genre g
join track t
on g.genreid=t.genreid
join invoiceline il on il.trackid=t.trackid
group by 1)
where rnk = 1

12) Identify if there are tracks more expensive than others. If there are then
    display the track name along with the album title and artist name for these expensive tracks.


select a.name as artist_name, alb.title as album_name,t.name as track_name
from artist a
join album alb
on a.artistid=alb.artistid
join track t
on t.albumid=alb.albumid
where t.unitprice > (select min(unitprice) from track)

13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]

with genre_cte as
(select genre_name from 
(select g.name as genre_name,count(*) as no_of_purchase,
rank() over(order by count(*) desc) as rnk
from invoiceline il
join track t
on il.trackid=t.trackid
join genre g
on g.genreid=t.genreid
group by 1)
where rnk = 1),
final_cte as
(select a.name as artist_name, count(*) as no_of_songs,
rank() over(order by count(*) desc) as rnk
from artist a
join album alb
on a.artistid=alb.artistid
join track t
on t.albumid=alb.albumid
join genre g
on g.genreid=t.genreid
where g.name in (select genre_name from genre_cte)
group by a.name)
select artist_name,no_of_songs from final_cte
where rnk = 1

14) Find the artist who has contributed with the maximum no of songs/tracks. 
Display the artist name and the no of songs.

select artist_name, no_of_songs from
(select a.name as artist_name, count(*) as no_of_songs,
rank() over(order by count(*) desc) as rnk
from artist a
join album alb
on a.artistid=alb.artistid
join track t
on t.albumid=alb.albumid
group by 1)
where rnk=1

15) Are there any albums owned by multiple artist?

select alb.title as album_name,count(*) as no_of_artist
from album alb
join artist a
on a.artistid=alb.artistid
group by 1
having count(*) > 1

16) Is there any invoice which is issued to a non existing customer?

select * from invoice i
where i.customerid not in (select customerid from customer)

select * from invoice i
where not exists(select * from customer c
where c.customerid = i.customerid)

17) Is there any invoice line for a non existing invoice?

select * from invoiceline i
where i.invoiceid not in(select invoiceid from invoice)

select * from invoiceline il
where not exists (select * from invoice i 
where i.invoiceid=il.invoiceid)

18) Are there albums without a title?

select * from album where title is null

19) Are there invalid tracks in the playlist?

select * from playlisttrack p
where p.trackid not in (select trackid from track)

select * from playlisttrack p
where not exists (select * from track t
where t.trackid=p.trackid)

