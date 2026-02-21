# Changelog

## 0.1.0 (2026-02-21)


### Features

* add create_alarm_sns_topic variable and update .github references ([ae1c21c](https://github.com/kbrockhoff/terraform-module/commit/ae1c21c2d42edb58039941eda9a4d632d521e05d))
* add GitHub Actions workflows for CI/CD ([ebfaa00](https://github.com/kbrockhoff/terraform-module/commit/ebfaa008e3528afe59d6851f933cb3c207e81e0e))
* add monitoring and alarm configuration variables ([aa0c796](https://github.com/kbrockhoff/terraform-module/commit/aa0c796a3e79ba2564c8745ce4dcb8a2d5ea14cc))
* **encryption:** add KMS key management and SNS encryption ([0594e58](https://github.com/kbrockhoff/terraform-module/commit/0594e58c86050b90b545e00c22eab160cb78829c))
* enhance bootstrap module with environment-based OIDC and S3 backend policies ([0ec5ae9](https://github.com/kbrockhoff/terraform-module/commit/0ec5ae9477792d652b532da4cb7731992ec07de0))
* enhance pricing module with comprehensive cost estimation ([e16e3a6](https://github.com/kbrockhoff/terraform-module/commit/e16e3a6c997104d67d57b9a1d65f985db0ec06a9))
* extend name_prefix validation to support 2-24 characters ([051df84](https://github.com/kbrockhoff/terraform-module/commit/051df8419b90024de0f30fef5af2be8eee1aa70d))


### Bug Fixes

* add more error proofing ([b8d6a0e](https://github.com/kbrockhoff/terraform-module/commit/b8d6a0e090cb47fad1a2f7d54ca8d5854a59aea9))
* correct SNS service principal and resolve test constant issue ([ea4b19a](https://github.com/kbrockhoff/terraform-module/commit/ea4b19a2a50ba04e237ec3fdf5c0870958822e1c))
* correct typos and update version information ([ca02eae](https://github.com/kbrockhoff/terraform-module/commit/ca02eae3dc73415c7d023995f4e325c4416676a5))
* enable terratest in CI and update test assertions ([d37eddd](https://github.com/kbrockhoff/terraform-module/commit/d37eddd55f906c4d5c914352b0489aa80044fbbf))
* enhance AWS credential configuration in CI workflow ([143f353](https://github.com/kbrockhoff/terraform-module/commit/143f353fe862283a611b51110a216f69ccb5e740))
* github copilot review fixes ([7cdab70](https://github.com/kbrockhoff/terraform-module/commit/7cdab70a9004e52842a131c549aca45f1677c5af))
* improve clarity of data_tags variable description and tag precedence ([3e2e84b](https://github.com/kbrockhoff/terraform-module/commit/3e2e84bf0b50fea9c3a197e56752387814a4fbba))
* improve Makefile destroy-examples output visibility ([8cef591](https://github.com/kbrockhoff/terraform-module/commit/8cef591ef3105e4a8e52ea0221ec037aead88748))
* remediation checkov errors ([75b54d2](https://github.com/kbrockhoff/terraform-module/commit/75b54d2ffdfc90624151c83e15c9b3108f5abed2))
* remediation gemini suggestions ([191f0a3](https://github.com/kbrockhoff/terraform-module/commit/191f0a31c02696dc00cd35437d90110062525615))
* remove unneeded version ([9691318](https://github.com/kbrockhoff/terraform-module/commit/96913180cc7dd20281fb036ed075e86053b6f766))
* update release-please action and add pricing module versions ([f813e75](https://github.com/kbrockhoff/terraform-module/commit/f813e7535bfc3ccb07af025bd670e28cb890d64e))
* update test assertion for disabled module ([3cad7fb](https://github.com/kbrockhoff/terraform-module/commit/3cad7fb99edb3043d6fbecbbefd729c7d2ff3460))

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
