//
//  CastledInAppTrigger.swift
//  Castled
//
//  Created by antony on 17/04/2023.
//

import Foundation
@objc public class CastledInAppTriggerEvaluator : NSObject {
    
    internal override init () {
        super.init()
        
        
    }
   internal func shouldTriggerEvent(filter : CIEventFilter?,params : [String:Any]?,showLog : Bool? = true) -> Bool{
        guard let eventFilter = filter else{
            return true
        }
        
        let filters = eventFilter.filters
        if filters == nil || filters?.count == 0{
            return true
        }
        
        if eventFilter.joinType.rawValue == CITriggerJoinType.and.rawValue{
            return evaluateAnd(propertyFilters: filters!, params: params,showLog: showLog)
        }
        else
        {
            return evaluateOr(propertyFilters: filters!, params: params,showLog: showLog)
            
        }
    }
    
    private func evaluateAnd(propertyFilters : [CIEventFilters], params : [String:Any]?,showLog : Bool? = true) -> Bool {
        for filter in propertyFilters {
            if let evaluator = getParamEvaluator(triggerType: filter.operation.propertyType.rawValue){
                
                if evaluator.evaluateCondition(value: params?[filter.name], propertyOperation: filter.operation) == false{
                    if showLog == true{
                        castledLog("Error:❌❌❌ Unable to satisfy the trigger condition: \(filter.name) for \(String(describing: params?[filter.name]))")
                    }
                    return false
                }
            }
            else
            {
                if showLog == true{
                    castledLog("Error:❌❌❌ No evaluator defined for property type: \(filter.operation.type)")
                }
                return false
                
            }
        }
        return true
    }
    private func evaluateOr(propertyFilters : [CIEventFilters], params : [String:Any]?,showLog : Bool? = true) -> Bool {
        for filter in propertyFilters {
            if let evaluator = getParamEvaluator(triggerType: filter.operation.propertyType.rawValue){
                
                if evaluator.evaluateCondition(value:params?[filter.name] , propertyOperation: filter.operation) == true{
                    return true
                }
            }
            else
            {
                if showLog == true{
                    castledLog("Error:❌❌❌ No evaluator defined for property type: \(filter.name)")
                }
                
            }
        }
        return false
    }
    private func getParamEvaluator(triggerType : String) -> (any CIParamsConditionEvaluatable)? {
        
        switch triggerType {
        case CITriggerPropertyType.string.rawValue:
            return CIStringEvaluator()
        case CITriggerPropertyType.number.rawValue:
            return CINumberEvaluator()
        case CITriggerPropertyType.bool.rawValue:
            return CIBoolEvaluator()
        case CITriggerPropertyType.date.rawValue:
            return CIDateEvaluator()
        default: break
            
        }
        return nil
    }
}
