//
//  ContentView.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/8/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var router = FullScreenRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                Text("LIM Study Diary")
                    .font(.headline)
                    .padding(5)
                List{
                    Button{
                        router.push(.textEditor)
                    } label: {
                        Text("8M 2W")
                    }
                    Button {
                        router.push(.codeTest)
                    } label: {
                        Text("10M")
                    }
                    Button {
                        router.push(.DP)
                    } label: {
                        Text("Dynamic Programming")
                    }
                }
                .foregroundStyle(.white)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .textEditor:
                    TestTextEditorView()
                case .codeTest:
                    codeTest()
                case .DP:
                    DynamicProgramming()
                }
                
            }
        }
        .environmentObject(router)
    }
}

