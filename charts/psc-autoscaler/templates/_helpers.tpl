{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "psc-autoscaler.fullname" -}}
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
Expand the name of the chart.
*/}}
{{- define "psc-autoscaler.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "psc-autoscaler.fullname" -}}
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
{{- define "psc-autoscaler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "psc-autoscaler.labels" -}}
helm.sh/chart: {{ include "psc-autoscaler.chart" . }}
{{ include "psc-autoscaler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "psc-autoscaler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "psc-autoscaler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "psc-autoscaler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "psc-autoscaler.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "psc-autoscaler.integrationTests.serviceAccountName" -}}
{{- if .Values.integrationTests.serviceAccount.create }}
{{- default (printf "%s-int-tests" (include "psc-autoscaler.fullname" .)) .Values.integrationTests.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.integrationTests.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "psc-autoscaler.autoscaler.remoteLogBatchSize" -}}
{{- if .Values.settings.remoteLogBatchSize }}
{{- .Values.settings.remoteLogBatchSize }}
{{- else }}
{{- "1000" }}
{{- end }}
{{- end }}

{{- define "psc-autoscaler.autoscaler.remoteLogBatchInterval" -}}
{{- if .Values.settings.remoteLogBatchInterval }}
{{- .Values.settings.remoteLogBatchInterval }}
{{- else }}
{{- "15s" }}
{{- end }}
{{- end }}

{{/*
For testing purposes, in prod we want to get the actual cluster's UID
*/}}
{{- define "psc-autoscaler.clusterUID" -}}
{{- if .Values.settings.clusterUID }}
{{- .Values.settings.clusterUID }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}
