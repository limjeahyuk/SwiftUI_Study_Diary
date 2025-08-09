//
//  CustomTextEditor.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/9/25.
//

import SwiftUI
import UIKit

struct CustomTextEditorView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @ObservedObject var controller: CustomTextEditorController

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.allowsEditingTextAttributes = true
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .systemFont(ofSize: 18)
        textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 18)]

        // 초기 텍스트를 속성문자열로 (첨부 보존)
        textView.attributedText = NSAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 18)]
        )

        // ⬇️ 체크 토글용 탭 제스처
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(context.coordinator.handleTap(_:)))
        tap.delegate = context.coordinator   // ⬅️ 델리게이트 설정
        tap.cancelsTouchesInView = false     // ⬅️ 기본 커서 이동/선택을 막지 않음
        tap.delaysTouchesBegan = false
        textView.addGestureRecognizer(tap)
        
        // 컨트롤러에서 실제 UITextView 접근 가능하도록 연결
        controller.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // ❌ 여기서 uiView.text = text 를 하면 첨부가 날아감
        if isFocused, !uiView.isFirstResponder { uiView.becomeFirstResponder() }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: CustomTextEditorView
        init(_ parent: CustomTextEditorView) { self.parent = parent }
        
        // ✅ 캐럿/선택 변경 시, 마커 위/앞에 걸리면 마커 뒤로 스냅
        func textViewDidChangeSelection(_ tv: UITextView) {
            // 드래그로 범위 선택 중이면 손대지 않음
            guard tv.selectedRange.length == 0 else { return }

            let length = tv.textStorage.length
            guard length > 0 else { return }  // ⬅️ 빈 문서일 때 바로 종료

            let loc = min(tv.selectedRange.location, max(0, length)) // 안전 클램프
            let para = paragraphRange(in: tv, at: loc)
            let mlen = markerLength(tv, paragraphRange: para)

            // 문단 시작에 마커가 있고, 캐럿이 마커 영역(첨부/공백) 안이면 → 마커 뒤로 스냅
            let target = para.location + mlen
            if mlen > 0, loc <= target, tv.selectedRange.location != target {
                tv.selectedRange = NSRange(location: target, length: 0)
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            // 바인딩 text는 "순수 텍스트"만 동기화 (첨부는 별도 보관/직렬화 대상)
            parent.text = textView.text
        }
        
        // ✅ 제스처가 인식될지 사전에 판단: 마커 영역에 '정확히' 들어온 탭만 허용
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let tv = parent.controller.textView, gestureRecognizer is UITapGestureRecognizer else { return false }
            let viewPt = touch.location(in: tv)

            // 탭 지점이 속한 문단 시작에 마커가 있는지, 그리고 마커 히트박스인지 확인
            return hitMarker(in: tv, at: viewPt) != nil
        }
        
        // ⬇️ 체크 아이콘 토글
        @objc func handleTap(_ gr: UITapGestureRecognizer) {
            guard let tv = gr.view as? UITextView else { return }
            let viewPt = gr.location(in: tv)

            // 탭 위치가 속한 문단을 구하기 위해 문자 오프셋 구함
            guard let pos = tv.closestPosition(to: viewPt) else { return }
            let caret = tv.offset(from: tv.beginningOfDocument, to: pos)
            let para = paragraphRange(in: tv, at: caret)

            // 문단 시작에 붙은 첨부(아이콘) 확인
            guard let (att, attachRange) = hasAttachmentAtParagraphStart(tv, range: para),
                  let listAtt = att as? ListAttachment else { return }

            // 첨부의 글리프 사각형(텍스트 컨테이너 좌표계)
            let lm = tv.layoutManager
            let tc = tv.textContainer
            let glyphRange = lm.glyphRange(forCharacterRange: attachRange, actualCharacterRange: nil)
            var rect = lm.boundingRect(forGlyphRange: glyphRange, in: tc)

            // 제스처 좌표를 텍스트 컨테이너 좌표로 변환
            let tapInTextContainer = CGPoint(
                x: viewPt.x - tv.textContainerInset.left,
                y: viewPt.y - tv.textContainerInset.top + tv.contentOffset.y
            )

            // 히트 영역 넉넉히
            rect = rect.insetBy(dx: -8, dy: -8)

            guard rect.contains(tapInTextContainer) else { return }

            // 체크만 토글 (불릿은 무시)
            guard case .check(let done) = listAtt.kind else { return }

            let f = currentFont(tv) // ⬅️ 아래 헬퍼 참고
            let newDone = !done

            // ✅ 아이콘 이미지 + bounds를 현재 폰트 기준으로 재설정
            listAtt.kind = .check(isDone: newDone)
            listAtt.image = imageForCheck(isDone: newDone, font: f)
            listAtt.bounds = CGRect(x: 0, y: f.descender, width: f.lineHeight, height: f.lineHeight)

            let curSel = tv.selectedRange
            tv.textStorage.beginEditing()
            tv.textStorage.replaceCharacters(in: attachRange,
                                             with: NSAttributedString(attachment: listAtt))

            // ✅ (중요) 마커 뒤 공백이 있으면 그 1글자에 폰트 속성을 다시 보강
            let spaceLoc = attachRange.location + 1
            if spaceLoc < tv.textStorage.length {
                let s = tv.attributedText.string as NSString
                if s.substring(with: NSRange(location: spaceLoc, length: 1)) == " " {
                    tv.textStorage.addAttribute(.font, value: f, range: NSRange(location: spaceLoc, length: 1))
                }
            }
            tv.textStorage.endEditing()

            tv.selectedRange = curSel
            // ✅ 새로 입력할 글자의 typingAttributes도 확실히 고정
            tv.typingAttributes = [.font: f]
        }
        
        // MARK: - 마커 히트 판정
        private func hitMarker(in tv: UITextView, at viewPt: CGPoint)
            -> (ListAttachment, NSRange, NSRange)? {
            // 탭 위치 기준으로 문단/첨부 찾기
            guard let pos = tv.closestPosition(to: viewPt) else { return nil }
            let caret = tv.offset(from: tv.beginningOfDocument, to: pos)
            let para = paragraphRange(in: tv, at: caret)

            guard let (att, attachRange) = hasAttachmentAtParagraphStart(tv, range: para),
                  let listAtt = att as? ListAttachment else { return nil }

            // 첨부 글리프 사각형(텍스트 컨테이너 좌표)
            let lm = tv.layoutManager
            let tc = tv.textContainer
            let glyphRange = lm.glyphRange(forCharacterRange: attachRange, actualCharacterRange: nil)
            var rect = lm.boundingRect(forGlyphRange: glyphRange, in: tc)

            // 제스처 좌표를 텍스트 컨테이너 좌표로 변환
            let pt = CGPoint(x: viewPt.x - tv.textContainerInset.left,
                             y: viewPt.y - tv.textContainerInset.top + tv.contentOffset.y)

            // 너무 넓게 잡지 말고, 살짝만 여유
            rect = rect.insetBy(dx: -4, dy: -4)

            return rect.contains(pt) ? (listAtt, attachRange, para) : nil
        }

        // MARK: - Helpers (탭 처리에 필요한 것들만 로컬 복붙)
        private func paragraphRange(in tv: UITextView, at location: Int) -> NSRange {
            let ns = tv.attributedText.string as NSString
            let loc = max(0, min(location, ns.length))
            return ns.paragraphRange(for: NSRange(location: loc, length: 0))
        }
        
        private func currentFont(_ tv: UITextView) -> UIFont {
            if let f = tv.font { return f }
            if let f = tv.typingAttributes[.font] as? UIFont { return f }
            return .systemFont(ofSize: 18)
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
            let length = tv.textStorage.length
            let start = paragraphRange.location
            guard start < length else { return 0 }   // ⬅️ 빈 문자열/끝 인덱스 방어

            var len = 0
            if tv.attributedText.attribute(.attachment, at: start, effectiveRange: nil) != nil {
                len += 1
            }

            if start + len < length {
                let s = tv.attributedText.string as NSString
                let nextChar = s.substring(with: NSRange(location: start + len, length: 1))
                if nextChar == " " || nextChar == "\t" { len += 1 }
            }
            return len
        }

        private func imageForCheck(isDone: Bool, font: UIFont) -> UIImage? {
            let size = font.pointSize * 0.9
            let cfg  = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
            return UIImage(systemName: isDone ? "checkmark.square.fill" : "square",
                           withConfiguration: cfg)
        }
    }
}
