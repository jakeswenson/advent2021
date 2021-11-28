import Foundation
import Logging

let bundle = Bundle.main

let logger = Logger(label: bundle.bundleIdentifier ?? "<none>")
logger.info("Hello World!")

// Since the Info.plist file gets embedded in the binary, we can access values
// like the bundle identifier using the NSBundle APIs.
print("Hello World from \(bundle.bundleIdentifier ?? "<none>")")
print("\nHere is the entire Info.plist dictionary: \n\n\(bundle.infoDictionary ?? [:])")
