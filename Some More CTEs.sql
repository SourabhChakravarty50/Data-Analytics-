CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE
);

INSERT INTO employees (employee_id, first_name, last_name, department, salary, hire_date) VALUES
(1, 'John', 'Doe', 'HR', 50000, '2020-01-15'),
(2, 'Jane', 'Smith', 'IT', 80000, '2019-03-10'),
(3, 'Emily', 'Jones', 'Finance', 75000, '2021-07-22'),
(4, 'Michael', 'Brown', 'IT', 85000, '2018-06-12'),
(5, 'Sarah', 'Davis', 'HR', 60000, '2020-02-20'),
(6, 'David', 'Wilson', 'Finance', 70000, '2017-09-25'),
(7, 'Laura', 'Taylor', 'Marketing', 55000, '2021-11-05'),
(8, 'James', 'Anderson', 'Marketing', 65000, '2018-12-18'),
(9, 'Robert', 'Thomas', 'IT', 90000, '2016-05-30'),
(10, 'Linda', 'Jackson', 'Finance', 72000, '2019-08-15');

SELECT*FROM employees;
----------------------------------------------------------

--1. Simple CTE to List All Employees in the IT Department

With it_employees As (
	SELECT employee_id,first_name,last_name,department,salary,hire_date
	FROM employees
	WHERE department='IT'
)
	
SELECT*FROM it_employees;

--2. CTE to Calculate Average Salary by Department

WITH avg_sal_dept AS (
	SELECT department,ROUND( AVG(salary)) AS avg_salary
	FROM employees
	GROUP BY department
)

SELECT e.department,e.first_name,e.last_name,e.salary,d.avg_salary
FROM employees e
JOIN avg_sal_dept d ON d.department = e.department; 

--3. CTE to Find Employees Hired After 2020 with Salary Above Average in Their Department

WITH avg_sal_dept AS (
	SELECT department,ROUND( AVG(salary)) AS avg_salary
	FROM employees
	GROUP BY department
)

SELECT e.employee_id,e.first_name,e.last_name,e.salary,e.hire_date,e.department,d.avg_salary
FROM employees e
JOIN avg_sal_dept d ON d.department = e.department
WHERE e.hire_date >'2020-01-01'
AND e.salary>d.avg_salary;

--4. Find the Most Recently Hired Employee in Each Department

SELECT*FROM employees

WITH recent_hires AS (
    SELECT 
        department,
        first_name,
        last_name,
        hire_date,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY hire_date DESC) AS row_num
    FROM 
        employees
)
-- Select*from recent_hires	
SELECT 
    department,
    first_name,
    last_name,
    hire_date,
	row_num
FROM 
    recent_hires
WHERE 
    row_num = 1;

--5. Calculate the Yearly Salary Increase for Each Employee

WITH salary_increase AS (
    SELECT employee_id,first_name,last_name,department,salary,hire_date,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_worked,
        salary / EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS yearly_increase
    FROM 
        employees
    WHERE 
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) > 0
)
	
SELECT employee_id,first_name,last_name,department,salary,hire_date,years_worked,yearly_increase
FROM salary_increase;

--6. Identify Employees with Salaries Above the Median Salary in Their Department

SELECT*FROM employees

WITH dept_median_salary  AS (
    SELECT*
	,row_number()over(partition by department order by salary asc) as rn_asc
	,row_number()over(partition by department order by salary desc) as rn_desc
    FROM employees
),
median_salary_per_dept AS (
	SELECT department,avg(salary) AS median_salary
	from dept_median_salary
	where (rn_asc-rn_desc)<=1
	group by department
	order by department
)	
SELECT 
    e.employee_id,e.first_name,e.last_name,e.department,e.salary,d.median_salary
FROM 
    employees e
JOIN 
    median_salary_per_dept d ON e.department = d.department
WHERE 
    e.salary > d.median_salary;

--7. List Employees and Their Cumulative Salary by Department
SELECT*FROM employees;

WITH cumulative_salary AS(
	SELECT department,employee_id,first_name,last_name,salary,
	SUM(salary) OVER (PARTITION BY department ORDER BY hire_date) AS cumulative_salary
	FROM employees 
)
SELECT 
    department,employee_id,first_name,last_name,salary,cumulative_salary
FROM 
    cumulative_salary;

--8. Find Departments Where the Total Salary Exceeds a Certain Threshold(200,000)

WITH dept_total_salary AS(
	SELECT department, SUM(salary) AS total_salary
	FROM employees
	GROUP BY department
)
SELECT department,total_salary
FROM dept_total_salary
WHERE total_salary>200000;

--9. Identify Employees with the Longest Tenure

WITH employee_tenure AS(
	SELECT employee_id, first_name,last_name,department,hire_date,
	RANK() OVER(ORDER BY hire_date) AS tenure_rank
	FROM employees
)
SELECT employee_id, first_name, last_name,department,hire_date,tenure_rank
FROM employee_tenure
WHERE tenure_rank=1;


