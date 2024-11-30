# Helm Chart For Perfectscale Exporter.

## Prerequisites

* Install the follow packages:  ``kubectl`` and ``helm``
* Add new cluster in the Web UI https://app.perfectscale.io/, copy clientId and clientSecret

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add perfectscale https://perfectscale-io.github.io --force-update
```

Install chart with command:

```console

helm upgrade psc-exporter --install -n perfectscale --create-namespace perfectscale \
      --set secret.create=true \
      --set secret.clientId=***** \
      --set secret.clientSecret=***** \
      --set settings.clusterName=ClusterName \
      perfectscale/exporter

```

Get the pods lists by running this commands:

```console
kubectl get pods -n perfectscale
```

## How to uninstall

Remove application with command.

```console
helm uninstall psc-exporter -n perfectscale
```
