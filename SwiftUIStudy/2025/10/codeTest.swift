//
//  codeTest.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 9/30/25.
//

import SwiftUI

struct codeTest: View {
    
    func repeatingString(){
        let s1 = "string"
        let a = 5
        
        if (1...10).contains(s1.count), (1...5).contains(a) {
            let result = String(repeating: s1, count: a)
            print(result)
        }
        
    }
    
    func changeUpLow() {
        let s1 = "aBCdEFghIj"
        
        if (1...20).contains(s1.count) {
            // map 함수를 이용해서 각 글자마다 확인
            // map함수를 이용하면 배열로 return 하기에 .joined를 이용해서 하나로 합쳐주기.
            let toggled = s1.map { ch in
                ch.isLowercase ? String(ch).uppercased() : String(ch).lowercased()
            }.joined()
            
            print(toggled)
        }
        
    }
    
    func specialChar(){
        print(#"!@#$%^&*(\'"<>?:;"#)
    }
    
    func plusFunc() {
        let a = 4
        let b = 5
        
        print("\(a) + \(b) = \(a+b)")
    }
    
    func trimChar(){
        let char = "hell o wor ld "
        
        let result = char.replacingOccurrences(of: " ", with: "")
        
        print(result)
    }
    
    func turnChar(){
        let s1 = "abcdef"
        if (1...10).contains(s1.count) {
            for char in s1 {
                print(char)
            }
        }
    }
    
    func oddOrEven(){
        let a = 100
        if (1...1000).contains(a) {
            if a%2 == 0 {
                print("\(a) is even")
            }else{
                print("\(a) is odd")
            }
        }
    }
    
    func charSolution(_ my_string:String, _ overwrite_string:String, _ s:Int) -> String {
        
        var result = my_string
        
        let i = my_string.index(my_string.startIndex, offsetBy: s)
        let replaceCount = overwrite_string.count
        
        let j = my_string.index(i, offsetBy: replaceCount)
        
        result.replaceSubrange(i..<j, with: overwrite_string)
        
        return result
    }
    
    func mixSolution(_ str1:String, _ str2:String) -> String {
        /*
        var result = ""
        var i = str1.startIndex
        
        for _ in 0..<str1.count {
            result += String(str1[i])
            result += String(str2[i])
            i = str1.index(after: i)
        }
        
        return result
         */
        
        return zip(str1, str2).map { String($0) + String($1) }.joined()
    }
    
    func listSolution(_ arr: [String]) -> String {
        
        // joined() : 배열을 String으로
        return arr.joined()
    }
    
    func multiSolution(_ my_string:String, _ k:Int) -> String {
        
        // repeating, count : repeating String을 count 만큼 반복해서 String으로 변환.
        return String(repeating: my_string, count: k)
    }
    
    func maxSolution(_ a: Int, _ b: Int) -> Int{
        /*
        let stringAB = "\(a)\(b)"
        let stringBA = "\(b)\(a)"
        
        if Int(stringAB)! >= Int(stringBA)! {
            return Int(stringAB)!
        }else{
            return Int(stringBA)!
        }
         */
        
        // max를 사용하면 더 간단하게 더 높은 수를 찾을 수 있습니다.
        return max(Int(String(a) + String(b))!, Int(String(b) + String(a))!)
    }
    
    func compareSolution(_ a:Int, _ b:Int) -> Int {
        
        return max(Int(String(a) + String(b))!, 2 * a * b)
    }
    
    func NSolution(_ num:Int, _ n:Int) -> Int {
        
        guard (2...100).contains(num), (2...9).contains(n) else {
            return 0
        }
        
        /*
        if num % n == 0 {
            return 1
        }else{
            return 0
        }
         */
        
        // 배수를 확인하는 함수. isMultiple
        return num.isMultiple(of: n) ? 1 : 0
    }
    
    func twoMultiSolution(_ number:Int, _ n:Int, _ m:Int) -> Int {
        
        return number.isMultiple(of: n) && number.isMultiple(of: m) ? 1 : 0
    }
    
    func OESolution(_ n:Int) -> Int {
        
        var result = 0
        
        if n % 2 == 0 {
            // 짝수
            for i in 1...n {
                if i % 2 == 0 {
                    // pow(num, n) num의 n 제곱.
                    let resultOfPow = pow(Double(i), 2.0)
                    result += Int(resultOfPow)
                    // reduce(0, +) 0번째부터 계속 더하기.
                }
            }
        }else{
            // 홀수
            for i in 1...n {
                if i % 2 != 0 {
                    result += i
                }
            }
        }
        return result
        
        // reduce 를 이용하여 모든 값을 한번에 더하기.
        // map 함수를 이용하여 제곱을 표현.
        // return n % 2 == 1 ? (1...n).filter { $0 % 2 == 1 }.reduce(0, +) : (0...n).filter { $0 % 2 == 0 }.map { $0 * $0 }.reduce(0, +)
    }
    
    func conditionSolution(_ ineq:String, _ eq:String, _ n:Int, _ m:Int) -> Int {
        switch ineq+eq {
             case ">=": return n >= m ? 1 : 0
             case "<=": return n <= m ? 1 : 0
             case ">!": return n > m ? 1 : 0
             case "<!": return n < m ? 1 : 0
             default: return 0
         }
    }
    
    var body: some View {
        Text("Coding Test Func")
        List {
            Button{
                repeatingString()
            }label: {
                Text("문자열 반복해서 출력하기")
            }
            
            Button {
                changeUpLow()
            }label: {
                Text("대소문자 변환")
            }
            
            Button {
                specialChar()
            }label: {
                Text("특수문자 출력하기")
            }
            
            Button {
                plusFunc()
            }label: {
                Text("덧셈식 계산하기")
            }
            
            Button {
                trimChar()
            }label: {
                Text("공백 제거")
            }
            
            Button {
                turnChar()
            }label: {
                Text("문자열 돌리기")
            }
            
            Button {
                oddOrEven()
            }label: {
                Text("홀짝 구분하기")
            }
            
            Button {
                let result = charSolution("Program29b8UYP", "merS123", 7)
                print(result)
            }label: {
                Text("문자열 겹쳐쓰기")
            }
            
            Button {
                let result = mixSolution("aaaaa", "bbbbb")
                print(result)
            }label: {
                Text("문자열 섞기")
            }
            
            Button {
                let result = mixSolution("aaaaa", "bbbbb")
                print(result)
            }label: {
                Text("문자 리스트를 문자열로 변환")
            }
            
            Button {
                let result = multiSolution("string", 3)
                print(result)
            }label: {
                Text("문자열 곱하기")
            }
            
            Button {
                let result = maxSolution(91, 9)
                print(result)
            }label: {
                Text("더 크게 합치기")
            }
            
            Button {
                let result = compareSolution(2, 91)
                print(result)
            }label: {
                Text("두 수의 연산값 비교")
            }
            
            Button {
                let result = NSolution(90, 3)
                print(result)
            }label: {
                Text("n의 배수")
            }
            
            Button {
                let result = twoMultiSolution(55, 10, 5)
                print(result)
            }label: {
                Text("공배수")
            }
            
            Button {
                let result = OESolution(7)
                print(result)
            }label: {
                Text("홀짝에 따라 다른 값 반환하기")
            }
            
            Button {
                let result = conditionSolution("<", "=", 20, 50)
                print(result)
            }label: {
                Text("조건 문자열")
            }
        }
    }
}


