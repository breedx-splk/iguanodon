#!/bin/bash

docker run -it --rm -p 4317:4317 iguanodon-collector --config /etc/collector.yaml
