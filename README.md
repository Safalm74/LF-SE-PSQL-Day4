# PSQL Assignment 4

### A: Common Table Expressions (CTEs):

#### Question: 1  Calculate the average salary by department for all Analysts.
###### Answer:
```
with
	department_salary as ---returns departments and salaries
	(
		select
			ts.unit as department,
			ts.salary as salary
		from
			table_salary ts
		where
			ts.designation='Analyst'
	)
select
	ds.department,
	avg(ds.salary) as Average_Salary
from
	department_salary as ds
group by
	ds.department
order by
	Average_Salary desc;
```
###### Output:
![Question 1](outputs/output_of_question_1.png)

#### Question 2: List all employees who have used more than 10 leaves.
##### Answer:
```
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
	employee_leave.leave_used > 10
order by 
	leave_used;
```
###### Output:
![Question 2](outputs/output_of_question_2.png)


### B: View:

#### Question 3: Create a view to show the details of all Senior Analysts.
##### Answer:
###### Creating View:
```
create view
	senior_Analyst_view as
select
	*
from
	table_salary ts
where
	ts.designation = 'Senior Analyst';
```
###### Reading From View
```
select
	*
from
	senior_Analyst_view;
```
###### Output:
![Question 3](outputs/output_of_question_3.png)

### C: Materialised View:
#### Question 4: Create a materialized view to store the count of employees by department.
##### Answer:
###### Creating View:
```
create materialized view emloyees_count_per_department as
select
	ts.unit as Department,
	count(ts.first_name) as employee_count
from
	table_salary ts
group by
	ts.unit;

```
###### Reading From View
```
select
	*
from
	emloyees_count_per_department
order by
	emloyees_count_per_department.employee_count;
```
###### Output:
![Question 4](outputs/output_of_question_4.png)

### D: Procedures (Stored Procedures):
#### Question 6: Create a procedure to update an employee's salary by their first name and last name.
##### Answer:
###### Creating Procedure:
```
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

```
###### Before Updating
```
select
	ts.first_name,ts.last_name,ts.salary 
from 
	table_salary ts 
where
	ts.first_name ='TOMASA'
and
	ts.last_name ='ARMEN';
```
###### Output: 
![Question 6_1](outputs/output_of_question_6_1.png)

###### Calling Update Function
```
call update_salary('TOMASA','ARMEN',50000);
```
###### After Updating
```
select
	ts.first_name,ts.last_name,ts.salary 
from 
	table_salary ts 
where
	ts.first_name ='TOMASA'
and
	ts.last_name ='ARMEN';
```
###### Output:
![Question 6_2](outputs/output_of_question_6_2.png)

#### Question 7: Create a procedure to calculate the total number of leaves used across all departments.
##### Answer:

##### Using Materialized view
###### Creating Procedure:
```
create or replace procedure calculate_leaves_across_department_view()
language plpgsql
as $$
begin 
	create materialized view if not exists leaves_across_department_view as
	select  unit as department, sum(leave_used) as Total_leave_used_across_department
	from table_salary
	group by unit;
end;$$;
```
##### Procedure calculate_leaves_across_department()
```
call calculate_leaves_across_department_view();
```
##### Reading data
```
select * from leaves_across_department_view ;
```

##### Alternatively, Using table

###### Creating Procedure:
```
create or replace procedure calculate_leaves_across_department_table()
language plpgsql
as $$
begin 
	create table if not exists leaves_across_department_table(
		department varchar (50),
		leave_used_across_department int
	);
	truncate leaves_across_department_table;
	insert into leaves_across_department_table(department ,leave_used_per_department)
	(select  unit as department, sum(leave_used) as Total_leave_used_across_department from table_salary
	group by unit);
end;$$;
```
###### Procedure calculate_leaves_across_department()
```
call calculate_leaves_across_department_table();
```
###### Reading data
```
select * from leaves_across_department_table ;
```

###### Output:
![Question 7](outputs/output_of_question_7.png)

