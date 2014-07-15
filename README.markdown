## GMail OAuth2 Sinatra

* It should be known that GMail is currently not supported with OAuth2 as far as I can tell.

A small working example of interacting with the Google API using OAuth and Sinatra

## Pre Reqs

Head to https://code.google.com/apis/console/, from the left menu select API Access and create a Client ID

## Run It!

To get this puppy running you just need to:

```bundle install```

then

```G_API_CLIENT=<your_client_id> G_API_SECRET=<your_secret> BASE_URL=<base url(http://.../...)> thin -p <port_number> start```

and then head over to http://localhost:<port_number> and click the 'Auth' link

## If you run behind nginx
```location /oauth2-test {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header Host $http_host;
  
    proxy_pass http://127.0.0.1:<thin_port_number>;
}```
