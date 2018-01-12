## Introduction

`Every` is an elegant timer in Swift.

## Requirements

* iOS 8.0+
* watchOS 2.0+
* tvOS 9.0+
* macOS 10.10+
* Xcode 9 with Swift 4

## Installation

#### CocoaPods

```ruby
use_frameworks!
pod 'Every'
```

## Usage

```swift
import Every
```

```swift
var counter = 0
Every(1).seconds.do { () -> Every.NextStep in
    counter += 1
    guard counter <= 4 else {
        print("STOP")
        return .stop
    }
    print(counter)
    return .continue
}
// 1
// 2
// 3
// 4
// STOP
```
