# Sample

This is a sample content for broadcasting markdown preview content to browsers.

```js
    var http = require('http');
    http.createServer(function (req, res) {
      res.writeHead(200, {'Content-Type': 'text/plain'});
      res.end('Hello World\n');
    }).listen(1337, '127.0.0.1');
    console.log('Server running at http://127.0.0.1:1337/');
```

:+1: :heart:

- [ ] Figure out wormholes
  - [ ] Call @arfon
  - [ ] Research ([docs](http://en.wikipedia.org/wiki/Wormhole#Time_travel))
  - [ ] Build prototype #15
  - [ ] Test run #43 @world-domination/time-travel
- [x] ...?
- [ ] Profit!
