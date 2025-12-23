//
//  SegmentationCrash.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 12/23/25.
//

import SwiftUI

struct SegmentationCrash: View {
    
    func segfaultLikeCrash() {
        for _ in 0..<1_000_000 {
            let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            ptr.initialize(to: 10)
            ptr.deallocate()

            // 해제된 메모리에 계속 접근
            _ = ptr.pointee
        }
    }
    
    var body: some View {
        Button{
            segfaultLikeCrash()
        } label: {
            Text("Segmentation Crash")
        }
    }
}
