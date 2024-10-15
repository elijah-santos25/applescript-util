//
//  NSAppleScript+handler.swift
//

import Foundation
import ApplicationServices

fileprivate let appleScriptSuite = fourCharCode("ascr")
fileprivate let subroutineEvent = fourCharCode("psbr")
fileprivate let subroutineName = fourCharCode("snam")

extension NSAppleScript {
    /// Returns a closure that executes a handler in the script with a given descriptor as its arguments.
    ///
    /// This method holds a strong reference to `self` throughout the lifetime of the closure in order to be able to invoke the handler.
    /// If handlers attempt to control other applications, the user may be asked to give the application permission to control them. The
    /// closure throws an error in any of the following cases: the script fails to compile, the handler fails with an error, or the handler
    /// fails to exist (the event is not handled). The arguments are passed to the handler as a direct object.
    /// - Parameter name: The name of the handler to invoke.
    /// - Returns: A closure whose arguments will be passed to the handler and whose return value is that of the handler.
    public func rawHandler(
        named name: String
    ) -> (_ parameters: NSAppleEventDescriptor?) throws -> NSAppleEventDescriptor {
        return { [self] parameters in
            var myPSN: ProcessSerialNumber = .init(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
            let target = NSAppleEventDescriptor(
                descriptorType: typeProcessSerialNumber,
                bytes: &myPSN,
                length: MemoryLayout<ProcessSerialNumber>.size)
            let handler = NSAppleEventDescriptor(string: name.lowercased())
            let event = NSAppleEventDescriptor(
                eventClass: appleScriptSuite,
                eventID: subroutineEvent,
                targetDescriptor: target,
                returnID: AEReturnID(kAutoGenerateReturnID),
                transactionID: AETransactionID(kAnyTransactionID))
            event.setParam(handler, forKeyword: subroutineName)
            if let parameters {
                event.setParam(parameters, forKeyword: keyDirectObject)
            }
            var error: NSDictionary? = nil
            // badly annotated APIs are the bane of my existence:
            // return is nonnull despite docs claiming it is nullable
            let result = unsafeBitCast(self.executeAppleEvent(event, error: &error), to: Optional<NSAppleEventDescriptor>.self)
            if let result {
                return result
            } else {
                throw NSError(
                    domain: "AppleScript",
                    code: (error?[NSAppleScript.errorNumber] as? Int) ?? -1,
                    userInfo: [NSLocalizedDescriptionKey: error?[NSAppleScript.errorMessage] ?? String(reflecting: error)])
            }
        }
    }
    
    /// Returns a type-safe closure that executes a handler in the script, taking typed arguments with a typed return value.
    ///
    /// This method holds a strong reference to `self` throughout the lifetime of the closure in order to be able to invoke the handler.
    /// If handlers attempt to control other applications, the user may be asked to give the application permission to control them. The
    /// closure throws an error in any of the following cases: the script fails to compile, the handler fails with an error, the handler
    /// fails to exist (the event is not handled), or the arguments or return value cannot be converted to/from descriptors. The
    /// arguments are passed to the handler as a direct object.
    /// - Parameters:
    ///   - name: The name of the handler to invoke.
    ///   - argType: The type of the expected arguments, as a tuple (i.e., `(Int, String).self`).
    ///   - returnType: The type of the expected return value.
    /// - Returns: A closure whose arguments will be passed to the handler and whose return value is that of the handler. The
    /// arguments are passed to the handler as a direct object.
    public func handler<
        each Arguments: NSAppleEventDescriptorConvertible,
        Return: NSAppleEventDescriptorConvertible
    >(
        named name: String,
        argumentTypes argType: (repeat each Arguments).Type = (repeat each Arguments).self,
        returnType: Return.Type = Return.self
    ) -> (repeat each Arguments) throws -> Return {
        return { (args: repeat each Arguments) throws -> Return in
            let argList = NSAppleEventDescriptor.list()
            for arg in repeat each args {
                // insertion at zero means append
                argList.insert(try arg.toAppleEventDescriptor(), at: 0)
            }
            return try Return.fromAppleEventDescriptor(self.rawHandler(named: name)(argList))
        }
    }
    
    /// Returns a type-safe closure that executes a handler in the script, taking typed arguments with a `Void` return value.
    ///
    /// This method holds a strong reference to `self` throughout the lifetime of the closure in order to be able to invoke the handler.
    /// If handlers attempt to control other applications, the user may be asked to give the application permission to control them. The
    /// closure throws an error in any of the following cases: the script fails to compile, the handler fails with an error, the handler
    /// fails to exist (the event is not handled), or the arguments cannot be converted to descriptors. The
    /// arguments are passed to the handler as a direct object, and any return values are discarded.
    /// - Parameters:
    ///   - name: The name of the handler to invoke.
    ///   - argType: The type of the expected arguments, as a tuple (i.e., `(Int, String).self`).
    /// - Returns: A closure whose arguments will be passed to the handler and whose return value is discarded. The
    /// arguments are passed to the handler as a direct object.
    public func handler<
        each Arguments: NSAppleEventDescriptorConvertible
    >(
        named name: String,
        argumentTypes argType: (repeat each Arguments).Type = (repeat each Arguments).self
    ) -> (repeat each Arguments) throws -> Void {
        return { (args: repeat each Arguments) throws -> Void in
            let argList = NSAppleEventDescriptor.list()
            for arg in repeat each args {
                // insertion at zero means append
                argList.insert(try arg.toAppleEventDescriptor(), at: 0)
            }
            _ = try self.rawHandler(named: name)(argList)
        }
    }
}
