Source tree for the web display.

In this directory, you can run:

```
$ npm install
$ npm run build
```

The build output will be copied over to `../web/` in this repo.

To view the results in your browser, go to the parent directory 
of iguanodon and run:
```
$ python3 -m http.server
```

## Deploying changes
The user should then ensure that this is copied over to the `gh-pages` branch as well. 
There is no automation for this presently.