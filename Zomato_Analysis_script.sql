create table golduser (
user_id int,
signup_date date
 );
 insert into golduser values
 (1,"2017-09-22"),
 (3,"2017-04-21");
 
 
create table user (
user_id int,
signup_date date
);

 insert into user values
 (1,"2014-09-02"),
(2,"2015-01-15"),
 (3,"2014-04-11");
 
create table product (
prod_id int,
prod_name varchar(25),
price double
 );
 insert into product values
 (1,'p1', 980.00),
(2,'p2',870.00),
 (3,'p3',330.00);
 

 
create table sales (
user_id int,
created_date date,
prod_id int
 )
 
 insert into sales values
 (1,"2017-04-19",2),
(3,"2019-12-18",1),
 (2,"2020-07-20",3),
(1,"2019-10-23",2),
(1,"2018-03-19",3),
 (3,"2016-12-20",2),
(1,"2016-11-09",1),
(1,"2016-05-20",3),
 (2,"2017-09-24",1),
(1,"2017-03-11",2),
(1,"2016-03-11",1),
 (3,"2016-11-10",1),
(3,"2017-12-07",2),
(3,"2016-12-15",2),
 (2,"2017-11-18",2),
(2,"2018-09-10",3);

#1 overall how much money each customer spend 
select s.user_id,sum(p.price) 
from sales s
join product p on p.prod_id=s.prod_id 
group by user_id

#2 how many days each customer has been visiting on zomato
select user_id , count(distinct(created_date)) 
from sales
group by user_id

#3 what was the first product purchase by customer
select x.user_id,x.created_date,p.prod_name,x.prod_id,x.rnk from (
select *,rank() over(partition by user_id order by created_date) as rnk from sales ) x
join product p on p.prod_id=x.prod_id
having x.rnk = 1

#4 what is the most purchase menu and how many time it is purchase by each customer
select user_id, count(prod_id) from sales 
where prod_id = (select prod_id from sales group by prod_id order by count(prod_id) desc limit 1)
group by user_id

#5 which product is most popular for each customer
select * from 
(select *,rank() over(partition by user_id order by cp desc) as rnk from 
(select user_id, prod_id, count(prod_id) as cp from sales group by user_id, prod_id) x) y
where rnk = 1

#6 which item was first purchase after user become gold member
select * from
(select x.user_id,x.prod_id,rank() over(partition by user_id order by created_date) as rnk from
(select g.user_id,s.created_date,s.prod_id 
from golduser g
inner join sales s on s.user_id = g.user_id and s.created_date > g.signup_date) x ) y
where rnk = 1
 
 #7 what product purchase before user becoming gold member
select * from
(select *,rank() over(partition by user_id order by created_date desc) as rnk from
(select g.user_id,s.created_date,s.prod_id 
from golduser g
inner join sales s on s.user_id = g.user_id and s.created_date < g.signup_date) x ) y
where rnk = 1
  
#8 Total order made and total amount spend by the user before user becoming gold member
select g.user_id,count(s.prod_id),sum(p.price)
from golduser g
inner join sales s on s.user_id = g.user_id and s.created_date < g.signup_date
join product p on p.prod_id = s.prod_id
group by g.user_id

#9 on buying of each product add zomato points 
# p1 5rs = 1point
# p2 10rs = 5point
# p3 5rs = 1point
select z.user_id,z.prod_id,z.sumx,z.points,(z.sumx/z.points) as points_of_cust_fo_each_prod from
(select y.user_id, y.prod_id,y.sumx ,(case when prod_id = 1 then 5 when prod_id=2 then 2 when prod_id=3 then 5 else 0 end) as points from  
(select x.user_id, x.prod_id,sum(x.price) as sumx from
(select s.user_id,s.prod_id,p.price from sales s
inner join product p on p.prod_id = s.prod_id) x
group by  x.user_id, x.prod_id ) y) z

#10 in the first 1 year aftre gold membership how much user have earn the zomato points if (2rs = 1 point)

select g.*,s.created_date,s.prod_id from golduser g
inner join sales s on g.user_id = s.user_id and created_date >= signup_date and signup_date < date_add(year,1,signup_date)
 
