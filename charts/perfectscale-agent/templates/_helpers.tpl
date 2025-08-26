{{/*
Expand the name of the chart.
*/}}
{{- define "perfectscale-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "perfectscale-agent.fullname" -}}
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
{{- define "perfectscale-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "perfectscale-agent.labels" -}}
perfectscale-agent.sh/chart: {{ include "perfectscale-agent.chart" . }}
{{ include "perfectscale-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "perfectscale-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "perfectscale-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "perfectscale-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "perfectscale-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.ksmAddress" -}}
{{- if .Values.settings.ksmAddress }}
{{- .Values.settings.ksmAddress }}
{{- else }}
{{- printf "http://%s-%s:8080" .Release.Name "kube-state-metrics" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.dataRetentionTime" -}}
{{- if .Values.settings.dataRetentionTime }}
{{- .Values.settings.dataRetentionTime }}
{{- else }}
{{- "15m" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.ksmTimeout" -}}
{{- if .Values.settings.ksmTimeout }}
{{- .Values.settings.ksmTimeout }}
{{- else }}
{{- "30s" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.rawTimeWindowSizeMinutes" -}}
{{- if .Values.settings.rawTimeWindowSizeMinutes }}
{{- .Values.settings.rawTimeWindowSizeMinutes }}
{{- else }}
{{- "10m" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.policyRefreshPct" -}}
{{- if .Values.settings.policyRefreshPct }}
{{- .Values.settings.policyRefreshPct }}
{{- else }}
{{- "0.5" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.remoteLogBatchSize" -}}
{{- if .Values.settings.remoteLogBatchSize }}
{{- .Values.settings.remoteLogBatchSize }}
{{- else }}
{{- "1000" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.remoteLogBatchInterval" -}}
{{- if .Values.settings.remoteLogBatchInterval }}
{{- .Values.settings.remoteLogBatchInterval }}
{{- else }}
{{- "15s" }}
{{- end }}
{{- end }}

{{- define "perfectscale-agent.exporter.clusterUID" -}}
{{- if .Values.settings.clusterUID }}
{{- .Values.settings.clusterUID }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}