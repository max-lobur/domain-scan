## Domain scanner. 
Finds opened (potentially volnurable) URLs, and DNS names volnurable to takeover.

Currently based on two projects (shoutout to them!):
- https://github.com/michenriksen/aquatone
- https://github.com/OWASP/Amass

## Running locally:
```
source ops/env.sh
docker run -e SCAN_DOMAINS="yourdomain.io" ${DOCKER_TAG}
```
## Running in Kubernetes:
```
helm install charts/`ls charts/ | tail -1` --name domain-scan --namespace=domain-scan -f path/to/your/values.yaml
```

## Contributing:
This code distributed under MIT. Pull requests welcome.

Docker:
- `./ops/docker-build.sh` build image.
- `./ops/docker-stage.sh` push to image registry.

Helm:
- `./ops/helm-template.sh` test templates.
- `./ops/helm-package.sh` package chart.

## Known issues
- https://github.com/michenriksen/aquatone/issues/141
- Removing `-passive` amass flag will slow down scan significantly.