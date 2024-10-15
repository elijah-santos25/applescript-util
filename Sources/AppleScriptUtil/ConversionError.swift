//
//  ConversionError.swift
//

import Foundation

internal enum ConversionError: LocalizedError {
    case couldntCoerceDescriptorToType(_ descriptorType: String, _ type: String)
    case listItemNotFound(_ index: Int)
    
    public var errorDescription: String? {
        switch self {
        case .couldntCoerceDescriptorToType(let descriptorType, let type):
            return "Failed to convert NSAppleEventDescriptor to type \(type); descriptor typecode: \(descriptorType)"
        case .listItemNotFound(let index):
            return "Could not retrieve descriptor at index \(index)"
        }
    }
}
