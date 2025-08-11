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
    
    @State var editorText: String = ""
    
    
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
                    logger.d("import Btn \(editorText)")
                    if let tv = editor.textView {
                        editor.importTokenText(editorText, into: tv, controller: editor, baseFont: tv.font ?? .systemFont(ofSize: 18))
                    }
                    
                    logger.d("import clear")
                    
                }label: {
                    Image(systemName: "photo")
                }
                .foregroundStyle(.black)
                
                Spacer()
                
                Button{
                    
                     let out: String = {
                       guard let tv = editor.textView else { return "" }
                         return editor.exportTokenText(from: tv)
                     }()
                    
                    logger.d("export Btn \(out)")
                    
                    editorText = out
                    
                }label: {
                    Image(systemName: "figure")
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
