# Observability — Metrics (Prometheus) & Logs (VictoriaLogs)

Both surfaces are queried over HTTPS with an inline, short-lived `readonly` token (see the
Authentication section of `SKILL.md` for the minting rules).

## Metrics

Fly hosts a Prometheus per org at `https://api.fly.io/prometheus/<organization>/`. Accepts PromQL or [MetricsQL](https://docs.victoriametrics.com/MetricsQL.html). Default to a 1h window, 60s step; honor explicit windows the user provides.

```bash
curl -sG https://api.fly.io/prometheus/<organization>/api/v1/query_range \
  --data-urlencode "query=<PromQL>" \
  --data-urlencode "start=$(date -u -d '-1 hour' +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "end=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "step=60" \
  -H "Authorization: $(fly tokens create readonly \
    --name '<model>: metrics query' \
    --expiry 30s --org <organization>)"
```

Parse JSON, summarize per `instance` (min / avg / max) with a one-line interpretation.

Built-in machine series: `fly_instance_cpu`, `fly_instance_memory_mem_available`, `fly_instance_load_average{minutes="1"}`, `fly_instance_net_recv_bytes`. Labels: `app`, `instance` (machine id), `region`.

App-level series exist only if the app exports them (e.g. PromEx via `[metrics]` in `fly.toml`). Inspect `fly.toml` for the prefix.

Full catalog: WebFetch <https://fly.io/docs/monitoring/metrics/>.

## Logs (VictoriaLogs)

Fly keeps **queryable, historical** logs in VictoriaLogs, per org, at
`https://api.fly.io/victorialogs/<organization>/select/logsql/query` (query language:
[LogsQL](https://docs.victoriametrics.com/victorialogs/logsql/)). This is the one to reach for
when you need history or aggregation — `fly logs` only tails the live buffer, and there is **no**
`/loki/` endpoint. (A Quickwit mirror also exists at `/quickwit/<organization>`.) Default to a 1h
window; honor explicit windows the user provides.

```bash
curl -sG https://api.fly.io/victorialogs/<organization>/select/logsql/query \
  --data-urlencode 'query=fly.app.name:<app> "<search text>"' \
  --data-urlencode "start=$(date -u -d '-1 hour' +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "end=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "limit=100" \
  -H "Authorization: $(fly tokens create readonly \
    --name '<model>: log query' --expiry 30s --org <organization>)"
```

Response is **newline-delimited JSON** (one object per matched line) — slurp with `jq -rs`, not `jq`.

Fields: `_msg` (the log line), `_time` (RFC3339), `fly.app.name`, `fly.app.instance` (machine id),
`log.level`.

LogsQL basics:
- Field filter: `fly.app.name:<app>`, `log.level:error`.
- Phrase match in the message: bare `"connection reset"` searches `_msg`.
- Combine (implicit AND): `fly.app.name:<app> log.level:error "timeout"`.
- Aggregate with a `| stats` pipe — counting is far cheaper than streaming every line.

**Example — count matches, bucketed hourly** (stats rows also come back as JSON lines, unsorted):

```bash
curl -sG https://api.fly.io/victorialogs/<organization>/select/logsql/query \
  --data-urlencode 'query=fly.app.name:<app> "<search text>" | stats by (_time:1h) count() as n' \
  --data-urlencode "start=$(date -u -d '-24 hour' +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "end=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -H "Authorization: $(fly tokens create readonly \
    --name '<model>: log stats' --expiry 30s --org <organization>)" \
| jq -rs 'sort_by(._time)[] | "\(._time)  \(.n)"'
```

**Example — single total over a window:** append `| stats count() as n`, then `jq -rs '.[0].n // 0'`.

App logs (`fly.app.name:<app>`) and Postgres logs (`fly.app.name:<db-app>`) both land here — e.g.
`fly.app.name:<db-app> repmgr` for cluster events, or `fly.app.name:<db-app> "system spent"` for
Fly's PSI-based "hit resource limits" health-check failures.
