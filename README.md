#  AppleScriptUtil

Utilities for interacting with `NSAppleScript` in Swift.

## Included Utilities

- `fourCharCode(_:)` - creates a `FourCharCode` from a 4-character ASCII string.
- `NSAppleScript.rawHandler(named:)` - returns a closure that invokes a handler in the script with
  `NSAppleEventDescriptor` argument and return value.
- Typed handlers:
    - `NSAppleEventDescriptorConvertible` - a protocol for types that can be converted two-way into
      and from `NSAppleEventDescriptor`
    - `NSAppleScript.handler(named:argumentTypes:returnType:)` (and its `Void`-return equivalent) -
      returns a closure that invokes a handler in the script with typed argument and return values.
    
