## [1.2.2](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/1.2.1...1.2.2) (2021-04-19)


### Bug Fixes

* another try ([05ac229](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/05ac229aef3b2c36277b27b4857c2ad1b50708e5))
* Experiment with Roang-zero1/github-create-release-action ([c3a817b](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/c3a817b4b17b65d48ae4475888fe2d114b799319))
* revert all ([c37b1ac](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/c37b1ac737b87c4edc297aa0e62b20f375a4f165))
* test github actions ([7b9e57f](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/7b9e57fa5e7f31cd6442478088bd97168dbdd88a))
* update ci ([9d304c9](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/9d304c99c675cac05373a502eec1f11c6416c6ed))
* update github.ref ([22edbe6](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/22edbe65f68175e4c521d7d18c2cb1b12d364f15))
* update release if condition ([ef74021](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/ef74021f3af0b25c2257985dcb943747d3e83a8b))
* update release.yml ([36bdbe1](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/36bdbe1ff63458074353cfae5dd017373ff2b9bc))
* update runs on for science ([7e3e94b](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/7e3e94ba60db16a4bb2788f731f8a005154421c9))
* update secret name ([f02133c](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/f02133cb1f1f36705718e84e7efc258687f4edf5))


### Features

* remove tag prefix ([d8ad0ec](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/d8ad0ecab3e1b1e47c3499b859ed5ef390e85532))



## [1.1.3](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/1.1.2...1.1.3) (2021-03-16)


### Bug Fixes

* fixing an issue that was caused by a callback stack never exiting ([8f365b5](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/8f365b57adf79ea629621c4ce7c1943274a63329))
* marking a closure as escaping ([084a5e8](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/084a5e8a749818613547ba0c408f7837759bbf51))



## [1.1.2](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/1.1.1...1.1.2) (2021-01-20)


### Bug Fixes

* add "log count" check  before scheduling "log work" in the analytics queue manager ([7617f19](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/7617f199c3910a627fa6910042655d034e741499))
* move DispatchQueue logic to the Scheduler implementation ([21eb647](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/21eb6472f0f86355603774f65095bb515dbf27f1))
* replace non-repeating timers with 'async after' of dispatch queue ([b1f70a3](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/b1f70a3dd967689147a19489d3f535b8604f390a))
* try to send 'unprocessed' logs when creating the queue manager ([8c7a306](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/8c7a306a26b07292cfe09125c00fe5f1c805d339))



## [1.1.1](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/1.1.0...1.1.1) (2020-12-08)


### Bug Fixes

* updating build to remove swiftlint and move to homebrew ([b940bf9](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/b940bf92fb1326519fc5ef012e8b5ab6959430da))
* updating fastfile to fix issue ([d0a92ed](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/d0a92edddda95e05cab0e18d0273f598eb5ffa98))



# [1.1.0](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/1.0.0...1.1.0) (2020-12-07)


### Features

* update function names for the "cache file" protocol definition ([ec5a422](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/ec5a422d6c7a812fa744053386fa00ab2b2e7dbd))



# [1.0.0](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/0.1.0...1.0.0) (2020-12-03)



# [0.1.0](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/compare/f1ba0c45de28a9cbf83fe9fd73be1be78c174426...0.1.0) (2020-11-18)


### Bug Fixes

* Trying another way to do the stringValue for the UserAgent protocol ([1dca84e](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/1dca84e8feb202d69b483d1da234f43c015ecf9e))


### Features

* Adding a queuemanager to hopefully reduce the complexity of these dependencies and simplify things ([f1ba0c4](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/f1ba0c45de28a9cbf83fe9fd73be1be78c174426))
* Adding customizable headers to the api ([e471c79](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/e471c7991f5f11f5ee02e24be18e45cf8f05ec8d))
* Fixes some tests and adds a note about what i want to do for testability and abstractness ([4031feb](https://github.com/krogertechnology/kat-native-ios-banner-analytics-api/commit/4031feb76378a18dc210b951d26d99832759b3aa))


### BREAKING CHANGES

* the api settings protocol now has another field on it that needs to be implemented elsewhere



