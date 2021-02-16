//
//  NaiveSAT.swift
//  
//
//  Created by Markus Pfeifer on 05.10.20.
//

import Foundation



public extension Prop {
    
    ///Computes if there is an assignment of variables making this proposition true.
    var isSatisfiable : Bool {
        naiveWitnesses() != nil
    }
    
    ///Computes if there is no assignment of variables making this proposition true.
    var isUnsatisfiable : Bool {
        !(self.isSatisfiable)
    }
    
    ///Computes if the opposite statement is unsatisfiable.
    var isTautology : Bool {
        (!self).isUnsatisfiable
    }
    
    ///Computes if both this statement and its opposite are satisfiable.
    var isContingent : Bool {
        (self.isSatisfiable) && ((!self).isSatisfiable)
    }
    
    ///Uses a naive algorithm to find an assignment making this proposition true, if there is any.
    func naiveWitnesses() -> [String : Bool]? {
        //get all variables and call naiveWitnesses with those variables
        return naiveWitnesses(for: getVariables())
    }
    
    
}


internal extension Prop {
    
    
    @usableFromInline
     func naiveWitnesses<C : Collection>(for variables: C) -> [String : Bool]? where C.Element == String {
        
        //get the first element of the nonempty collection
        let member = variables.first!
        
        //lazily drop the first element
        let copy = variables.dropFirst()
        
        //return either a witness assigning the element to true or a witness assigning the element to false or nothing
        return  recWitnesses(for: copy,
                             assigning: member,
                             to: true) ??
            recWitnesses(for: copy,
                         assigning: member,
                         to: false)
        
    }
    
    
    @usableFromInline
     func recWitnesses<C : Collection>(for variables: C,
                                              assigning name: String,
                                              to value: Bool) -> [String : Bool]? where C.Element == String {
        
        //evaluate the proposition given the assignment
        switch evaluate(assignments: [name : value]){
            
        case .value(let bool):
            
            //if it is a value, return the assignment if the value is true or nothing otherwise
            return bool ? [name : value] : nil
            
        case .prop(let prop):
            
            //if the result is a proposition, try to get a witness for that proposition
            var out = prop.naiveWitnesses(for: variables)
            //set the value of the current variable to the current value
            out?[name] = value
            //return the assignment 
            return out
            
        }
        
    }
    
    
}



public extension Dictionary where Key == String, Value == Bool {
    
    func knf() -> Prop? {
        
        guard var prop = self.first.map({name, value in
            value ? Prop.atom(name: name) : Prop.not(.atom(name: name))
        }) else {
            return nil
        }
        
        for (name, value) in self.dropFirst() {
            prop = prop && (value ? .atom(name: name) : !.atom(name: name))
        }
        
        return prop
        
    }
    
}
