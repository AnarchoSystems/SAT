//
//  Prop.swift
//  
//
//  Created by Markus Pfeifer on 05.10.20.
//

import Foundation



infix operator => : AssignmentPrecedence
infix operator <=> : AssignmentPrecedence


///Encapsulates a logical proposition.
public enum Prop : ExpressibleByStringLiteral {
    ///The proposition is just a variable.
    case atom(name: String)
    ///Conjunction of two propositions.
    indirect case and(Prop, Prop)
    ///Disjunction of two propositions.
    indirect case or(Prop, Prop)
    ///Negation of a proposition.
    indirect case not(Prop)
    
    //Enables code like ```let a : Prop = "A"```
    public init(stringLiteral value: String) {
        self = .atom(name: value)
    }
    
}

extension Prop : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .atom(let name):
            return name
        case .and(let p, let q):
            return "(" + p.description + " && " + q.description + ")"
        case .or(let p, let q):
            return "(" + p.description + " || " + q.description + ")"
        case .not(let p):
            return "!" + p.description
        }
    }
    
}

public extension Prop {
    

    ///The conjunction of lhs and rhs.
    /// - Returns: .and(lhs, rhs)
    static func &&(lhs: Prop, rhs: Prop) -> Prop {
        .and(lhs, rhs)
    }
    
    ///The disjunction of lhs and rhs.
    /// - Returns: .or(lhs, rhs)
    static func ||(lhs: Prop, rhs: Prop) -> Prop {
        .or(lhs, rhs)
    }
    
    ///The conjunction of the proposition.
    /// - Returns: .not(prop)
    static prefix func !(prop: Prop) -> Prop {
        .not(prop)
    }
    
    ///lhs implies rhs.
    /// - Returns: (!lhs) || rhs
    static func =>(lhs: Prop, rhs: Prop) -> Prop {
        (!lhs) || rhs
    }
    
    ///The equivalence of lhs and rhs.
    /// - Returns: (lhs && rhs) || ((!lhs) && (!rhs))
    static func <=>(lhs: Prop, rhs: Prop) -> Prop {
        (lhs && rhs) || ((!lhs) && (!rhs))
    }
    
    
    ///Evaluates the proposition given variable assignments to boolean values.
    /// - Parameters:
    ///     - assignments: A function mapping variable names to boolean values or leaving them open.
    /// - Returns: Either  a boolean value or a partially evaluated proposition.
    func evaluate(assignments: (String) -> Bool?) -> EvaluatedProp {
        
        //Make case distinction
        switch self {
            
        case .atom(let name):
            //if atom, just look up the truth value if present
            return assignments(name).map(EvaluatedProp.value) ?? .prop(self)
            
        case let .and(lhs, rhs):
            
            //if conjunction, evaluate both
            
            switch (lhs.evaluate(assignments: assignments),
                    rhs.evaluate(assignments: assignments)){
                
                //if both sides are values, return the conjunction of values
            case (.value(let lv), .value(let rv)):
                return .value(lv && rv)
                
                //if one is a value, short circuit
                
            case (.value(let val), .prop(let prop)):
                return val ? .prop(prop) : .value(false)
                
            case (.prop(let prop), .value(let val)):
                return val ? .prop(prop) : .value(false)
                
                //if both are propositions, return the conjunction of those propositions
            case (.prop(let lp), .prop(let rp)):
                return .prop(lp && rp)
                
            }
            
        case let .or(lhs, rhs):
            
            //if disjunction, evaluate both
            
            switch (lhs.evaluate(assignments: assignments),
                    rhs.evaluate(assignments: assignments)){
                
                //if both sides are values, return the disjunction of values
            case (.value(let lv), .value(let rv)):
                return .value(lv || rv)
                
                //if one is a value, short circuit
                
            case (.value(let val), .prop(let prop)):
                return val ? .value(true) : .prop(prop)
                
            case (.prop(let prop), .value(let val)):
            return val ? .value(true) : .prop(prop)
                
                //if both are propositions, return the disjunction of those propositions
            case (.prop(let lp), .prop(let rp)):
                return .prop(lp || rp)
                
            }
            
        case .not(let prop):
            
            //if negation... 
            switch prop.evaluate(assignments: assignments) {
                //if the wrapped proposition evaluates to a value, return the opposite value
            case .value(let val):
                return .value(!val)
                //if the wrapped proposition evaluates to a proposition again, return the negated proposition
            case .prop(let prop):
                return .prop(!prop)
            }
        }
        
    }
    
    ///Evaluates the proposition given variable assignments to boolean values.
    /// - Parameters:
    ///     - assignments: A dictionary mapping variable names to boolean values or leaving them open.
    /// - Returns: Either  a boolean value or a partially evaluated proposition.
    func evaluate(assignments: [String : Bool]) -> EvaluatedProp {
        evaluate{assignments[$0]}
    }
    
    
    ///Returns all the open variables in the formula.
    /// - Returns: A set containing all the variables in the formula, i.e., the formula is guaranteed to evaluate to a boolean value, if each of these strings is assigned a boolean value.
    func getVariables() -> Set<String> {
        switch self {
        case .atom(let name):
            return [name]
        case .and(let lhs, let rhs):
            let (l, r) = (lhs.getVariables(), rhs.getVariables())
            return l.union(r)
        case .or(let lhs, let rhs):
            let (l, r) = (lhs.getVariables(), rhs.getVariables())
            return l.union(r)
        case .not(let prop):
            return prop.getVariables()
        }
    }
    
    
    enum EvaluatedProp {
        case value(Bool)
        case prop(Prop)
    }
    
}
