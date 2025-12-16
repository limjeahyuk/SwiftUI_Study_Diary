//
//  ARCTest.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 12/16/25.
//

import SwiftUI

class Person {
    let name: String
    
    init(name: String) {
        self.name = name
        print("\(name) init")
    }
    
    deinit {
        print("\(name) deinit")
    }
}

class Owner {
    let name: String
    var pet: Pet?
    
    init(name: String) {
        self.name = name
        print("Owner \(name) init")
    }
    
    deinit {
        print("Owner \(name) deinit")
    }
}

class Pet {
    let name: String
    var owner: Owner?   // 기본은 strong
//    weak var owner: Owner?   // weak로 변경 > 약한참조
    
    init(name: String) {
        self.name = name
        print("Pet \(name) init")
    }
    
    deinit {
        print("Pet \(name) deinit")
    }
}

struct ARCTest: View {
    
    
    func arcBasicExample() {
        print("=== ARC Basic Example ===")
        
        var p1: Person? = Person(name: "혁쨩")
        // 여기서는 참조 카운트 = 1 (p1이 참조 중)
        
        p1 = nil
        // 참조 카운트 = 0 이 되는 순간 deinit 호출
    }
    
    func strongCycleExample() {
        print("=== Strong Reference Cycle Example ===")
        
        var owner: Owner? = Owner(name: "혁쨩")
        var pet: Pet? = Pet(name: "멍멍이")
        
        owner?.pet = pet   // Owner → Pet strong
        pet?.owner = owner // Pet → Owner strong (순환!)
        
        owner = nil
        pet = nil
        // 참조 카운트가 서로 1씩 남아 있어서 deinit이 안 불림
        // pet을 weak로 변경시 강한 참조가 없어져서 둘 다 deinit 호출 됨.
    }

    
    var body: some View {
        VStack(spacing: 10){
            Button{
                arcBasicExample()
            }label: {
                Text("ARC Basic TEST")
            }
            
            Button{
                strongCycleExample()
            }label: {
                Text("ARC Strong Reference Cycle TEST")
            }

        }
    }
}
