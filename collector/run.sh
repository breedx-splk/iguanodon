#!/bin/bash

docker run -it --rm -p 4317:4317 -p 13133:13133 iguanodon-collector --config /etc/collector.yaml
