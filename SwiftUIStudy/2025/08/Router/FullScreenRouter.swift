//
//  FullScreenRouter.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/8/25.
//

import UIKit
import SwiftUI

enum AppRoute: Hashable {
    case textEditor
    case codeTest
    case DP
    case ARC
}

final class FullScreenRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }
    
    func reset() {
        path.removeAll()
    }
    
    func widgetPush(_ route: AppRoute) {
        path.removeAll()
        path.append(route)
    }
}
