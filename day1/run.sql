.load ./csv
create virtual table t using csv(filename='numbered.txt');
select count(t2.c0)
from t t1
join t t2
on t2.c0 - 1 = t1.c0
where t2.c1 > t1.c1;

select count(t4.c0)
from t t1
join t t4
on t4.c0 - 3 = t1.c0
where t4.c1 > t1.c1;
