<?php

require_once 'vendor/autoload.php';

use Tarantool\Client\Client;

$start = microtime(true);
testTarantool();
//testMysqlPrepare();
//testMysql();
$end = microtime(true);

echo "total time: ".($end-$start)."\n\r";
echo "max_memory: ".(memory_get_peak_usage()/1024/1024)."\n\r";

function testTarantool()
{
    $client = Client::fromDsn('tcp://tarantool:3301');;

    $space = $client->getSpace('repl_users');

    for ($i = 0; $i< 10000; $i++) {
        $id = rand(1, 1000000);
        $result = $space->select(\Tarantool\Client\Schema\Criteria::key([$id]));
    }

//    var_dump($result);
}

function testMysqlPrepare()
{
    $mysqli = new mysqli("mysql_master", "user", "pwd", "test_repl_db");
    $mysqli->set_charset('utf8');
    $stmt = $mysqli->prepare("SELECT * from users where id = ?");

    for ($i = 0; $i< 10000; $i++) {
        $id = rand(1, 1000000);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
    }

//    var_dump($result);
}

function testMysql()
{
    $mysqli = new mysqli("mysql_master", "user", "pwd", "test_repl_db");
    $mysqli->set_charset('utf8');

    for ($i = 0; $i< 10000; $i++) {
        $id = rand(1, 1000000);
        $result = $mysqli->query("SELECT * from users where id = $id")->fetch_assoc();
//        $stmt->bind_param("i", $id);
//        $stmt->execute();
//        $result = $stmt->get_result()->fetch_assoc();
    }

//    var_dump($result);
}