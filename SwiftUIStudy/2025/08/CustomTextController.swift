//
//  CustomTextController.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/9/25.
//

import SwiftUI
import UIKit

// 불릿/체크박스 마커를 위한 Attachment
final class ListAttachment: NSTextAttachment {
    enum Kind {
        case bullet
        case check(isDone: Bool)
    }
    var kind: Kind = .bullet
}

// 1) 에디터 제어 컨트롤러 (SwiftUI 버튼에서 안전하게 호출)
final class CustomTextEditorController: ObservableObject {
    weak var textView: UITextView?

    func insertBullet() { insertOrToggle(.bullet) }
    func insertCheck()  { insertOrToggle(.check(isDone: false)) }

    // MARK: - Core
    private func insertOrToggle(_ target: ListAttachment.Kind) {
        guard let tv = textView else { return }
        if !tv.isFirstResponder { tv.becomeFirstResponder() }

        let f = currentFont(tv)
        let caret = tv.selectedRange.location
        let para  = paragraphRange(in: tv, at: caret)
        let ms    = tv.textStorage

        // 이미 문단 시작에 마커가 있는지 확인
        if let (att, attachRange) = hasAttachmentAtParagraphStart(tv, range: para),
           let listAtt = att as? ListAttachment {

            switch (listAtt.kind, target) {
            case (.bullet, .bullet), (.check, .check):
                // 같은 종류 버튼을 다시 누르면 => 마커 제거 (토글 OFF)
                let mlen = markerLength(tv, paragraphRange: para) // attachment + 공백(또는 탭)
                let deleteRange = NSRange(location: para.location, length: mlen)

                let oldSel = tv.selectedRange
                ms.beginEditing()
                ms.deleteCharacters(in: deleteRange)
                ms.endEditing()

                // 커서 보정
                var newLoc = oldSel.location
                if oldSel.location >= para.location + mlen { newLoc -= mlen }
                else { newLoc = para.location }
                tv.selectedRange = NSRange(location: max(para.location, newLoc), length: 0)

                // 다음 입력 폰트 고정
                tv.typingAttributes = [.font: f]
                return

            default:
                // 다른 종류였다면 => 종류 변경 (불릿 ↔ 체크)
                let newKind: ListAttachment.Kind = {
                    switch target {
                    case .bullet: return .bullet
                    case .check:  return .check(isDone: false) // 토글로 만든 것이므로 기본 미완료
                    }
                }()

                listAtt.kind  = newKind
                listAtt.image = imageFor(kind: newKind, font: f)
                listAtt.bounds = CGRect(x: 0, y: f.descender, width: f.lineHeight, height: f.lineHeight)

                // 첨부 한 글자만 교체, 뒤의 공백은 유지
                ms.beginEditing()
                ms.replaceCharacters(in: attachRange, with: NSAttributedString(attachment: listAtt))

                // 마커 뒤 공백 1칸에 폰트 속성 보강 (폰트 작아지는 현상 방지)
                let spaceLoc = attachRange.location + 1
                if spaceLoc < ms.length {
                    let s = tv.attributedText.string as NSString
                    if s.substring(with: NSRange(location: spaceLoc, length: 1)) == " " {
                        ms.addAttribute(.font, value: f, range: NSRange(location: spaceLoc, length: 1))
                    }
                }
                ms.endEditing()

                tv.typingAttributes = [.font: f]
                return
            }
        }

        // 마커가 없으면 => 새로 삽입
        let att   = markerAttachment(for: target, font: f)
        let space = NSAttributedString(string: " ", attributes: [.font: f])
        let marker = NSAttributedString(attachment: att) + space

        ms.beginEditing()
        ms.replaceCharacters(in: NSRange(location: para.location, length: 0), with: marker)
        ms.endEditing()

        // 커서 보정
        let delta = marker.length
        let newSelLoc = (caret >= para.location) ? caret + delta : para.location + delta
        tv.selectedRange = NSRange(location: newSelLoc, length: 0)

        tv.typingAttributes = [.font: f]
    }

    // MARK: - Helpers
    private func markerAttachment(for kind: ListAttachment.Kind, font: UIFont) -> ListAttachment {
        let at = ListAttachment()
        at.kind = kind
        at.image = imageFor(kind: kind, font: font)
        at.bounds = CGRect(x: 0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
        return at
    }

    private func imageFor(kind: ListAttachment.Kind, font: UIFont) -> UIImage? {
        let size = font.pointSize * 0.9
        let cfg  = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
        switch kind {
        case .bullet:                 return UIImage(systemName: "circle.fill", withConfiguration: cfg)
        case .check(let isDone):      return UIImage(systemName: isDone ? "checkmark.square.fill" : "square", withConfiguration: cfg)
        }
    }

    private func currentFont(_ tv: UITextView) -> UIFont {
        if let f = tv.font { return f }
        if let f = tv.typingAttributes[.font] as? UIFont { return f }
        return .systemFont(ofSize: 18)
    }

    private func paragraphRange(in tv: UITextView, at location: Int) -> NSRange {
        let ns = tv.attributedText.string as NSString
        let loc = max(0, min(location, ns.length))
        return ns.paragraphRange(for: NSRange(location: loc, length: 0))
    }

    private func hasAttachmentAtParagraphStart(_ tv: UITextView, range: NSRange)
    -> (NSTextAttachment, NSRange)? {
        guard range.location < tv.attributedText.length else { return nil }
        var eff = NSRange()
        if let att = tv.attributedText.attribute(.attachment, at: range.location, effectiveRange: &eff) as? NSTextAttachment {
            return (att, eff)
        }
        return nil
    }

    private func markerLength(_ tv: UITextView, paragraphRange: NSRange) -> Int {
        // attachment 1글자 + (공백/탭) 1글자
        var len = 0
        if tv.attributedText.attribute(.attachment, at: paragraphRange.location, effectiveRange: nil) != nil { len += 1 }
        if paragraphRange.location + len < tv.attributedText.length {
            let s = tv.attributedText.string as NSString
            let next = s.substring(with: NSRange(location: paragraphRange.location + len, length: 1))
            if next == " " || next == "\t" { len += 1 }
        }
        return len
    }
}

// 편의: NSAttributedString 이어 붙이기
private func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let m = NSMutableAttributedString(attributedString: lhs)
    m.append(rhs)
    return m
}
