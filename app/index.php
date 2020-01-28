<?php
$redis = new Redis();

try {
    $redis->connect('redis');
}
catch (\Exception $e)
{
    die($e->getMessage());
}

$redis->set('counter', 0);


$mysqli = new mysqli("mysql_master", "user", "pwd", "test_repl_db");
if ($mysqli->connect_errno) {
    echo "Не удалось подключиться к MySQL: " . $mysqli->connect_error;
}
$mysqli->set_charset('utf8');


if (!($stmt = $mysqli->prepare("INSERT INTO test(id, name) VALUES (null, ?)"))) {
    echo "Не удалось подготовить запрос: (" . $mysqli->errno . ") " . $mysqli->error;
}

$id = 1;
if (!$stmt->bind_param("i", $id)) {
    echo "Не удалось привязать параметры: (" . $stmt->errno . ") " . $stmt->error;
}

for ($id = 1; $id <= 1000000; $id++) {
    if (!$stmt->execute()) {
        echo "Не удалось выполнить запрос: (" . $stmt->errno . ") " . $stmt->error;
        usleep(100);
    }
    else {
        $redis->incr('counter');
        continue;
    }
}

echo "Запрос успешно выполнен \r\n";

$stmt->close();

echo "Количество успешно добавленных записей: ". (int) $redis->get('counter') ."\r\n";