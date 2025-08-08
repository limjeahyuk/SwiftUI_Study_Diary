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
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world!")
                    .padding()
                
                Button{
                    router.push(.textEditor)
                } label: {
                    Text("textEditor view")
                }
                
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

