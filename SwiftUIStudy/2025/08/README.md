# 2025.08
## 08 2주차
### FullScreen Router

- FullScreenRouter

    - path: 경로 배열을 관리하는데 사용됩니다. 이 배열은 현재 네비게이션 스택의 상태를 나타냅니다.

    - push(_:): 경로를 스택에 추가하여 새로운 화면으로 이동합니다.

    - pop(): 스택에서 마지막 경로를 제거하여 이전 화면으로 돌아갑니다.

    - reset(): 경로를 초기화하여 네비게이션 스택을 비웁니다.

    - widgetPush(_:): 모든 경로를 제거하고 새로운 경로를 설정하여 특정 화면으로만 이동합니다.

- NavigationStack

    - NavigationStack(path:): router.path를 사용하여 경로를 바인딩하고, NavigationDestination을 통해 경로에 맞는 화면을 렌더링합니다.

    - navigationDestination(for:): 이 뷰에서는 AppRoute에 맞춰 경로가 이동할 때마다 적절한 뷰를 보여줍니다.

- 페이지 간 이동

    - ContentView: router.push(.textEditor)를 호출하여 TextEditorView로 이동합니다.

    - TextEditorView: 버튼을 클릭하면 router.push(.secondPage)를 통해 SecondPageView로 이동합니다.

    - SecondPageView: router.pop()을 호출하여 이전 화면(TextEditorView)으로 돌아갑니다.

- 결과

    - 첫 번째 페이지에서 버튼을 클릭하면 TextEditorView로 이동하고, 그 안의 버튼을 클릭하면 SecondPageView로 이동합니다.

    - **SecondPageView**에서는 router.pop()을 통해 첫 번째 페이지로 돌아갑니다.

결론:
이 방식은 **NavigationStack**과 라우터를 함께 사용하여 프로그래밍적으로 페이지를 이동시키는 방법입니다. router.push()를 호출하여 네비게이션 스택을 조작하고, 그에 맞는 페이지로 이동합니다.

---

### LogManager

**LogLevel 열거형**

> LogLevel은 로그의 우선 순위를 정의하는 열거형(enum)입니다.

 이 열거형은 각 로그 레벨에 대해 정수 값을 지정하고, 각 레벨에 대해 텍스트 설명을 제공합니다.

- debug: 로그 레벨 1로, 개발 및 디버깅 단계에서 주로 사용됩니다.

- info: 로그 레벨 2로, 일반적인 정보 로그를 나타냅니다.

- error: 로그 레벨 3으로, 오류나 예외 상황을 나타냅니다.

**description 속성**

> LogLevel은 CustomStringConvertible 프로토콜을 채택하고 있어, 각 열거형 값을 설명하는 텍스트를 반환합니다. 

예를 들어:

```
.debug: "- DEBUG"

.info: "- INFO"

.error: "- ERROR"
```

**logger 클래스**

> logger 클래스는 애플리케이션의 로깅을 담당하는 클래스입니다. 이 클래스는 로그 레벨을 기준으로 로깅을 하며, 각 로그 메시지는 파일명, 코드의 라인 번호, 함수 이름과 함께 출력됩니다.

**logLevel 변수**

logLevel은 현재 로깅할 최소 레벨을 정의하는 클래스 변수입니다. 기본값은 .debug로 설정되어 있으며, 로그 레벨이 이 값 이상일 경우에만 로그 메시지가 출력됩니다. 예를 들어, logLevel이 .info로 설정되면 debug 레벨의 로그는 출력되지 않습니다.

```
d(): debug 레벨 로그를 출력합니다.

i(): info 레벨 로그를 출력합니다.

e(): error 레벨 로그를 출력합니다.
```

각 메소드에서는 로그 메시지 외에도 파일 이름, 라인 번호, 함수 이름을 자동으로 캡처하여 로그에 포함시킵니다. 이 정보는 코드에서 어디서 호출되었는지 추적할 수 있게 도와줍니다.

**log() 메소드**

log() 메소드는 실제로 로그 메시지를 출력하는 역할을 합니다. message, level, file, line, function 정보를 받아서 로그를 출력합니다. 이 메소드는 logLevel 변수에 설정된 최소 로그 레벨 이상일 경우에만 로그를 출력합니다. 로그는 콘솔에 다음과 같은 형식으로 출력됩니다:

```
SwiftUIStudy: - DEBUG MyFile.swift:10 myFunction - This 
```
사용 예시
```swift
logger.d("This is a debug message")
logger.i("This is an info message")
logger.e("This is an error message")
```
위와 같은 코드로 로그를 출력할 수 있습니다. 각 로그 메시지는 로그 레벨에 따라 적절하게 출력됩니다. logLevel이 .info로 설정된 경우, debug 레벨의 로그는 출력되지 않으며, info와 error 레벨의 로그만 출력됩니다.

**로그 레벨 설정**

로그 레벨은 logger.logLevel을 통해 설정할 수 있습니다. 기본값은 .debug로 설정되어 있으며, 필요에 따라 .info 또는 .error로 변경하여 로그 출력의 수준을 조정할 수 있습니다.

예시:
```
logger.logLevel = .info
```
위와 같이 설정하면, debug 레벨의 로그는 출력되지 않고 info와 error 레벨의 로그만 출력됩니다.

장점
간단한 로깅: 개발자가 로그 레벨을 설정하고, 간편하게 로그 메시지를 출력할 수 있습니다.

디버깅 지원: 각 로그 메시지에 파일명, 라인 번호, 함수명이 포함되어 있어, 디버깅할 때 유용합니다.

로그 필터링: 로그 레벨을 통해 어떤 로그를 출력할지 쉽게 조정할 수 있습니다.

이 클래스를 사용하여 애플리케이션의 로깅을 효율적으로 관리하고, 필요에 따라 로그 출력을 제어할 수 있습니다.

---
### TextEditor

**코드 설명 (핵심 개념 먼저)**

- UITextView + NSAttributedString: SwiftUI의 TextEditor는 String만 다뤄서 이미지/아이콘 삽입이 불가합니다. 그래서 UITextView로 내려가 **NSTextAttachment**를 이용해 아이콘(불릿/체크)을 “문자처럼” 집어넣습니다.

- 단일 에디터: 한 개 UITextView 안에서 모든 줄을 처리하므로 “전체 선택(Select All)”이 문서 전체에 적용됩니다.

- 컨트롤러 분리: SwiftUI 버튼 → CustomTextEditorController의 공개 메서드 호출(예: insertBullet()). 여기서만 textStorage를 조작합니다. (코디네이터 직접 호출 X)

- 첨부 보존: updateUIView에서 uiView.text = text로 덮지 않습니다. 한 번이라도 text로 덮으면 첨부가 사라집니다. 대신 처음에 attributedText 세팅 후 **항상 textStorage**만 수정합니다.

- 들여쓰기 제거: 리스트 문단 스타일을 적용하지 않고, 마커 뒤에 한 칸 공백만 둡니다. 그래서 아이콘 바로 옆부터 텍스트가 시작돼요.

**라인별 포인트**

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

### CustomTextController

**흐름 요약 (한 문단에서 버튼을 누르면 무슨 일이?)**

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



