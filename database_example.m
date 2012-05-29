clc; format compact
clear java
javaaddpath('E:\raid\MRI\database\mysql-connector-java-3.1.14\mysql-connector-java-3.1.14-bin.jar')
db_driver = 'com.mysql.jdbc.Driver';
db_url = 'jdbc:mysql://192.168.1.222:3306/tmp';
conn = database('tmp', 'db_user', '8ruke?U$', db_driver, db_url);
for i = 1:1
  db_cmd = [];
  fid = fopen('make_params.m', 'r'); clear a; a = textscan(fid, '%s', 'delimiter' ,'\n'); fclose(fid);
  ins_str = char(a{:});  
%   db_cmd = sprintf('insert into test (name) values ("%s")', ins_str');
%   db_cmd = 'CREATE TABLE test(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), name MEDIUMTEXT,  age INT)';
%   db_cmd = 'DROP TABLE test';
% %   db_cmd = 'ALTER TABLE example ADD file_path VARCHAR(5000)';
% %   db_cmd = 'insert into example (name) values ("asdlfjalksdfjlkasdf")';
% %   db_cmd = 'SELECT ALL * FROM example';
% %   db_cmd = 'show columns from test';
  e = exec(conn, db_cmd);
  e
end

db_cmd = 'select * from test where name like "%thom%" AND name like "%n_spoke = 4%"';
% db_cmd = 'select * from test';
e = exec(conn, db_cmd);
try
  e = fetch(e);
  e.Data
catch
  e.Message
end