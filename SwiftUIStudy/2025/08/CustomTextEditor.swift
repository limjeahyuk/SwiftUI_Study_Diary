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
        

        // 체크 토글용 탭 제스처
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(context.coordinator.handleTap(_:)))
        tap.delegate = context.coordinator   // 델리게이트 설정
        tap.cancelsTouchesInView = false     // 기본 커서 이동/선택을 막지 않음
        tap.delaysTouchesBegan = false
        textView.addGestureRecognizer(tap)
        
        // 2) 싱글탭: 커서 강제 이동 (마커가 아닌 영역 전용)
        let textTap = UITapGestureRecognizer(target: context.coordinator,
                                             action: #selector(context.coordinator.forceCaretTap(_:)))
        textTap.delegate = context.coordinator
        textTap.cancelsTouchesInView = false
        textTap.delaysTouchesBegan = false
        textView.addGestureRecognizer(textTap)

        // 시스템 더블/트리플탭(단어/문단 선택)보다 '나중'에 인식되도록 실패를 요구
        for gr in textView.gestureRecognizers ?? [] {
            if let tgr = gr as? UITapGestureRecognizer,
               tgr !== textTap, tgr.numberOfTapsRequired > 1 {
                textTap.require(toFail: tgr)
            }
        }

        // 커서 우선: markerTap은 마커에서만, textTap은 나머지에서만
        context.coordinator.markerTap = tap
        context.coordinator.textTap = textTap

        // 링크 자동탐지로 단어 선택이 과해지는 걸 줄이고 싶다면
        textView.dataDetectorTypes = []
        
        // 컨트롤러에서 실제 UITextView 접근 가능하도록 연결
        controller.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // 여기서 uiView.text = text 를 하면 첨부가 날아감
        if isFocused, !uiView.isFirstResponder { uiView.becomeFirstResponder() }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        weak var markerTap: UITapGestureRecognizer?
        weak var textTap: UITapGestureRecognizer?
        var parent: CustomTextEditorView
        init(_ parent: CustomTextEditorView) { self.parent = parent }
        
        // 싱글탭 강제 커서 이동
        @objc func forceCaretTap(_ gr: UITapGestureRecognizer) {
            guard let tv = gr.view as? UITextView, gr.state == .ended else { return }
            let pt = gr.location(in: tv)

            // 마커가 맞으면 커서는 건드리지 않음 (마커 탭이 처리)
            if hitMarker(in: tv, at: pt) != nil { return }

            if let pos = tv.closestPosition(to: pt),
               let range = tv.textRange(from: pos, to: pos) {
                tv.selectedTextRange = range
                tv.scrollRangeToVisible(tv.selectedRange)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    tv.becomeFirstResponder()
                }
            }
        }
        
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
        
        // 제스처 분기: 마커면 markerTap만, 아니면 textTap만
        func gestureRecognizer(_ gr: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let tv = parent.controller.textView else { return false }
            let pt = touch.location(in: tv)
            let isMarker = (hitMarker(in: tv, at: pt) != nil)
            if gr === markerTap { return isMarker }
            if gr === textTap   { return !isMarker }
            return false
        }
        
        // 동시에 인식 금지(둘이 싸우지 않게)
        func gestureRecognizer(_ gr: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            return false
        }
        
        // 우리 싱글탭은 더블탭(단어 선택)보다 뒤로
        func gestureRecognizer(_ gr: UIGestureRecognizer,
                               shouldRequireFailureOf other: UIGestureRecognizer) -> Bool {
            if gr === textTap, let tap = other as? UITapGestureRecognizer, tap.numberOfTapsRequired > 1 {
                return true
            }
            return false
        }
        
        // ⬇️ 체크 아이콘 토글
        @objc func handleTap(_ gr: UITapGestureRecognizer) {
            guard let tv = gr.view as? UITextView, gr.state == .ended else { return }
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

            let f = currentFont(tv) // 아래 헬퍼 참고
            let ctrl = parent.controller

            // ✅ 아이콘 이미지 + bounds를 현재 폰트 기준으로 재설정
            let newKind: ListAttachment.Kind = .check(isDone: !done)
            listAtt.kind = newKind
            
            // ⬇️ 에셋 이미지 + 고정 크기 bounds를 '컨트롤러 헬퍼'로부터 사용
            if let img = ctrl.assetImage(for: newKind) {
                listAtt.image  = img
                listAtt.bounds = ctrl.fixedBounds(for: newKind, font: f)
            }

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
        
        func substring(in tv: UITextView, range: NSRange) -> String? {
            let len = tv.textStorage.length
            guard range.location >= 0,
                  range.length >= 0,
                  range.location + range.length <= len else { return nil }
            let s = tv.attributedText.string as NSString
            return s.substring(with: range)
        }
        
        
        // MARK: - keyBoard 동작 커마
        // 엔터 동작 커스터마이즈
        func textView(_ tv: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool
        {
            guard text == "\n" else { return true } // 엔터만 커스터마이즈

            let len = tv.textStorage.length
            // 입력 위치 클램프
            let safeLoc = min(max(0, range.location), len)
            let para = paragraphRange(in: tv, at: safeLoc)

            // 리스트 문단이 아니면 기본 동작
            let mlen = markerLength(tv, paragraphRange: para)
            guard mlen > 0 else { return true }

            let f = currentFont(tv)
            let ms = tv.textStorage
            let ctrl = parent.controller

            // 마커 뒤 내용 범위 (안전 클램프)
            let contentStart = para.location + mlen
            let contentLenRaw = para.length - mlen
            let contentLen = max(0, min(contentLenRaw, max(0, len - contentStart)))
            let contentEmpty: Bool = {
                // 문자열 끝이면 당연히 비어 있음
                if contentStart >= len || contentLen == 0 { return true }
                let s = tv.attributedText.string as NSString
                let r = NSRange(location: contentStart, length: contentLen)
                return s.substring(with: r).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }()

            if contentEmpty {
                // (A) 비어있는 리스트 줄: 리스트 해제 (= 마커 제거) + 일반 줄 개행
                ms.beginEditing()
                // 마커 삭제
                let delLen = min(mlen, max(0, len - para.location))
                ms.deleteCharacters(in: NSRange(location: para.location, length: delLen))

                // 개행을 "현재 입력 위치 - 삭제만큼"에 삽입
                let insertLoc = max(0, min(safeLoc - delLen, ms.length))
                ms.replaceCharacters(in: NSRange(location: insertLoc, length: 0),
                                     with: NSAttributedString(string: "\n", attributes: [.font: f]))
                ms.endEditing()

                tv.selectedRange = NSRange(location: insertLoc + 1, length: 0)
                tv.typingAttributes = [.font: f]
                return false
            } else {
                // (B) 내용 있는 리스트 줄: 다음 줄에 동일 마커 자동 생성
                // 현재 문단의 마커 종류
                var nextKind: ListAttachment.Kind = .bullet
                if let (att, _) = hasAttachmentAtParagraphStart(tv, range: para),
                   let listAtt = att as? ListAttachment {
                    switch listAtt.kind {
                    case .bullet: nextKind = .bullet
                    case .check:  nextKind = .check(isDone: false) // 새 줄은 미체크
                    }
                }

                // 삽입 덩어리를 "한 번에" 구성: \n + [attachment] + " "
                let insertion = NSMutableAttributedString()
                insertion.append(NSAttributedString(string: "\n", attributes: [.font: f]))
                let newAtt = ListAttachment()
                newAtt.kind = nextKind
                if let img = ctrl.assetImage(for: nextKind) {
                    newAtt.image  = img
                    newAtt.bounds = ctrl.fixedBounds(for: nextKind, font: f)
                }
                insertion.append(NSAttributedString(attachment: newAtt))
                insertion.append(NSAttributedString(string: " ", attributes: [.font: f]))

                ms.beginEditing()
                // 사용자 입력(엔터)을 우리가 만든 덩어리로 "교체" → 중복 삽입 방지
                ms.replaceCharacters(in: NSRange(location: safeLoc, length: range.length), with: insertion)
                ms.endEditing()

                tv.selectedRange = NSRange(location: safeLoc + insertion.length, length: 0)
                tv.typingAttributes = [.font: f]
                return false
            }
        }
    }
}
