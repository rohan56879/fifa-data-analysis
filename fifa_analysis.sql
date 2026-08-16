-- use customers;
select * from customers;

-- 1Find the average ova, pot, and age of all players.


select avg(age) as average_age,avg(ova) as average_overall_performancs,avg(pot) as average_potential from customers;


-- 2 Find the number of players in each nationality.

select nationality,count(*) as players from customers group by nationality order by players desc;


-- 3 Find the maximum ova for each positions.


select positions,max(ova)  from customers group by positions;



-- 4 Find players whose ova is greater than 80 and potential_growth is greater than 5.

select `name`,ova,potential_growth from customers where ova>80 and potential_growth>5;


-- 5 Create an age category:

select name,age,case
when age<=21 then 'young'
when age>21 and age<=28 then 'prime'
when age>28 then 'experienced'
end as age_graoup
 from customers;
 
 
 
 -- 6 Find players whose pot is greater than their ova. 
 select name from customers where ova<pot;
 
 
 
 -- 7. Find players whose ova is greater than the overall average OVA of their team.
 
 select name,team,ova from 
( select name,team,ova,avg(ova) over(partition by team) as avg_ova  from customers)t
where ova>avg_ova
;
 
 
 
 -- 8 Find players whose wage is greater than the average wage of all players in a team.
  
 select name from (
 select  team,wage,name,avg(wage)over(partition by team) as avg_wage from customers
 ) t where wage>avg_wage;
 
 
 
 -- 9 Find the player(s) having the highest OVA in the entire dataset.
select max(ova) from customers where ova<(
 select max(ova) from customers);
 
 
 
 -- 10. Rank all players by ova from highest to lowest.
 select name,team,ova, rank() over(partition by team order by ova desc) as rnk from customers;
 
 
 
 -- 11 top 3 players of each teams
 
select team,name, value,rnk from(
select team,name,value, row_number() over(partition by team order by value desc) as rnk from customers )t
where rnk<=3; 




-- 12 Rank players within each team based on OVA.
select name,team,ova,rank() over(partition by team order by ova desc) rnk from customers ; 



# 13 Find the player with the second-highest OVA in each team.
select team,name,ova from (
select team,name,ova, rank() over(partition by team order by ova desc)as rnk  from customers)t
where rnk=2;

-- 14 Calculate the difference between each player's OVA and the average OVA of their team 
select team,name,ova-avg(ova) over(partition by team ) as difference from customers;



-- 15Within each team, compare each player's OVA with the previous player's OVA. 


select *,(ova-previous_player_ova) as diff from 
(select team,name,ova,lag(ova) over(partition by team order by ova) as previous_player_ova from customers)t;




-- # 6 Within each team, compare each player's OVA with the previous player's OVA whose ova is hogher than previous one.


select *,(ova-previous_player_ova) as diff from 
(select team,name,ova,lag(ova) over(partition by team order by ova) as previous_player_ova from customers)t
where (ova-previous_player_ova) >0;



-- 17Find players whose wage is more than 2× their team's average wage.
select name,wage from( 
select name,wage,avg(wage) over(partition by team) as avg_wage from customers )t
where wage>avg_wage*2;




-- 18 A football club wants to identify young players who are currently affordable but have high future potential. Using this dataset, identify the top 20 players who satisfy the following conditions:

-- Age ≤ 23
-- OVA ≥ 70
-- Potential ≥ 80
-- Wage below the overall average wage
-- Rank them using potential growth and value.



with cte as(
select name, row_number() over(order by potential_growth desc,value desc ) as rnk from customers where wage<
(select avg(wage) as avg_wage from customers) and age<=23 and ova>=70 and pot>=80 )
select * from cte where rnk<=20
;