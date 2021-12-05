.load ./csv
create virtual table t using csv(header=true, filename='numbered.txt');

select count(t1.time)
from t t1
join t t2
on t2.time - 1 = t1.time
where t2.depth > t1.depth;

select count(t1.time)
from t t1
join t t4
on t4.time - 3 = t1.time
where t4.depth > t1.depth;
