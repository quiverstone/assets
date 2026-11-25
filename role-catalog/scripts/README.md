# Role-Catalog CloudShell Scripts

Scripts that deploy the role-catalog CloudFormation templates from **AWS CloudShell** with one
command. They are published with the templates by `.github/workflows/upload-templates.yaml`
(the `role-catalog/` directory is synced to `s3://assets.quiverstone.io/role-catalog/` on every
push to `main`), so they are served at:

```text
https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts/<script>
```

> The sync runs with `--delete`: anything under `role-catalog/` in the bucket that is not in this
> repository is removed on the next publish. Keep scripts **here**, not only in the bucket.

| Script | Purpose |
|---|---|
| `quiverstone-onboard.sh` | Deploys any Quiverstone role type (see below). The Quiverstone app generates the command. |
| `quiverstone-inventory-onboard.sh` | Compatibility shim for commands generated before the multi-role script. Downloads `quiverstone-onboard.sh` and runs it with `--role-type org-inventory`. |

## Role types

| `--role-type` | `--variant` | Template | Required flags |
|---|---|---|---|
| `org-inventory` | `direct` | `inventory/direct-org-inventory-role.yaml` | `--external-id` |
| `org-inventory` | `chained` | `inventory/chained-org-inventory-role.yaml` | `--intermediate-role-arn` |
| `standalone-inventory` | `direct` | `inventory/standalone-account-inventory-role.yaml` | `--external-id` |
| `account-access` | `browser` | `access/browser-access-role.yaml` | `--trusted-account-id` |
| `account-access` | `direct` | `access/direct-access-role.yaml` | `--external-id` |
| `account-access` | `chained` | `access/chained-access-role.yaml` | `--intermediate-role-arn` |
| `intermediate` | — | `intermediate/trusted-intermediate-role.yaml` | `--external-id` |

Optional flags: `--role-name`, `--region` (stack region, default `us-east-1`), `--stack-name`,
`--expected-account-id` (stop if CloudShell is signed in to a different account),
`--permissions` (account access: comma list of `read-only`, `administrator`, `power-user`,
`view-only`, `security-audit`, `system-administrator`, `support-user`, `billing`),
`--trust-scope all|named` (chained), `--external-id` on chained (optional hop-2 External ID),
`--account-type management|delegated-admin` (org inventory), `--assume-scope`,
`--destination-role-name`, `--destination-account-id` (intermediate), and the Quick Setup
callback trio `--callback-url --token --session-id` (org inventory only). `--help` prints them all.

## External ID contract

This matches how the Quiverstone backend assumes roles (from the production account
`684035162433`, never from an IAM user):

- **Direct** roles and the **intermediate** role trust `arn:aws:iam::684035162433:root` and
  **require** the tenant External ID, which Quiverstone always presents.
- **Chained** target roles trust the intermediate account (or the named intermediate role). Their
  `pExternalId` is an **optional** hop-2 External ID; the tenant External ID is enforced on hop 1.
- **Browser** roles trust a customer account for console switch-role and cannot use an External ID.

## Example

```bash
curl -fsSL https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts/quiverstone-onboard.sh -o quiverstone-onboard.sh && bash quiverstone-onboard.sh --role-type account-access --variant direct --external-id <your-external-id> --permissions read-only
```

## Troubleshooting

- `curl: (22) The requested URL returned error: 404` — the script is not in the bucket. It is not
  a CloudShell region problem: the URL is fixed to the `us-east-2` bucket. Confirm the last
  `Upload Templates` workflow run succeeded and the object exists:
  `curl -sI https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts/quiverstone-onboard.sh`.
- The CloudShell region does not matter for IAM (roles are global). It only decides where the
  CloudFormation stack is created, which is set with `--region`. If a role with the same name
  already exists (for example from a stack in another region), the script says so before deploying.
- On a failed deploy the script prints the failing stack events. A stack left in
  `ROLLBACK_COMPLETE` by a previous failed attempt is deleted automatically before retrying.

## Linting

```bash
shellcheck role-catalog/scripts/*.sh
bash -n role-catalog/scripts/quiverstone-onboard.sh
```
