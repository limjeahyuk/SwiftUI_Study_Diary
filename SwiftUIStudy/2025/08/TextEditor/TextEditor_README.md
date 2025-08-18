# TextEditor

## 코드 설명 (핵심 개념 먼저)

- UITextView + NSAttributedString: SwiftUI의 TextEditor는 String만 다뤄서 이미지/아이콘 삽입이 불가합니다. 그래서 UITextView로 내려가 **NSTextAttachment**를 이용해 아이콘(불릿/체크)을 “문자처럼” 집어넣습니다.

- 단일 에디터: 한 개 UITextView 안에서 모든 줄을 처리하므로 “전체 선택(Select All)”이 문서 전체에 적용됩니다.

- 컨트롤러 분리: SwiftUI 버튼 → CustomTextEditorController의 공개 메서드 호출(예: insertBullet()). 여기서만 textStorage를 조작합니다. (코디네이터 직접 호출 X)

- 첨부 보존: updateUIView에서 uiView.text = text로 덮지 않습니다. 한 번이라도 text로 덮으면 첨부가 사라집니다. 대신 처음에 attributedText 세팅 후 **항상 textStorage**만 수정합니다.

- 들여쓰기 제거: 리스트 문단 스타일을 적용하지 않고, 마커 뒤에 한 칸 공백만 둡니다. 그래서 아이콘 바로 옆부터 텍스트가 시작돼요.

## 라인별 포인트

- ListAttachment
    - 마커의 종류(bullet, check(isDone:))를 보관. 나중에 토글/스타일에 재사용 가능.

- insertListMarker(kind:)
    - 현재 커서 기준 문단 범위(paragraphRange)를 구하고, 문단 시작에 이미 첨부가 있으면 중복 삽입 방지 → 커서를 마커 뒤로 옮기고 종료. 
    - 없으면 [attachment + " "]를 문단 시작에 삽입. 문단 스타일은 전혀 적용하지 않음(= 들여쓰기 없음).

- markerAttachment(for:font:)
    - SF Symbol로 아이콘 렌더, 폰트 라인 높이와 맞춰 베이스라인 정렬(y: font.descender).
    - 체크의 완료/미완료 아이콘 차이는 여기서 처리.

- markerLength(...)
    - 문단의 “마커 길이”를 계산합니다. 첨부 1글자 + 공백(또는 탭) 1글자 = 보통 2. 
    - 커서를 “마커 뒤”로 옮길 때, 삭제/분리 로직을 짤 때 기준이 됩니다.

- CustomTextEditorView
    - allowsEditingTextAttributes = true 필수.
    - 초기만 attributedText로 세팅, 그 이후는 절대 uiView.text = ... 하지 않음.

textViewDidChange에서 평문만 바인딩에 반영(첨부는 별도 직렬화 대상).

---

## CustomTextController

### 흐름 요약 (한 문단에서 버튼을 누르면 무슨 일이?)

1. 버튼 → insertOrToggle(target) 호출

2. 커서 위치의 문단 범위를 구함

3. 문단 시작에 마커가 있으면

    - 같은 종류 버튼이면 → 마커 삭제(토글 OFF)

    - 다른 종류 버튼이면 → 마커의 이미지/종류만 교체

4. 문단 시작에 마커가 없으면

    - [첨부 + 공백] 세트를 문단 시작에 삽입

5. 매번 커서 위치/typingAttributes 보정(아이콘 주변에서 폰트가 바뀌는 것 방지)

---

### Enter Custom

```swift
func textView(_ tv: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool
{
    guard text == "\n" else { return true } // 엔터만 커스터마이즈
```

Coordinator 내부에 TextView delegate를 이용.

---

### Text Click

TextEditor에서 글자 클릭시 단어 전체가 선택되는 이슈.

**싱글탭 / 더블 탭 이슈.**

```swift
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
```

탭 이벤트를 두개로 나눠서 이미지를 탭했을 때 or 글자를 탭했을때

두가지로 나눠서 이벤트를 추가합니다.


### Q. iPhone 메모를 보면 체크버튼은 선택이 되지 않음. 하지만 지금 만든 메모를 보면 체크 버튼이나 불릿을 문자열로 변경을 했기에 선택이 되고 복사 붙혀넣기도 됨. 이 부분은??

### **혼자 생각한 방식**

Bullet과 check에 관련된 것을 토큰 텍스트로 넣습니다. 
```
예시)
ㄱㄱㄱ > 불릿클릭
[Bullet] ㄱㄱㄱ

ㄱㄱㄱ > 체크 클릭
[checked] ㄱㄱㄱ
``` 

이처럼 텍스트로 넣는걸 토큰 텍스트라고 칭하겠습니다.

토큰 텍스트로 넣고 View에서 확인을 해서 이미지로 뿌려주는 것.

View에서 텍스트 위에 image로 뿌려주는 방식으로 하면 선택 자체가 안될 것으로 보여졌습니다.

### A. chatGPT 에게 묻고 웹에서 확인 한 결과

- UIKit의 UITextView 안에서 보이는 것(글자/첨부)은 “문자”로 취급됩니다.
    - NSTextAttachment(이미지)도 내부적으로는 U+FFFC 문자 1글자로 들어가요. 그래서 원칙적으로 “선택 대상”이에요.

 - 아이폰 메모는 체크 마커를 문자로 넣지 않고, 레이아웃/렌더링 단계에서 ‘장식’처럼 그려서 선택 대상에서 빠지게 합니다. (일종의 커스텀 텍스트 레이아웃)
 ---

