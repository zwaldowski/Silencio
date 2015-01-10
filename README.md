# Silencio

Shut up, Xcode.

`SourceKitService` crashes slow down Xcode. As it turns out, this is because of 
the bezel it displays at that time. Inhibit that, speed up Xcode.

## Terminology

* `SourceKit`/`SourceKitService`: The framework and XPC service (respectively) responsible for Swift.
* `IDEKit`: UI framework for Xcode's implementation
* `IDEFoundation`: Business logic for Xcode's implementation
* `IDESourceEditor`: Plugin containing base text view for Xcode
* `IDELanguageSupportUI`: Plugin containing support for "third-party" languages (i.e., Swift)
* `IDESourceCodeDocument`: Base `NSDocument` subclass for source code
  * `IDEPlaygroundDocument`: Subclass for playgrounds.
* `sourceLanguageServiceAvailabilityNotification:message:`: Delegate callback (unknown protocol) for Swift crasher bezel

## LICENSE

Silencio is available with no warranty for use or misuse. See LICENSE for more details.

## TODO

* Move use of JRSwizzle into something more suited (`imp_implementationWithBlock`)
* (Efficiently!) add an indicator to `IDEActivityView` when SourceKit crashes
