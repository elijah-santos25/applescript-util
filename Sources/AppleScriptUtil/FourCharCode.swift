//
//  FourCharCode.swift
//

import Foundation

/// Creates a `FourCharCode` (`UInt32`) from an ASCII `String`.
///
/// This function will crash if the string is non-ASCII-representable or not exactly 4 ASCII bytes.
public func fourCharCode(_ str: String) -> FourCharCode {
    precondition(str.canBeConverted(to: .ascii), "fourCharCode(_:) only accepts ASCII characters")
    precondition(str.lengthOfBytes(using: .ascii) == 4, "fourCharCode(_:) only accepts strings of length 4")
    // reversed in order to have proper endianness
    return str.data(using: .ascii)!.reversed().withUnsafeBytes { $0.load(as: UInt32.self) }
}
