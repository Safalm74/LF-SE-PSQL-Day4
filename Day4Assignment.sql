create schema Assignment4;

create table
	if not exists table_salary (
		FIRST_NAME varchar(50),
		LAST_NAME varchar(50),
		SEX varchar(50),
		DOJ date,
		CURRENT__DATE date,
		DESIGNATION varchar(50),
		AGE int,
		SALARY int,
		UNIT varchar(50),
		LEAVE_USED int,
		LEAVE_REMAINING int,
		RATING int,
		PAST_EXP int
	);

/*
 *----------------- data was first copied to docker container then loaded
copy table_salary
(FIRST_NAME,LAST_NAME,SEX,DOJ ,CURRENT__DATE ,DESIGNATION ,
AGE ,SALARY ,UNIT ,LEAVE_USED ,LEAVE_REMAINING ,RATING ,PAST_EXP )
from './data/data.csv'
DELIMITER ','
CSV HEADER;
 */
------------------------------data.head()--------------------
select
	*
from
	table_salary ts
limit
	5;

---------------------------------Common Table Expressions (CTEs):-------------------------------
--Question 1: Calculate the average salary by department for all Analysts.
with
	department_salary as ---returns departments and salaries
	(
		select
			ts.unit as department,
			ts.salary as salary
		from
			table_salary ts
	)
select
	ds.department,
	avg(ds.salary) as Average_Salary
from
	department_salary as ds
group by
	ds.department;

--Question 2: List all employees who have used more than 10 leaves.
with
	employee_leave as (
		select
			ts.first_name,
			ts.last_name,
			ts.leave_used
		from
			table_salary ts
	)
select
	*
from
	employee_leave
where
	employee_leave.leave_used > 10;

--------------------------------------------Views:------------------
--Question 3: Create a view to show the details of all Senior Analysts.
--creating view
create view
	senior_Analyst_view as
select
	*
from
	table_salary ts
where
	ts.designation = 'Senior Analyst';

--reading from view
select
	*
from
	senior_Analyst_view;

----------------------------------------------Materialized Views:--------------------------
--Question 4: Create a materialized view to store the count of employees by department.
--creating materialized view
create materialized view emloyees_count_per_department as
select
	ts.unit as Department,
	count(ts.first_name) as employee_count
from
	table_salary ts
group by
	ts.unit;

--using view
select
	*
from
	day4assignment.emloyees_count_per_department;

---------------------------------------------Procedures (Stored Procedures):

--Question 6: Create a procedure to update an employee's salary by their first name and last name.
create or replace procedure update_salary(
	selected_first_name varchar(50),
	selected_last_name varchar(50),
	updated_salary int
)
language plpgsql
as $$
begin 
	update table_salary 
	set salary=updated_salary
	where first_name=selected_first_name
	and last_name=selected_last_name;
	commit;
end;$$;

---------------Before Updating
select
	ts.first_name,ts.last_name,ts.salary 
from 
	table_salary ts 
where
	ts.first_name ='TOMASA'
and
	ts.last_name ='ARMEN';

---------------Calling Update Function
call update_salary('TOMASA','ARMEN',50000);

---------------------After Updating
select
	ts.first_name,ts.last_name,ts.salary 
from 
	table_salary ts 
where
	ts.first_name ='TOMASA'
and
	ts.last_name ='ARMEN';

--Question 7: Create a procedure to calculate the total number of leaves used across all departments.
--creating procedure (using materialized view)
create or replace procedure calculate_leaves_across_department_view()
language plpgsql
as $$
begin 
	create materialized view if not exists leaves_across_department_view as
	select  unit as department, sum(leave_used) as Total_leave_used_across_department
	from table_salary
	group by unit;
end;$$;
call calculate_leaves_across_department_view();
select * from leaves_across_department_view ;
--creating procedure (using materialized view)
create or replace procedure calculate_leaves_across_department()
language plpgsql
as $$
begin 
	create table if not exists leaves_across_department_table(
		department varchar (50),
		leave_used_per_department int
	);
	truncate leaves_across_department_table;
	insert into leaves_across_department_table(department ,leave_used_per_department)
	(select  unit as department, sum(leave_used) as Total_leave_used_across_department from table_salary
	group by unit);
end;$$;
call calculate_leaves_across_department_table();
select * from leaves_across_department_table ;





