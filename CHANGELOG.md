<a name="0.3.0"></a>
## 0.3.0 (2018-10-12)

### Features

- added `Blackhole` storage engine
- replaced `porcelain` with `erlexec`
- **BREAKING CHANGE** replaced StatsD metrics exporter with Prometheus

### Fix

- `Local` storage now creates full path to file before trying to save
- use Alpine based Docker image instead of Ubuntu based one
