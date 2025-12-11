//
//  DynamicProgramming.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 12/11/25.
//

import SwiftUI

struct DynamicProgramming: View {
    
    let testValues = [10, 20, 30, 35, 40]   // 점점 늘려보기
    
    // 1. 순수 재귀 (Naive, 비추천)
    func fibNaive(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibNaive(n - 1) + fibNaive(n - 2)
    }

    // 2. Top-Down (재귀 + 메모이제이션)
    func fibTopDown(_ n: Int) -> Int {
        var memo = Array(repeating: -1, count: n + 1)

        func dfs(_ x: Int) -> Int {
            if x <= 1 { return x }
            if memo[x] != -1 { return memo[x] }   // 이미 계산된 값 있으면 재사용

            let value = dfs(x - 1) + dfs(x - 2)
            memo[x] = value
            return value
        }

        return dfs(n)
    }

    // 3. Bottom-Up (반복문)
    func fibBottomUp(_ n: Int) -> Int {
        if n <= 1 { return n }

        var dp = Array(repeating: 0, count: n + 1)
        dp[0] = 0
        dp[1] = 1

        for i in 2...n {
            dp[i] = dp[i - 1] + dp[i - 2]
        }

        return dp[n]
    }
    
    func measureTime(label: String, _ block: () -> Int) {
        let start = CFAbsoluteTimeGetCurrent()
        let result = block()
        let end = CFAbsoluteTimeGetCurrent()
        let elapsed = end - start

        print("\(label): result = \(result), time = \(String(format: "%.6f", elapsed)) sec")
    }
    
    var body: some View {
        Text("DynamicProgramming")
        
        Spacer()
        
        Button{
            for n in testValues {
                print("===== n = \(n) =====")
                measureTime(label: "Naive      ") {
                    fibNaive(n)
                }
                measureTime(label: "Top-Down   ") {
                    fibTopDown(n)
                }
                measureTime(label: "Bottom-Up  ") {
                    fibBottomUp(n)
                }
                print("")
            }
        } label: {
            Text("click")
        }
        
        Spacer()
        
    }
}
