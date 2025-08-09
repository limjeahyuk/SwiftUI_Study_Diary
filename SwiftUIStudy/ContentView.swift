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
                }
                .foregroundStyle(.black)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .textEditor:
                    TestTextEditorView()
                }
                
            }
        }
        .environmentObject(router)
    }
}

