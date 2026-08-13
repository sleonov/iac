# record-reaper Lambda

Safety net for `record-manager`: periodically deletes stale Route53 private-zone A records
whose owning EC2 instance is no longer running with the `manage-r53-record` tag. Deployed
by the Terraform module at `aws-infra/05-dns-automation/record-reaper/`.

See the module-level docstring in `handler.py` for full details on the reaping logic and
zone discovery approach.

---

## Structure

```
record-reaper/
  handler.py              # Lambda source
  requirements-test.txt   # test dependencies (not bundled into the Lambda)
  tests/
    conftest.py           # env var + sys.path setup for pytest
    test_handler.py       # unit tests
```

---

## Testing

Tests use [moto](https://docs.getmoto.org/) to mock Route53 and SSM, and
`unittest.mock.patch` for EC2 calls (EC2 paginator) to avoid
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
| `test_fresh_record_not_reaped` | A record exists and instance is running+opted-in → record kept |
| `test_stale_record_reaped` | A record exists but instance not in running set → record deleted |
| `test_empty_zone_no_deletes` | No A records in zone → nothing happens |
| `test_mixed_fresh_and_stale` | One fresh record, one stale → only stale deleted |
| `test_record_not_found_warns` | Delete raises `InvalidChangeBatch` → warning logged, no exception |

---

## How moto is wired up

The `aws_setup` fixture creates a moto-mocked hosted zone and stores its
auto-generated zone ID in a mocked SSM parameter under the same path the
handler reads at runtime. This means `get_zone()` resolves correctly inside
tests and Route53 assertions verify real mocked state.

The EC2 paginator (`ec2_paginator.paginate`) is patched with `unittest.mock`
to return canned instance lists, avoiding the need to spin up mocked EC2
instances in moto. The patch directly controls which instance IDs the handler
considers "running and opted-in."
