__author__ = "(https://github.com/bigg01) - containerize.ch "
__version__ = "0.1.0"


import os
import sys
import time

from kubernetes import client, config
from prometheus_client import start_http_server, Gauge

import logging

stdout_handler = logging.StreamHandler(stream=sys.stdout)
handlers = [stdout_handler]

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s",
    handlers=handlers,
)

log = logging.getLogger("LOGGER_NAME")


# Load the Kubernetes configuration
if os.environ.get("KUBERNETES_PORT"):
    config.load_incluster_config()
else:
    config.load_kube_config()

CURRENT_NAMESPACE = os.environ.get("CURRENT_NAMESPACE", "na")
HTTP_PORT = os.environ.get("HTTP_PORT", 8000)

# Create a Kubernetes API client
api_client = client.CoreV1Api()

# Create a Prometheus metric for the container image names
container_image_metric = Gauge(
    "container_image_names",
    "Names of the container images running inside pods",
    ["pod_name", "namespace", "container_name", "container_image_name"],
)

# Start the Prometheus exporter
logging.info(
    f"Start the Prometheus exporter Author: http://localhost:{HTTP_PORT} {__author__} Version: {__version__}"
)
start_http_server(HTTP_PORT)

while True:
    # Get the namespace of the pods
    namespace = CURRENT_NAMESPACE

    # Get all the pods in the namespace
    pods = api_client.list_namespaced_pod(namespace=namespace)

    # Export the container image names for each pod
    for pod in pods.items:
        for container in pod.spec.containers:
            container_image = pod.spec.containers[0].image
            container_image_metric.labels(
                pod_name=pod.metadata.name,
                namespace=namespace,
                container_name=container.name,
                container_image_name=container_image,
            ).set(1)

    # Sleep for 5 seconds before checking again
    time.sleep(60)
