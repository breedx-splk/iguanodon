# iguanodon

<img src="https://raw.githubusercontent.com/breedx-splk/iguanodon/main/doc/iguanodon.svg" width="200" alt="iguanadon"/>

Measurements of otel agent overhead.

# Description

We run a [sample app](https://github.com/spring-petclinic/spring-petclinic-rest) 
with and without the agent and perform some measurements. Goals ultimately
include the desire to compare overhead of:

* transaction throughput (TPM) - average and P95
* GC pauses (number and total duration)
* memory allocation rate

# Setup

```bash
$ git submodule init
$ git submodule update
$ cd spring-petclinic-rest
$ ./mvnw install
$ brew install k6
$ brew install jq
```

You should also install [JDK Mission Control](https://adoptopenjdk.net/jmc) if you don't already have it.

To verify that java is working and things have built, 
run the `spring-petclinic-rest` app:

`java -jar target/spring-petclinic-rest-2.2.5.jar`

and then point a browser at [http://localhost:9966/petclinic/swagger-ui.html](http://localhost:9966/petclinic/swagger-ui.html).

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
* no-agent.json - k6 summary output data from run without agent
* with-agent.jfr - JFR recording data from the run with agent
* with-agent.json - k6 summary output data from run with agent

# Analysis

There is much to be done in this area!  Especially around automating runs and interpreting the 
results. 

For now, it is recommended to look at the output of k6. For very very basic manual inspection, 
consider the line that shows how long each iteration took.  This is a single pass through the k6 `basic.js`
script.

![iteration duration](https://raw.githubusercontent.com/breedx-splk/iguanodon/main/doc/iteration_duration.png)

Of particular interest are the first column (average) and last column (P95, or 95th percentile).
You can use these two numbers to get a rough idea at how throughput was impacted.
These numbers also exist in the summary output.

* tbd how to interpret/read the data
* tbd show how to load and look at jfr in jmc
* tbd start building some comparison automation

# Ideas / Future

* take a heap dump after k6 runs.  could be useful to catch otel objects in flight.
* run with a more realistic -Xmx like 4G. 
* use a real/external database (mysql or pg via docker)
* be able to run with the agent and compare with/without options
    * like with specific instrumentation en/disabled
* test each different exporter in isolation
* with and without jdbc
* use JFR profile named "profiler"?
* compare/contrast with `e2ebenchmark` in the instrumentation repo
* gh-pages for results
* automation (maybe nightly?)
* collaboration
