# LogManager

## LogLevel 열거형

> LogLevel은 로그의 우선 순위를 정의하는 열거형(enum)입니다.

 이 열거형은 각 로그 레벨에 대해 정수 값을 지정하고, 각 레벨에 대해 텍스트 설명을 제공합니다.

- debug: 로그 레벨 1로, 개발 및 디버깅 단계에서 주로 사용됩니다.

- info: 로그 레벨 2로, 일반적인 정보 로그를 나타냅니다.

- error: 로그 레벨 3으로, 오류나 예외 상황을 나타냅니다.

## description 속성

> LogLevel은 CustomStringConvertible 프로토콜을 채택하고 있어, 각 열거형 값을 설명하는 텍스트를 반환합니다. 

예를 들어:

```
.debug: "- DEBUG"

.info: "- INFO"

.error: "- ERROR"
```

## logger 클래스

> logger 클래스는 애플리케이션의 로깅을 담당하는 클래스입니다. 이 클래스는 로그 레벨을 기준으로 로깅을 하며, 각 로그 메시지는 파일명, 코드의 라인 번호, 함수 이름과 함께 출력됩니다.

### logLevel 변수

logLevel은 현재 로깅할 최소 레벨을 정의하는 클래스 변수입니다. 기본값은 .debug로 설정되어 있으며, 로그 레벨이 이 값 이상일 경우에만 로그 메시지가 출력됩니다. 예를 들어, logLevel이 .info로 설정되면 debug 레벨의 로그는 출력되지 않습니다.

```
d(): debug 레벨 로그를 출력합니다.

i(): info 레벨 로그를 출력합니다.

e(): error 레벨 로그를 출력합니다.
```

각 메소드에서는 로그 메시지 외에도 파일 이름, 라인 번호, 함수 이름을 자동으로 캡처하여 로그에 포함시킵니다. 이 정보는 코드에서 어디서 호출되었는지 추적할 수 있게 도와줍니다.

### log() 메소드

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

### 로그 레벨 설정

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
sss
ssss