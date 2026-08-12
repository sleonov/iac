# record-manager Lambda

Automatically registers and deregisters Route53 private-zone A records as EC2 instances
start and stop. Deployed by the Terraform module at `aws-infra/05-dns-automation/record-manager/`.

See the module-level docstring in `handler.py` for full details on the opt-in mechanism,
DNS state tag, and zone discovery approach.

---

## Structure

```
record-manager/
  handler.py              # Lambda source
  requirements-test.txt   # test dependencies (not bundled into the Lambda)
  tests/
    conftest.py           # env var + sys.path setup for pytest
    test_handler.py       # unit tests
```

---

## Testing

Tests use [moto](https://docs.getmoto.org/) to mock Route53 and SSM, and
`unittest.mock.patch` for EC2 calls (`get_instance`, `tag_instance`) to avoid
the complexity of spinning up mocked EC2 instances.

**Install dependencies**

```bash
pip install -r requirements-test.txt
```

**Run tests**

```bash
pytest tests/ -v
```

---

## Test coverage

| Test | What it verifies |
|---|---|
| `test_instance_not_found_skips` | Instance ID from event does not exist → no record created |
| `test_no_manage_r53_tag_skips` | Instance has no `manage-r53-record` tag → skipped (opt-in not set) |
| `test_no_name_tag_skips` | Instance has no `Name` tag → skipped (no label to build FQDN) |
| `test_no_private_ip_skips` | Instance has no private IP → skipped |
| `test_running_creates_record` | `state=running` → A record created in Route53, FQDN written to `fqdn` tag |
| `test_shutting_down_deletes_record` | `state=shutting-down` → existing A record removed from Route53 |
| `test_shutting_down_no_fqdn_tag_skips` | `fqdn` tag absent (Lambda never ran on start) → delete skipped |

---

## How moto is wired up

The `aws_setup` fixture creates a moto-mocked hosted zone and stores its
auto-generated zone ID in a mocked SSM parameter under the same path the
handler reads at runtime. This means `get_zone()` resolves correctly inside
tests and Route53 assertions verify real mocked state rather than relying
on patched return values.

Module-level boto3 clients in `handler.py` are created before the mock
starts, but moto intercepts at the botocore transport layer so all calls
made within the `mock_aws()` context are captured regardless of when the
client was created.