### 지금처럼 첨부(attachment)로 바꾸는 방식 (우리가 이미 구현 중)

**장점**: 구현이 단순, 성능/호환 안정, 엔터/백스페이스/토글 로직 붙이기 쉬움.

**단점**: 선택 범위에 ‘눈에 안 보이는 문자(첨부)’도 포함되는 개념.

→ 우리는 이를 커서 스냅, 제스처 필터, (원하면) copy/cut 오버라이드로 토큰 제거로 UX를 거의 동일하게 만들 수 있어요.

이 경로를 추천하는 이유: SwiftUI/UITextView와 가장 자연스럽게 맞물리고, 유지보수가 쉽습니다.

---
### “오버레이로 이미지만 얹는” 방식 (문자는 토큰으로 남기고, 뷰가 위에 그림)
> 말 그대로 토큰은 텍스트 안에 그대로 두고, 위에 투명한 레이어를 얹어 이미지들을 원하는 위치에 그립니다.

UITextView.layoutManager로 각 토큰이 놓인 글리프/라인 프래그먼트의 CGRect를 구함

그 좌표에 SwiftUI 뷰(또는 UIKit 서브뷰)로 체크/불릿 이미지를 오버레이

탭 제스처 대상은 오버레이 이미지(→ 체크 토글), 텍스트뷰 탭은 그대로 커서 이동

**장점**: 오버레이는 텍스트뷰의 선택 하이라이트에 포함되지 않음 → “이미지는 선택되지 않는” UX 달성.

**단점(중요)**:

- 동기화가 매우 빡셈: 스크롤/리사이즈/폰트 변경/입력 편집/키보드 표시/다크모드 전환 등 모든 순간마다
토큰 위치를 다시 계산해 오버레이 위치를 업데이트해야 해요.

- 성능 고려: 문서가 길고 마커가 많으면 리레이아웃 비용이 커짐.

- 복사/붙여넣기/접근성: 클립보드에는 토큰 문자열이 남습니다(원하면 copy/cut 오버라이드로 치환 필요).

- 엣지 처리: 줄 바꿈 직후, 비율/배율 변화, 스크롤 바운스 등에서 오버레이와 텍스트가 살짝 어긋나는 현상 케어 필요.

**시간/비용 많이 드는 고급 구현이고, 안정화까지 꽤 손이 갑니다.**

---
### “텍스트 레이아웃 커스터마이징” 방식 (진짜 메모 앱에 가까운 길)
> TextKit을 커스터마이즈해서 마커를 문자로 넣지 않고, 문단 속성/데코레이션으로 그림

**방법**: NSLayoutManager(TextKit 1)나 NSTextLayoutManager(TextKit 2)를 커스터마이즈해
drawGlyphs 단계에서 문단 시작 위치에 마커 이미지를 그려주고, 실제 문자열엔 마커 문자를 넣지 않음.

**장점**: 선택 불포함 + 복사/붙여넣기 깔끔 + 렌더링 일관성.

**단점**: 난이도 높음. UITextView와의 결합 지점이 복잡하고 iOS 버전에 따라 미묘함.
SwiftUI 래핑까지 포함하면 프로덕션 품질로 올리려면 시간이 꽤 듭니다.

---
### 정리

토큰 저장은 지금 구조와 완벽 호환.

“뷰에서 토큰만 보고 위에 이미지 얹기”는 가능하지만 복잡도↑.

현재 구현(첨부) + 선택/복사 보정으로도 충분히 “메모 같은” UX를 낼 수 있어요.

원하시면 copy/cut 오버라이드로 토큰만 복사되게 하는 스니펫이나,
오버레이 프로토타입을 어떻게 붙일지(업데이트 타이밍, 좌표 변환 포인트)도 정리해서 드릴게요.

---

### SwiftUI - TextField

SwiftUI에서 TextField만 추가 후 길게 눌러서 돋보기가 나타나는 순간 아래와 같은 에러문이 로그에 나타나게 됩니다.

해당 부분은 NaN 에러라고 하는데 현재로써 애플에서 고쳐줘야하는 문제로 보여집니다.

도움 받은 링크
- https://developer.apple.com/forums/thread/738726

- https://www.reddit.com/r/SwiftUI/comments/1ddcit9/help_needed_swiftui_app_passing_nan_to/


```
Error: this application, or a library it uses, has passed an invalid numeric value (NaN, or not-a-number) to CoreGraphics API and this value is being ignored. Please fix this problem.
Backtrace:
  <CGPathAddLineToPoint+92>
   <<redacted>+1336>
    <<redacted>+188>
     <<redacted>+344>
      <<redacted>+1256>
       <<redacted>+1528>
        <<redacted>+504>
         <<redacted>+148>
          <<redacted>+464>
           <<redacted>+648>
            <<redacted>+88>
             <<redacted>+52>
              <<redacted>+84>
               <<redacted>+172>
                <<redacted>+92>
                 <<redacted>+28>
                  <<redacted>+176>
                   <<redacted>+244>
                    <<redacted>+828>
                     <CFRunLoopRunSpecific+608>
                      <GSEventRunModal+164>
                       <<redacted>+888>
                        <UIApplicationMain+340>
                         <<redacted>+414604>
                          <<redacted>+72024>
                           <<redacted>+120596>
                            <$s6iosApp6iOSAppV5$mainyyFZ+40>
                             <__debug_main_executable_dylib_entry_point+12>                              <<redacted>+2240>
```