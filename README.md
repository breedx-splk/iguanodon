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
```

You can verify then that the app works by running:

`java -jar target/spring-petclinic-rest-2.2.5.jar`



# Running tests

tbd

# Ideas / Future

* test each different exporter in isolation
* gh-pages for results
* automation (maybe nightly?)
* collaboration