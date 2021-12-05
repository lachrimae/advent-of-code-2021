.load ./csv
create virtual table measurements using csv(header=true, filename='numbered.txt');

select count(m1.time)
from measurements m1
join measurements m2
on m2.time - 1 = m1.time
where m2.depth > m1.depth;

select count(m1.time)
from measurements m1
join measurements m4
on m4.time - 3 = m1.time
where m4.depth > m1.depth;
