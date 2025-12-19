//
//  WebViewTest.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 12/17/25.
//

import SwiftUI
import WebKit



struct WebViewTest: View {
    var body: some View {
        WebView(urlString: "http://192.168.62.122:3000/")
            .ignoresSafeArea() // 전체 화면 덮기
    }
}

// MARK: - WKWebView 래퍼

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = " MyHybridApp/1.01111"

        let webView = WKWebView(frame: .zero, configuration: config)

        // 스크롤 관련 설정
        webView.scrollView.isScrollEnabled = false      // 필요에 따라 false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false

        // 네비게이션 / UIDelegate 연결
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {}
}
