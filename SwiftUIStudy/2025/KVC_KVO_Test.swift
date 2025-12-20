//
//  KVCCode.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 12/20/25.
//

import SwiftUI

class KVCPerson: NSObject {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}

class Address: NSObject {
    @objc dynamic var city: String = ""
    @objc dynamic var zipCode: String = ""
}

class User: NSObject {
    @objc dynamic var name: String = ""
    @objc dynamic var address: Address = Address()
}

struct DeginPatternView: View {
    
    var body: some View {
        VStack (spacing: 30){
            Text("DeginPatternView")
            
            Button{
                let person = KVCPerson()

                // set
                person.setValue("혁쨩", forKey: "name")
                person.setValue(30, forKey: "age")

                // get
                if let name = person.value(forKey: "name") as? String {
                    print("이름:", name) // 이름: 혁쨩
                }

                if let age = person.value(forKey: "age") as? Int {
                    print("나이:", age) // 나이: 30
                }
                
                
            } label: {
                Text("KVC Pattern person")
            }
            
            Button{
                let user = User()
                user.setValue("서울시", forKeyPath: "address.city")
                user.setValue("01234", forKeyPath: "address.zipCode")

                if let city = user.value(forKeyPath: "address.city") as? String {
                    print(city) // 서울시
                }
            } label: {
                Text("KVC Pattern Address")
            }
            
            Button{
                let person = KVCPerson()

                // NSKeyValueObservation를 잡아둘 프로퍼티
                var observation: NSKeyValueObservation?

                observation = person.observe(\.name, options: [.old, .new]) { object, change in
                    print("이름이 변경됨: \(change.oldValue ?? "") -> \(change.newValue ?? "")")
                }

                person.name = "혁쨩"
                // 출력: 이름이 변경됨:  -> 혁쨩

                person.name = "재혁"
                // 출력: 이름이 변경됨: 혁쨩 -> 재혁
            } label: {
                Text("KVO Pattern Person")
            }
        }
    }
}
