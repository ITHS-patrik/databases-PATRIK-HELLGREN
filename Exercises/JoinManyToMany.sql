create table students (
	id int,
	name nvarchar(max)
);

insert into students values (1, 'Thomas');
insert into students values (2, 'Stefan');
insert into students values (3, 'Camilla');
insert into students values (4, 'Daniel');
insert into students values (5, 'Niklas');
insert into students values (6, 'Anna');
insert into students values (7, 'Helena');


create table courses (
	id int,
	name nvarchar(max)
);

insert into courses values (1, 'Python');
insert into courses values (2, 'Databehandling');
insert into courses values (3, 'Databaser');
insert into courses values (4, 'Linjär algebra');


create table studentsCourses(
	studentId int,
	courseId int
)

insert into studentsCourses values(1, 1);
insert into studentsCourses values(3, 1);
insert into studentsCourses values(4, 1);
insert into studentsCourses values(6, 1);
insert into studentsCourses values(1, 2);
insert into studentsCourses values(6, 2);
insert into studentsCourses values(7, 2);
insert into studentsCourses values(1, 3);
insert into studentsCourses values(2, 3);
insert into studentsCourses values(3, 3);
insert into studentsCourses values(4, 3);
insert into studentsCourses values(6, 3);

select * from students;
select * from courses;
select * from studentsCourses;

select 
	s.name as 'Student name',
	c.name as 'Course'
from 
	students s
	join studentsCourses sc on s.id = sc.studentId
	join courses c on c.id = sc.courseId


-- Uppgift 1
-- Select:a ut en lista med de olika kurserna, samt hur många studenter det är på varje kurs.
SELECT 
    c.name AS 'Course Name',
    COUNT(s.id) AS 'Number of Students'
FROM 
    students s
    right JOIN Studentscourses sc ON s.id = sc.studentId
    right JOIN courses c ON c.id = sc.courseId
GROUP BY 
    c.name
ORDER BY 
    c.name;




-- Uppgift 2
-- Select:a ut en lista med de olika studentera, samt hur många kurser varje student går.

select
    students.name as 'Student',
    count(studentId) as 'Number of courses'
from
    studentsCourses
	right JOIN students ON students.id = studentsCourses.studentId
group by
    students.name;


