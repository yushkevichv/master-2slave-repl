# master-2slave-repl
Set master and 2 slaves. Testing process promote slave to master after killing master

Homework for otus study.

Create in docker 3 mysql instances - 1 master and 2 slaves. Run build.sh, after it check slave statuses. If slave didn't start, we should start it manually. It is random :)

Also exist php-cli instance, redis. 
We run index.php and while script run, we should stop docker container with master mysql (after kill -9 mysqld restart). Before stopping container we should wait some time, because before write ~100 000 records slaves are the same. 
After it we stop write by interrupt php script.  Also we should stop slaves. 

After it we check latest slave (which has more rows) and promote it to master. After it we change master settings on second slave and start it. 
All rows between slaves will be same :) magic :) 
