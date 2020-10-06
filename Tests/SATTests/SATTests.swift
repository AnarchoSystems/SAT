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
    
    
    
    func testUnsat() {
        
        let nVars = 500
        
        let vars = (0..<nVars).map{"V\($0)"}
        
        let nHalf = nVars / 2
        
        var prop : Prop = .atom(name: vars[0])
        
        for (idx, name) in vars.enumerated().dropFirst() {
            
            if idx == nHalf {
                prop = prop && !.atom(name: vars.last!)
            }
            
            prop = prop && .atom(name: name)
            
        }
        
        if nil != prop.naiveWitnesses() {
            return XCTFail()
        }
        
        guard let actualAsg = (!prop).naiveWitnesses() else {
            return XCTFail()
        }
        
        switch (!prop).evaluate(assignments: actualAsg) {
         
        case .value(let bool):
            
            XCTAssert(bool)
            
        case .prop:
            
            XCTFail()
            
        }
        
    }
    
    

    static var allTests = [
        ("testTrivial", testTrivial),
        ("testUnsat", testUnsat)
    ]
}
