# Silencio

Shut up, Xcode.

`SourceKitService` crashes slow down Xcode. As it turns out, this is because of 
the bezel it displays at that time. Inhibit that, speed up Xcode.

## LICENSE

Silencio is available with no warranty for use or misuse. See LICENSE for more details.

## TODO

* Move use of JRSwizzle into something more suited (`imp_implementationWithBlock`)
* (Efficiently!) add an indicator to `IDEActivityView` when SourceKit crashes
