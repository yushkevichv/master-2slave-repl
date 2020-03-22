<?php

$mysqli = new mysqli("mysql_master", "user", "pwd", "test_repl_db");
if ($mysqli->connect_errno) {
    echo "Не удалось подключиться к MySQL: " . $mysqli->connect_error;
}
$mysqli->set_charset('utf8');

$mysqli->query("CREATE TABLE `test_repl_db`.`users` 
    ( 
        `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT , 
        `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL , 
        PRIMARY KEY (`id`)
    ) ENGINE = InnoDB;");


//