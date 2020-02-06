CREATE USER 'pol'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL ON *.* TO 'pol'@'%' WITH GRANT OPTION;
