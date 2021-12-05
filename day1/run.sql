.load ./csv
create virtual table t using csv(filename='numbered.txt');
select * from t;

