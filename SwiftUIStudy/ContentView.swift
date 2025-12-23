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
                    Button {
                        router.push(.ARC)
                    } label: {
                        Text("ARC Test")
                    }
                    
                    Button {
                        router.push(.WKWebView)
                    } label: {
                        Text("WKWebView Test")
                    }
                    
                    Button {
                        router.push(.DeginPattern)
                    } label: {
                        Text("DeginPattern Test")
                    }
                    
                    Button {
                        router.push(.segment)
                    } label: {
                        Text("Segment Crash Test")
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
                case .ARC:
                    ARCTest()
                case .WKWebView:
                    WebViewTest()
                case .DeginPattern:
                    DeginPatternView()
                case .segment:
                    SegmentationCrash()
                }
                
            }
        }
        .environmentObject(router)
    }
}

