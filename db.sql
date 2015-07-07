create database perl_project;
grant usage on perl_project.* to svetlina@localhost;
grant all on perl_project.* to svetlina@localhost
identified by 'work_time'; flush privileges;

mysql -u svetlina -h localhost -p'work_time' perl_project

CREATE TABLE `users` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,  
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
