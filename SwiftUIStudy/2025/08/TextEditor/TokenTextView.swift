//
//  TokenTextView.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/11/25.
//

import SwiftUI
import UIKit

class TokenTextView: UITextView {
    
    weak var controller: CustomTextEditorController?
    
    func attributedFromTokenText(_ text: String, baseFont f: UIFont) -> NSAttributedString {
        let ms = NSMutableAttributedString()
        let lines = text.components(separatedBy: .newlines) // 빈 줄 보존

        for (i, raw) in lines.enumerated() {
            var line = raw
            var kind: ListAttachment.Kind? = nil

            if line.hasPrefix("[Bullet] ")  { kind = .bullet;              line.removeFirst("[Bullet] ".count) }
            else if line.hasPrefix("[Checked] ") { kind = .check(isDone: true);  line.removeFirst("[Checked] ".count) }
            else if line.hasPrefix("[Check] ")   { kind = .check(isDone: false); line.removeFirst("[Check] ".count) }

            if let k = kind, let ctrl = controller {
                let att = ListAttachment(); att.kind = k
                if let img = ctrl.assetImage(for: k) {
                    att.image  = img
                    att.bounds = ctrl.fixedBounds(for: k, font: f) // ⬅️ 고정 크기/정렬 규칙 재사용
                }
                ms.append(NSAttributedString(attachment: att))
                ms.append(NSAttributedString(string: " ", attributes: [.font: f]))
            }

            ms.append(NSAttributedString(string: line, attributes: [.font: f]))
            if i < lines.count - 1 {
                ms.append(NSAttributedString(string: "\n", attributes: [.font: f]))
            }
        }
        return ms
    }
    
    override func paste(_ sender: Any?) {
        let f = font ?? .systemFont(ofSize: 18)
        let pb = UIPasteboard.general
        
        // 1) 문자열 우선 — 대부분의 앱이 plain text도 함께 넣습니다.
        if let s = pb.string {
            let insertion = attributedFromTokenText(s, baseFont: f) // 토큰 → 첨부 변환(토큰 없으면 그냥 평문)
            let sel = selectedRange
            textStorage.beginEditing()
            textStorage.replaceCharacters(in: sel, with: insertion)
            textStorage.endEditing()
            
            selectedRange = NSRange(location: sel.location + insertion.length, length: 0)
            typingAttributes = [.font: f]   // ⬅️ 폰트 축소 방지
            return
        }
        
        // 2) (선택) 리치텍스트만 있는 경우: 속성은 버리고 문자열만 사용
        if let items = pb.items.first {
            // 대충이라도 문자열 추출 시도
            for (uti, value) in items {
                if let attr = value as? NSAttributedString {
                    let s = attr.string
                    let insertion = attributedFromTokenText(s, baseFont: f)
                    let sel = selectedRange
                    textStorage.beginEditing()
                    textStorage.replaceCharacters(in: sel, with: insertion)
                    textStorage.endEditing()
                    selectedRange = NSRange(location: sel.location + insertion.length, length: 0)
                    typingAttributes = [.font: f]
                    return
                }
            }
        }
        
        // 3) 그 외 형식은 기본 동작으로
        super.paste(sender)
        // 그리고 폰트 보정(혹시 모를 축소 방지)
        typingAttributes = [.font: f]
    }
    
    // 선택 영역을 토큰 문자열로 변환
    private func tokenString(for range: NSRange) -> String {
        let fullLen = textStorage.length
        guard fullLen > 0, range.length > 0 else { return "" }

        let s = attributedText.string as NSString
        let sel = NSIntersectionRange(range, NSRange(location: 0, length: fullLen))
        guard sel.length > 0 else { return "" }

        var out: [String] = []
        var idx = sel.location
        let selEnd = sel.location + sel.length

        while idx < selEnd {
            // 현재 위치의 문단 범위
            let para = s.paragraphRange(for: NSRange(location: idx, length: 0))
            let inter = NSIntersectionRange(para, sel)
            if inter.length == 0 {
                idx = para.location + para.length
                continue
            }

            // 문단 시작에 첨부(마커)가 있는지
            var prefix = ""
            var bodyStart = para.location
            if para.location < fullLen,
               let att = attributedText.attribute(.attachment, at: para.location, effectiveRange: nil) as? ListAttachment {

                // 마커 → 토큰
                switch att.kind {
                case .bullet:                       prefix = "[Bullet] "
                case .check(let done):              prefix = done ? "[Checked] " : "[Check] "
                }

                // 마커 길이(첨부 1글자 + 공백 1글자면 2)
                bodyStart += 1
                if bodyStart < fullLen {
                    let next = s.substring(with: NSRange(location: bodyStart, length: 1))
                    if next == " " || next == "\t" { bodyStart += 1 }
                }
            }

            // 이 문단에서 "실제로 선택된" 본문 구간
            let sliceStart = max(inter.location, prefix.isEmpty ? inter.location : bodyStart)
            let sliceEnd   = min(inter.location + inter.length, para.location + para.length)
            let sliceLen   = max(0, sliceEnd - sliceStart)

            let body = (sliceLen > 0)
                ? s.substring(with: NSRange(location: sliceStart, length: sliceLen))
                    .trimmingCharacters(in: .newlines)
                : ""

            out.append(prefix + body)

            // 선택이 다음 문단으로 이어지면 개행 추가
            if sliceEnd < selEnd {
                out.append("\n")
            }

            idx = para.location + para.length
        }

        // 합치되, 마지막에 붙은 개행이 과하면 정리
        let joined = out.joined()
        return joined.hasSuffix("\n\n") ? String(joined.dropLast()) : joined
    }

    // 복사: 선택 영역을 토큰 텍스트로
    override func copy(_ sender: Any?) {
        let sel = selectedRange
        let token = tokenString(for: sel)
        if !token.isEmpty {
            UIPasteboard.general.string = token
        } else {
            // 선택이 없으면 기본 동작
            super.copy(sender)
        }
    }

    // 잘라내기: 토큰 텍스트로 복사 후, 선택 영역 삭제
    override func cut(_ sender: Any?) {
        let sel = selectedRange
        let token = tokenString(for: sel)
        if !token.isEmpty {
            UIPasteboard.general.string = token
            // 삭제
            textStorage.beginEditing()
            textStorage.replaceCharacters(in: sel, with: NSAttributedString(string: ""))
            textStorage.endEditing()

            // 커서/폰트 유지
            let f = font ?? .systemFont(ofSize: 18)
            selectedRange = NSRange(location: sel.location, length: 0)
            typingAttributes = [.font: f]
        } else {
            super.cut(sender)
        }
    }
}
