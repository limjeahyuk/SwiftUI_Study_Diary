//
//  TestTextEditorView.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/8/25.
//

import SwiftUI
import UIKit

struct TestTextEditorView: View {
    
    @State private var text: String = ""
    @State private var isFocused: Bool = false
    @StateObject private var editor = CustomTextEditorController()
    
    
    var body: some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button{
                    logger.d("listBullet")
                    editor.insertBullet()
                }label: {
                    Image(systemName: "list.bullet")
                }
                .foregroundStyle(.black)
                
                Spacer()
                
                Button{
                    logger.d("checkmark Button")
                    editor.insertCheck()
                }label: {
                    Image(systemName: "checkmark.square.fill")
                }
                .foregroundStyle(.black)
                
                Spacer()
                
                Button{
                    logger.d("Image Button")
                }label: {
                    Image(systemName: "photo")
                }
                .foregroundStyle(.black)
                
                Spacer()
            }
            .padding(5)
            .background(Color(.systemGray6))
            
            Spacer()
            
            CustomTextEditorView(text: $text, isFocused: $isFocused, controller: editor)
                .padding(5)
                .border(Color.gray, width: 1)
        }
    }
}
