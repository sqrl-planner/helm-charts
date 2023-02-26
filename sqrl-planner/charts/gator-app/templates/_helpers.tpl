{{/*
Expand the name of the chart.
*/}}
{{- define "gator-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gator-app.fullname" -}}
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
{{- define "gator-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gator-app.labels" -}}
helm.sh/chart: {{ include "gator-app.chart" . }}
{{ include "gator-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gator-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gator-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gator-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gator-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Base template for containers
*/}}
{{- define "gator-app.container" -}}
{{- $top := first . }}
volumeMounts:
- name: tmp
  mountPath: /tmp
envFrom:
- configMapRef:
    name: {{ include "common.fullname" $top }}
- secretRef:
    name: {{ include "common.fullname" $top }}
ports:
- name: http
  containerPort: {{ $top.Values.service.port }}
  protocol: TCP
readinessProbe: null
livenessProbe: null
{{- end }}
