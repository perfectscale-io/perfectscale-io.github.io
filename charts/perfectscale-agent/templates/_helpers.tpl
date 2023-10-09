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

{{- define "helm.exporter.ksmTimeout" -}}
{{- if .Values.settings.ksmTimeout }}
{{- .Values.settings.ksmTimeout }}
{{- else }}
{{- "30s" }}
{{- end }}
{{- end }}

{{- define "helm.exporter.rawTimeWindowSizeMinutes" -}}
{{- if .Values.settings.rawTimeWindowSizeMinutes }}
{{- .Values.settings.rawTimeWindowSizeMinutes }}
{{- else }}
{{- "10m" }}
{{- end }}
{{- end }}

{{- define "helm.exporter.policyRefreshPct" -}}
{{- if .Values.settings.policyRefreshPct }}
{{- .Values.settings.policyRefreshPct }}
{{- else }}
{{- "0.5" }}
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