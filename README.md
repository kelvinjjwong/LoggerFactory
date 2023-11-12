# LoggerFactory

A library for logging in macOS platform.

Built for  ![Platform](https://img.shields.io/badge/platforms-macOS%2010.15%20+-ff7711.svg)

Built with ![swift](https://img.shields.io/badge/Swift-5-blue) ![xcode](https://img.shields.io/badge/Xcode-14.3-blue) ![SPM](https://img.shields.io/badge/SPM-ff7711)


## Installation

#### Swift Package Manager

Specify dependency in `Package.swift` by adding this:

```swift
.package(url: "https://github.com/kelvinjjwong/LoggerFactory.git", .upToNextMajor(from: "1.0.5"))
```

Then run `swift build` to download and integrate the package.

#### CocoaPods

Use [CocoaPods](http://cocoapods.org/) to install `LoggerFactory` by adding it to `Podfile`:

```ruby
pod 'LoggerFactory', '~> 1.0.5'
```

Then run `pod install` to download and integrate the package.

## Usage

#### Initialialization

Such as in `AppDelegate.swift`

```swift
import LoggerFactory
```

```swift
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger())
    }
```

Or:

```swift
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "/path/to/folder/of/log/files"))
    }
```

#### Declare a logger


```swift
let logger = LoggerFactory.get(category: "DB")
```

Or:

```swift
let logger = LoggerFactory.get(category: "DB", subCategory: "PostgresDB")
```

You can specify logging levels including [.info, .warning, .error, .debug, .trace, .performance, .todo].
By default, [.info, .warning, .error, .todo] will be printed. You can use `includeTypes` and `excludeTypes` to add or remove some of them.

```swift
let logger = LoggerFactory.get(category: "DB", subCategory: "PostgresDB", includeTypes: [.performance, .debug, .trace])
```

Or:

```swift
let logger = LoggerFactory.get(category: "DB", subCategory: "PostgresDB", excludeTypes: [.todo, .warning])
```

#### Log a message

By default, it logs at `info` level when you don't specify.

```swift
self.logger.log("Some info message.")
```

```swift
self.logger.log(.error, "Error at somewhere.")
```

or you can specify the error in a `do...catch...` 

```swift
do {
	...
}catch{
	self.logger.log(.error, "Error at somewhere.", error)
}
```

or you can calculate how much time elapsed by using `timecost` at `performance` level:

```swift
let startTime = Date()
// do something
self.logger.timecost("did something", fromDate: startTime)
```

#### Sample output

```
Writing log to file: /Users/kelvinwong/Library/Containers/nonamecat.PostgresModelApp/Data/Documents/log/2023-07-20_0647.log
📗 2023-07-19T22:47:37Z [DB][PostgresDB] connecting: modeltest@127.0.0.1:5432/ModelTest
📗 2023-07-19T22:47:37Z [ViewController] [record]: 1 Optional("Tom") Optional(20)
📗 2023-07-19T22:47:37Z [ViewController] [record]: 2 Optional("Daisy") Optional(17)
📗 2023-07-19T22:47:37Z [ViewController] [record]: 3 Optional("DrWHO") nil
📗 2023-07-19T22:47:37Z [ViewController] [record]: 4 Optional("Jack") Optional(38)
📗 2023-07-19T22:47:37Z [ViewController] [record]: 5 nil Optional(41)
📗 2023-07-19T22:47:37Z [ViewController] [record]: 6 Optional("Helen") Optional(14)
📕 2023-07-19T22:52:12Z [DB][PostgresDB] Error: connection lost.
🕘 2023-07-19T22:54:23Z [DB][PostgresDB] did something - time cost: 123 seconds.
```


## License

[The MIT License](LICENSE)
