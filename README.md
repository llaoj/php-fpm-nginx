## intro
 - 1 a base image
 - 2 installed supervisor, nginx, php-fpm, composer
 - 3 supervisor is the root process which mange other process, like nginx php-fpm and other defined program
 - 4 nginx site conf path: `/etc/nginx/sites-enabled/default`
 - 5 supervisor program conf path: `/etc/supervisor/conf.d/`
 - 6 workdir: `/var/www/html/`
 - 7 php-fpm listen: `listen = 127.0.0.1:9000`

## how to use

due this is a base image, you can use this image like this,

`Dockerfile` demo:

```
FROM llaoj/php-fpm-nginx:tagname

COPY . .

RUN chmod 755 bootstrap.sh

CMD ["bootstrap.sh"]
```

`bootstrap.sh` demo:

```
#!/bin/bash

#nginx site conf
if [ -f $PWD/conf/nginx/default ]; then
  cp $PWD/conf/nginx/default /etc/nginx/sites-enabled/default
fi

#other program process conf, manage by supervisor
if [ -d "$PWD/conf/supervisor/" ]; then
  cp $PWD/conf/supervisor/* /etc/supervisor/conf.d/
fi

exec supervisord -n
```

so, you can build your image like this:

```
docker build -t tagname .
```

besides, you can define a program process (`mns-worker.conf`) like this:

```
[program:mns-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan mns:worker --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=1
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stopsignal=QUIT
```
