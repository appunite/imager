<a name="0.3.2"></a>
## 0.3.2 (2018-11-24)


#### Documentation

*   document installation and configuration ([38f3c37f](https://github.com/appunite/imager/commit/38f3c37f851299030c47acf1aaea64ad1e09b815))

#### Bug Fixes

* **Dockerfile:**  use tini as a PID 1 process in container ([daffe313](https://github.com/appunite/imager/commit/daffe3136d430c0b89427662986755e89a4ba7ef))



<a name="0.3.1"></a>
### 0.3.1 (2018-10-15)


#### Documentation

*   document installation and configuration ([38f3c37f](https://github.com/appunite/imager/commit/38f3c37f851299030c47acf1aaea64ad1e09b815))



<a name="0.3.0"></a>
### 0.3.0 (2018-10-12)

#### Features

*   added `Blackhole` storage engine
*   replaced `porcelain` with `erlexec`
*   **BREAKING CHANGE** replaced StatsD metrics exporter with Prometheus

#### Fixes

*   `Local` storage now creates full path to file before trying to save
*   use Alpine based Docker image instead of Ubuntu based one
