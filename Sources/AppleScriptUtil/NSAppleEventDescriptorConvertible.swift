//
//  NSAppleEventDescriptorConvertible.swift
//

import Foundation

/// A type that can be converted to and from an `NSAppleEventDescriptor`.
public protocol NSAppleEventDescriptorConvertible {
    /// Converts the instance to an `NSAppleEventDescriptor`.
    func toAppleEventDescriptor() throws -> NSAppleEventDescriptor
    
    /// Returns an instance created from an `NSAppleEventDescriptor`.
    ///
    /// This is a static function rather than an initializer to allow retroactive conformance of classes, if necessary.
    static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self
}

extension String: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        NSAppleEventDescriptor(string: self)
    }
    
    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        guard let string = descriptor.stringValue else {
            throw ConversionError.couldntCoerceDescriptorToType(descriptor.descriptorType.description, "String")
        }
        return string
    }
}

extension Int32: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        NSAppleEventDescriptor(int32: self)
    }
    
    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        return descriptor.int32Value
    }
}

extension Double: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        NSAppleEventDescriptor(double: self)
    }
    
    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        return descriptor.doubleValue
    }
}

extension Bool: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        NSAppleEventDescriptor(boolean: self)
    }
    
    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        return descriptor.booleanValue
    }
}

extension Array: NSAppleEventDescriptorConvertible where Element: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        let list = NSAppleEventDescriptor.list()
        for element in self {
            try list.insert(element.toAppleEventDescriptor(), at: 0)
        }
        return list
    }
    
    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        var arr: Self = []
        arr.reserveCapacity(descriptor.numberOfItems)
        // indexed from 1
        for i in 1...descriptor.numberOfItems {
            guard let item = descriptor.atIndex(i) else {
                throw ConversionError.listItemNotFound(i)
            }
            arr.append(try .fromAppleEventDescriptor(item))
        }
        return arr
    }
}

extension Optional: NSAppleEventDescriptorConvertible where Wrapped: NSAppleEventDescriptorConvertible {
    public func toAppleEventDescriptor() throws -> NSAppleEventDescriptor {
        try self?.toAppleEventDescriptor() ?? .null()
    }

    public static func fromAppleEventDescriptor(_ descriptor: NSAppleEventDescriptor) throws -> Self {
        if descriptor.isEqual(NSAppleEventDescriptor.null()) {
            return .none
        } else {
            return try Wrapped.fromAppleEventDescriptor(descriptor)
        }
    }
}
