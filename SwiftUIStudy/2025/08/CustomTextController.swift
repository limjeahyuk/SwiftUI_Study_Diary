//
//  CustomTextController.swift
//  SwiftUIStudy
//
//  Created by 임재혁 on 8/9/25.
//

import SwiftUI
import UIKit

// 불릿/체크박스 마커를 위한 Attachment
// NSTextAttachment를 상속 → "문자처럼" 들어가는 이미지 컨테이너
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
    
    // 원하는 고정 크기 (필요하면 런타임에 바꿔도 됨)
    @Published var bulletSize: CGSize = .init(width: 6, height: 6)
    @Published var checkSize:  CGSize = .init(width: 16, height: 16)

    // 불릿 or 체크박스 삽입 함수
    func insertBullet() { insertOrToggle(.bullet) }
    func insertCheck()  { insertOrToggle(.check(isDone: false)) }

    // MARK: - Core
    // 불릿 or 체크 공통 처리 함수
    private func insertOrToggle(_ target: ListAttachment.Kind) {
        guard let tv = textView else { return }
        // 포커스 보장(커서가 있어야 위치 계산/삽입이 안전)
        if !tv.isFirstResponder { tv.becomeFirstResponder() }

        let f = currentFont(tv)                         // 현재 사용할 폰트(아이콘 크기/정렬 기준)
        let caret = tv.selectedRange.location           // 현재 커서(캐럿) 위치
        let para  = paragraphRange(in: tv, at: caret)   // 커서가 속한 "문단"의 NSRange
        let ms    = tv.textStorage                      // 실제 문서 내용(속성문자열) 저장소

        // 이미 문단 시작에 마커가 있는지 확인
        // 문단 첫 글자가 attachment인지? / 직접 만든 ListAttachment인지?
        if let (att, attachRange) = hasAttachmentAtParagraphStart(tv, range: para),
           let listAtt = att as? ListAttachment {

            switch (listAtt.kind, target) {
            case (.bullet, .bullet), (.check, .check):
                // 같은 종류 버튼을 다시 누르면 => 마커 제거 (토글 OFF)
                // 마커 길이(보통 2글자: 첨부1 + 공백1)
                let mlen = markerLength(tv, paragraphRange: para)
                // 문단 맨 앞의 마커 영역
                let deleteRange = NSRange(location: para.location, length: mlen)

                let oldSel = tv.selectedRange // 기존 커서 위치 저장(보정용)
                ms.beginEditing()
                ms.deleteCharacters(in: deleteRange) // 마커 삭제
                ms.endEditing()

                // 커서 보정: 마커 앞/뒤 어디에 있었든 자연스러운 위치로
                var newLoc = oldSel.location
                if oldSel.location >= para.location + mlen { newLoc -= mlen } // 마커 뒤에 있던 커서는 mlen만큼 앞으로
                else { newLoc = para.location }  // 마커 앞/안쪽이면 문단 시작으로
                tv.selectedRange = NSRange(location: max(para.location, newLoc), length: 0)

                // 다음 입력 폰트 고정(첨부 주변에서 typingAttributes가 초기화되는 문제 예방)
                tv.typingAttributes = [.font: f]
                return

            default:
                // 다른 종류였다면 => 종류 변경 (불릿 ↔ 체크)
                let newKind: ListAttachment.Kind = {        // 타겟에 맞춰 새 타입 결정
                    switch target {
                    case .bullet: return .bullet
                    case .check:  return .check(isDone: false) // 토글로 만든 것이므로 기본 미완료
                    }
                }()

                listAtt.kind = newKind
                if let img = assetImage(for: newKind) {
                    listAtt.image  = img
                    listAtt.bounds = fixedBounds(for: newKind, font: f)
                } else {
                    listAtt.image  = imageForSFSymbol(kind: newKind, font: f)
                    listAtt.bounds = CGRect(x: 0, y: f.descender, width: f.lineHeight, height: f.lineHeight)
                }

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

                tv.typingAttributes = [.font: f] // 폰트 유지
                return
            }
        }

        // 마커가 없으면 => 새로 삽입
        let att   = markerAttachment(for: target, font: f)  // target에 맞는 첨부 생성
        let space = NSAttributedString(string: " ", attributes: [.font: f]) // 들여쓰기 대신 공백 1칸(폰트 고정)
        let marker = NSAttributedString(attachment: att) + space  // [첨부 + 공백] 한 세트

        ms.beginEditing()
        // 문단 시작에 삽입
        ms.replaceCharacters(in: NSRange(location: para.location, length: 0), with: marker)
        ms.endEditing()

        // 커서 보정: 기존 캐럿이 문단 안쪽이면 그대로 +marker 길이, 아니면 문단 시작 + marker 길이
        let delta = marker.length
        let newSelLoc = (caret >= para.location) ? caret + delta : para.location + delta
        tv.selectedRange = NSRange(location: newSelLoc, length: 0)

        tv.typingAttributes = [.font: f]  // 다음 타이핑 폰트 고정
    }

    // MARK: - Helpers
    func markerAttachment(for kind: ListAttachment.Kind, font: UIFont) -> ListAttachment {
        let at = ListAttachment()   // 첨부 인스턴스 생성
        at.kind = kind              // 타입 기록(토글/변경시 활용)
        
        if let img = assetImage(for: kind) {
            at.image  = img
            at.bounds = fixedBounds(for: kind, font: font)
        } else {
            // 에셋이 없을 때 안전하게 SF 심볼로 폴백
            at.image  = imageForSFSymbol(kind: kind, font: font)
            at.bounds = CGRect(x: 0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
        }
        
        return at
    }
    
    
    // 폴백용(SF 심볼) — 기존 imageFor(kind:font:)의 심볼 버전
    func imageForSFSymbol(kind: ListAttachment.Kind, font: UIFont) -> UIImage? {
        let size = font.pointSize * 0.9
        let cfg  = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
        switch kind {
        case .bullet:
            return UIImage(systemName: "circle.fill", withConfiguration: cfg)
        case .check(let isDone):
            return UIImage(systemName: isDone ? "checkmark.square.fill" : "square", withConfiguration: cfg)
        }
    }

    
    // 에셋에서 이미지 로드
    func assetImage(for kind: ListAttachment.Kind) -> UIImage? {
        switch kind {
        case .bullet:
            return UIImage(named: "bullet")
        case .check(let isDone):
            return UIImage(named: isDone ? "checked" : "uncheck")
        }
    }

    // 폰트 라인 높이에 ‘세로 가운데’ 오도록 y 오프셋 포함한 고정 크기
    func fixedBounds(for kind: ListAttachment.Kind, font: UIFont) -> CGRect {
        let size: CGSize = {
            switch kind {
            case .bullet: return bulletSize
            case .check:  return checkSize
            }
        }()

        // 베이스라인 기준 세로 가운데 정렬:
        // descender는 아래로 음수, lineHeight는 전체 라인 높이
        let y = font.descender + (font.lineHeight - size.height) / 2
        return CGRect(x: 0, y: y, width: size.width, height: size.height)
    }
    
    // 폰트 라인 높이에 맞춰 attachment 크기 계산 (가로세로 비율 유지)
    func attachmentBounds(for image: UIImage, font: UIFont) -> CGRect {
        let targetH = font.lineHeight * 0.9          // 글자보다 살짝 작게
        let aspect  = image.size.width / max(image.size.height, 1)
        let targetW = targetH * aspect
        return CGRect(x: 0, y: font.descender, width: targetW, height: targetH) // 베이스라인 정렬
    }

    func currentFont(_ tv: UITextView) -> UIFont { // 현재 사용할 폰트 결정(아이콘 크기/정렬 기준)
        if let f = tv.font { return f } // textView.font 우선
        if let f = tv.typingAttributes[.font] as? UIFont { return f }   // 타이핑 속성에 폰트가 있으면 사용
        return .systemFont(ofSize: 18)  // 둘 다 없으면 기본값
    }

    func paragraphRange(in tv: UITextView, at location: Int) -> NSRange {
        let ns = tv.attributedText.string as NSString   // 전체 문자열
        let loc = max(0, min(location, ns.length))      // 경계 클램프
        return ns.paragraphRange(for: NSRange(location: loc, length: 0)) // 해당 위치가 속한 문단 범위
    }

    func hasAttachmentAtParagraphStart(_ tv: UITextView, range: NSRange)
    -> (NSTextAttachment, NSRange)? {
        guard range.location < tv.attributedText.length else { return nil } // 빈 문서/끝 인덱스 방어
        var eff = NSRange()
        // 문단 시작 글자에 attachment가 있는지
        if let att = tv.attributedText.attribute(.attachment, at: range.location, effectiveRange: &eff) as? NSTextAttachment {
            return (att, eff)   // (첨부, 그 첨부 한 글자의 range)
        }
        return nil
    }

    func markerLength(_ tv: UITextView, paragraphRange: NSRange) -> Int {
        // attachment 1글자 + (공백/탭) 1글자
        var len = 0
        if tv.attributedText.attribute(.attachment, at: paragraphRange.location, effectiveRange: nil) != nil { len += 1 }   // 문단 시작이 첨부면 +1
        if paragraphRange.location + len < tv.attributedText.length {  // 다음 글자가 존재하면
            let s = tv.attributedText.string as NSString
            let next = s.substring(with: NSRange(location: paragraphRange.location + len, length: 1))
            if next == " " || next == "\t" { len += 1 }  // 공백/탭이면 +1 (우리는 공백 1칸 정책)
        }
        return len // 총 마커 길이(보통 2)
    }
}

// 편의: NSAttributedString 이어 붙이기
private func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let m = NSMutableAttributedString(attributedString: lhs) // 왼쪽을 가변화
    m.append(rhs)       // 오른쪽을 뒤에 붙임
    return m
}
