# iguanodon

Measurements of otel agent overhead.

# Description

We run a [sample app](https://github.com/spring-petclinic/spring-petclinic-rest) 
with and without the agent and perform some measurements:

* transaction throughput (TPM) P95
* GC pauses (number and duration)
* allocation rate

# Setup

```bash
$ git submodule init
$ cd spring-petclinic-reset
$ ./mvnw install
$ brew install k6
```

TBD: You should also stand up a locally runnig collector 

You can verify then that the app works by running:

`java -jar target/spring-petclinic-rest-2.2.5.jar`

and then pointing a browser at http://localhost:9966/petclinic/swagger-ui.html.



# Running tests

tbd

`$ k6 run -u 1 -i 3 k6/basic.js`

# Ideas / Future

* do a jfr recording
* clean out the database between runs
* use a real/external database (mysql or pg via docker)
* test each different exporter in isolation
* gh-pages for results
* automation (maybe nightly?)
* collaboration