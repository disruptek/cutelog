# cutelog

[![Test Matrix](https://github.com/disruptek/cutelog/workflows/CI/badge.svg)](https://github.com/disruptek/cutelog/actions?query=workflow%3ACI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/disruptek/cutelog?style=flat)](https://github.com/disruptek/cutelog/releases/latest)
![Minimum supported Nim version](https://img.shields.io/badge/nim-1.4.8%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/disruptek/cutelog?style=flat)](#license)
[![buy me a coffee](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-orange.svg)](https://www.buymeacoffee.com/disruptek)

A stylish little logger to replace `echo` in command-line apps.

## Usage

- _`useStderr` does not have any effect on nim-0.19.6_
- _color, style, and prefix are unsupported on nim-0.20.X_

```
--define:cutelogEmojis       # turn on emojis
--define:cutelogMonochrome   # turn off color
--define:cutelogBland        # turn off style
```

## Documentation
See [the documentation for the cutelog module](https://disruptek.github.io/cutelog/cutelog.html) as generated directly from the source.

## License
MIT
