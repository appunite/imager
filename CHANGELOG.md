<a name="0.3.1"></a>
### 0.3.1 (2018-10-15)


#### Documentation

*   document installation and configuration ([38f3c37f](https://github.com/appunite/imager/commit/38f3c37f851299030c47acf1aaea64ad1e09b815))



<a name="0.3.0"></a>
## 0.3.0 (2018-10-12)

### Features

- added `Blackhole` storage engine
- replaced `porcelain` with `erlexec`
- **BREAKING CHANGE** replaced StatsD metrics exporter with Prometheus

### Fix

- `Local` storage now creates full path to file before trying to save
- use Alpine based Docker image instead of Ubuntu based one
