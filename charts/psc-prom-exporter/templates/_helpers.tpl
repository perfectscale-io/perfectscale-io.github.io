{{/*
Expand the name of the chart.
*/}}
{{- define "helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm.labels" -}}
helm.sh/chart: {{ include "helm.chart" . }}
{{ include "helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "helm.exporter.ksmAddress" -}}
{{- if .Values.settings.ksmAddress }}
{{- .Values.settings.ksmAddress }}
{{- else }}
{{- printf "http://%s-%s:8080" .Release.Name "kube-state-metrics" }}
{{- end }}
{{- end }}

{{- define "helm.exporter.dataRetentionTime" -}}
{{- if .Values.settings.dataRetentionTime }}
{{- .Values.settings.dataRetentionTime }}
{{- else }}
{{- "15m" }}
{{- end }}
{{- end }}

{{- define "helm.exporter.remoteLogBatchSize" -}}
{{- if .Values.settings.remoteLogBatchSize }}
{{- .Values.settings.remoteLogBatchSize }}
{{- else }}
{{- "1000" }}
{{- end }}
{{- end }}

{{- define "helm.exporter.remoteLogBatchInterval" -}}
{{- if .Values.settings.remoteLogBatchInterval }}
{{- .Values.settings.remoteLogBatchInterval }}
{{- else }}
{{- "15s" }}
{{- end }}
{{- end }}

{{/*
For testing purposes, in prod we want to get the actual cluster's UID
*/}}
{{- define "helm.exporter.clusterUID" -}}
{{- if .Values.settings.clusterUID }}
{{- .Values.settings.clusterUID }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "datadogAD.v1annotations" -}}
ad.datadoghq.com/{{ .containerName }}.check_names: '["openmetrics"]'
ad.datadoghq.com/{{ .containerName }}.init_configs: "[{}]"
{{- if .config.maxReturnedMetrics }}
ad.datadoghq.com/{{ .containerName }}.max_returned_metrics: "{{ .config.maxReturnedMetrics }}"
{{- end }}
ad.datadoghq.com/{{ .containerName }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .config.port }}{{ .config.endpoint }}",
      "namespace": "{{ .config.namespace }}",
      {{- if .config.options }}
      {{- range $key, $value := .config.options }}
      "{{ $key }}": {{ $value }},
      {{- end }}
      {{- if .config.metrics }}
      "metrics": [
        {{- range $index, $metric := .config.metrics }}
        {{- if $index }},{{ end }}
        {{- if .rename }}
        {
        {"{{ .name }}": "{{ .rename }}"}
        }
        {{- else }}
        "{{ .name }}"
        {{- end }}
        {{- end }}
      ]
      {{- end }}
      {{- end }}
    }
  ]
{{- end }}

{{- define "datadogAD.v2annotations" -}}
ad.datadoghq.com/{{ .containerName }}.checks: |
  {
    "openmetrics": {
      "init_config": {},
      "instances": [
        {
          "openmetrics_endpoint": "http://%%host%%:{{ .config.port }}{{ .config.endpoint }}",
          "namespace": "{{ .config.namespace }}",
          {{- if .config.maxReturnedMetrics }}
          "max_returned_metrics": "{{ .config.maxReturnedMetrics }}",
          {{- end }}
          {{- if .config.options }}
          {{- range $key, $value := .config.options }}
          "{{ $key }}": {{ $value }},
          {{- end }}
          {{- end }}
          {{- if .config.metrics }}
          "metrics": [
            {{- range $index, $metric := .config.metrics }}
            {{- if $index }},{{ end }}
            {{- if .rename }}
            {"{{ .name }}": "{{ .rename }}"}
            {{- else }}
            "{{ .name }}"
            {{- end }}
            {{- end }}
          ]
          {{- end }}
        }
      ]
    }
  }
{{- end }}
