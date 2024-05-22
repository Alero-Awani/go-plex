{{/*
Create a default mongo service name which can be overridden.
*/}}
{{- define "mongodb.service.nameOverride" -}}
    {{- if and .Values.service .Values.service.nameOverride -}}
        {{- print .Values.service.nameOverride -}}
    {{- else -}}
        {{- if eq .Values.architecture "replicaset" -}}
            {{- printf "%s-headless" (include "mongodb.fullname" .) -}}
        {{- else -}}
            {{- printf "%s" (include "mongodb.fullname" .) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}