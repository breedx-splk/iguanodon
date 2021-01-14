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
$ cd spring-petclinic-rest
$ ./mvnw install
$ brew install k6
```

To verify that java is working and things have built, 
run the `spring-petclinic-rest` app:

`java -jar target/spring-petclinic-rest-2.2.5.jar`

and then point a browser at http://localhost:9966/petclinic/swagger-ui.html.


## Collector

Some tests run with an agent-instrumented application, and the otel
agent will need some place to send the data.
The easiest way to get going is to run the otel collector via docker:

```
SFX_REALM=<your-realm>
SFX_TOKEN=<your-secret-token>

docker run -it --rm \
	-p 4317:4317 -p 55679-55680:55679-55680 -p 6060 -p 7276 -p 8888 -p 9411 -p 9943 \
	-v /path/to/signalfx-collector.yaml:/etc/collector.yaml:ro \
	-e SFX_REALM=${SFX_REALM} \
	-e SFX_TOKEN=${SFX_TOKEN} \
	--name otelcontribcol otel/opentelemetry-collector-contrib:0.13.0 \
	--config /etc/collector.yaml \
	--mem-ballast-size-mib=683
```


# Running tests

There is a script that runs a single pass test, either with or without the agent:

```
./bin/run-test.sh <with-agent | no-agent>
```

This script does the following:
1. Finds the local IP address
1. Starts up the `spring-petclinic-rest` app by running either `run-app-no-agent.sh` or `run-app-with-agent.sh`
1. Poll until the app returns success
1. Runs [k6](https://k6.io/) with the `k6/basic.js` script.
1. When the test run is complete it terminates the `spring-petclinic-reset` app.

# Test outputs

After a test run is complete, we have the following outputs:

* no-agent.jfr - JFR recording data from the run without agent
* no-agent.json - k6 output data from run without agent
* with-agent.jfr - JFR recording data from the run with agent
* with-agent.json - k6 output data from run with agent

# Analysis

tbd how to interpret/read the data
tbd show how to load and look at jfr in jmc

# Ideas / Future

* use a real/external database (mysql or pg via docker)
* test each different exporter in isolation
* with and without jdbc
* gh-pages for results
* automation (maybe nightly?)
* collaboration