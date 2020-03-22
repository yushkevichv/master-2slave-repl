<?php
require_once 'vendor/autoload.php';

use Tarantool\Client\Client;

$client = Client::fromDsn('tcp://tarantool:3301');;

$space = $client->getSpace('tester');

//$result = $space->insert([4, 'Rammstein', 2014]);

printf("Result: %s\n", json_encode($result));

$result1 = $space->select(\Tarantool\Client\Schema\Criteria::key([4]));

var_dump($result1);