import XCTest
import SAT

final class SATTests: XCTestCase {
    
    
    func testTrivial() {
        
        let prop1 : Prop = "X" || !"X"
        
        XCTAssert(prop1.isTautology)
        
        let prop2 : Prop = "X" && !"X"
        
        XCTAssert(prop2.isUnsatisfiable)
        
        XCTAssert((prop2 => "Y").isTautology)
        
        let prop3 : Prop = ("A" => "B") <=> (!"B" => !"A")
        
        XCTAssert(prop3.isTautology)
        
        let prop4 : Prop = (("A" => "B") && ("B" => "A")) <=> ("A" <=> "B")
        
        XCTAssert(prop4.isTautology)
        
        let prop5 : Prop = "A" || "B"
        
        XCTAssert(prop5.isContingent)
        
        let prop6 : Prop = "A" && ("A" => "B") => "B"
        
        XCTAssert(prop6.isTautology)
        
    }
    
    
    
    func testDNFSimple() {
        
        let nVars = 500
        
        let vars = (0..<nVars).map{"V\($0)"}
        
        let assignments = (0..<250).map{_ in
            Dictionary(uniqueKeysWithValues: vars.map{($0, Bool.random())})
        }
        
        let prop = assignments.dropFirst().lazy.map{$0.knf()!}
            .reduce(assignments.first!.knf()!, ||)
        
        guard let actualAsg = prop.naiveWitnesses() else {
            return XCTFail()
        }
        
        XCTAssert(assignments.contains(actualAsg))
        
        switch (prop).evaluate(assignments: actualAsg) {
         
        case .value(let bool):
            
            XCTAssert(bool)
            
        case .prop:
            
            XCTFail()
            
        }
        
    }
    
    func testHardInstance() {
        
        let nVars = 500
        
        let vars = (0..<nVars).map{"V\($0)"}
        
        let disjunctions = (0..<500).lazy.map{_ in
            vars.filter{_ in .random()}
            // (0..<3).map{_ in vars.randomElement()!}//alternative
        }.compactMap{(vars) -> Prop? in
            guard let first = vars.first else {
                return nil
            }
            return vars.dropFirst().lazy.map({Bool.random() ? .atom(name: $0) : !.atom(name: $0)}).reduce(Prop.atom(name: first), ||)
        }
        
        guard
            let first = disjunctions.first,
            disjunctions.count > 250 else {
            return testHardInstance()
        }
        
        let prop = disjunctions.dropFirst().reduce(first, &&)
        
        if let asg = prop.naiveWitnesses() {
            switch prop.evaluate(assignments: asg) {
            case .value(let val):
                XCTAssert(val)
            case .prop:
                XCTFail()
            }
        }
        else {
            guard let asg = (!prop).naiveWitnesses() else {
                return XCTFail()
            }
            switch prop.evaluate(assignments: asg) {
            case .value(let val):
                XCTAssert(val)
            case .prop:
                XCTFail()
            }
        }
        
    }
    
    

    static var allTests = [
        ("testTrivial", testTrivial),
        ("testDNFSimple", testDNFSimple),
        ("testHardInstance", testHardInstance)
    ]
}
