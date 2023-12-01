//
//  CasstledTriggerParamsConditionEvaluator.swift
//  Castled
//
//  Created by antony on 17/04/2023.
//

import Foundation

protocol CIParamsConditionEvaluatable {
    //    associatedtype T
    func evaluateCondition(value: Any?, propertyOperation: CITriggerOperation) -> Bool
}

class CIStringEvaluator: CIParamsConditionEvaluatable {
    public func evaluateCondition(value: Any?, propertyOperation: CITriggerOperation) -> Bool {
        guard let textValue = value as? String else {
            return false // value is not a String, return false
        }
        switch propertyOperation.type {
        case .EQ:
            return propertyOperation.value == textValue
        case .NEQ:
            return propertyOperation.value != textValue

        default:
            CastledLog.castledLog("Operations type \(propertyOperation.type.rawValue) not supported for string operand", logLevel: CastledLogLevel.error)
            return false
        }
    }
}

class CINumberEvaluator: CIParamsConditionEvaluatable {
    func evaluateCondition(value: Any?, propertyOperation: CITriggerOperation) -> Bool {
        guard let numberValue = value as? NSNumber else { return false }
        let formatter = NumberFormatter()
        switch propertyOperation.type {
        case .EQ:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return false }
            return numberValue == conditionValue
        case .NEQ:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return true }
            return numberValue != conditionValue
        case .GT:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return false }
            return numberValue.doubleValue > conditionValue.doubleValue
        case .LT:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return false }
            return numberValue.doubleValue < conditionValue.doubleValue
        case .GTE:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return false }
            return numberValue.doubleValue >= conditionValue.doubleValue
        case .LTE:
            guard let conditionValue = formatter.number(from: propertyOperation.value) else { return false }
            return numberValue.doubleValue <= conditionValue.doubleValue
        case .BETWEEN:
            guard let fromValue = formatter.number(from: propertyOperation.value),
                  let toValue = formatter.number(from: propertyOperation.value) else { return false }
            return fromValue.doubleValue < numberValue.doubleValue && toValue.doubleValue > numberValue.doubleValue
        default:
            let message = String(format: "Operations type %@ not supported for numeric operand", propertyOperation.propertyType.rawValue)
            CastledLog.castledLog(message, logLevel: CastledLogLevel.error)
        }
        return false
    }
}

class CIBoolEvaluator: CIParamsConditionEvaluatable {
    func evaluateCondition(value: Any?, propertyOperation: CITriggerOperation) -> Bool {
        guard let aBool = value as? Bool else {
            // Throw an error or return a default value if value is not of the expected type
            return false
        }
        let conditionValue = Bool(propertyOperation.value) ?? false
        switch propertyOperation.type {
        case .EQ:
            return aBool == conditionValue
        default:
            // Throw an error or return a default value if the operation is not supported
            return false
        }
    }
}

class CIDateEvaluator: CIParamsConditionEvaluatable {
    func evaluateCondition(value: Any?, propertyOperation: CITriggerOperation) -> Bool {
        return false
    }
}
