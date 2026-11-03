# OrderFlow v2.3.0 release readiness

## Version and validation
- Application version: 2.3.0; published baseline tag: v2.3.0.
- Each CI image uses `orderflow:<full commit SHA>`; record that SHA and image ID from the successful run before promotion. The published tag is not moved.
- `validate` runs the HTTP endpoint tests; `deploy-local-lab` builds the same commit and verifies `/health` reports `ok` and `2.3.0`.
- Local deployment, rollback to 1.0.0 and redeployment to 2.3.0 passed. Cloud deployment has not been performed.

## Deployment and infrastructure decision
- Prepare a container release for an existing Kubernetes cluster using the supplied Deployment and Service; replace the example image with the validated registry image digest before production use.
- Kubernetes manages application rollout and replicas. Terraform provisions infrastructure; the standalone EC2 example is not an application rollout mechanism and is not used for this release.
- Use a rolling update, check rollout status and `/health`, and stop promotion if health, version or error-rate checks fail. No production deployment is executed by this lab.

## Secrets and approvals
- No credentials remain in the deployment configuration or Kubernetes manifest; this application needs no external credentials.
- Any future credentials must come from protected environment secrets and Kubernetes Secret references, never committed literals or log output.
- Manual workflow dispatch on main runs validation first, then the `production` environment review gate. Approval records remain pending until a reviewer actually approves.
- The fork owner is the lab reviewer; production use requires an independent release reviewer and prevention of self-review.

## Rollback plan
- Before promotion, record the previous healthy production image digest and its expected application version. Do not use `latest` or assume the local 1.0.0 image is a production artifact.
- On failed rollout, unhealthy endpoints, incorrect version or increased errors, restore that recorded digest, wait for rollout completion, and verify `/health` and service traffic.
- The executable local drill is `bash scripts/rollback.sh orderflow:1.0.0 1.0.0`; it verifies the restored version. Production recovery is planned, not claimed as tested.

## Production approval checklist
- [x] HTTP tests and isolated container health/version validation pass.
- [x] Hardcoded credentials removed; image tied to the source commit.
- [x] Deployment strategy, infrastructure choice and rollback steps documented.
- [ ] Release manager reviews the successful run, source SHA and image digest.
- [ ] Production registry image and previous healthy digest recorded.
- [ ] Production environment approval granted before promotion.
- [ ] Target-cluster access, secret injection and rollout monitoring verified.

This is a validated lab release candidate. Production promotion remains blocked until the unchecked items are completed.
