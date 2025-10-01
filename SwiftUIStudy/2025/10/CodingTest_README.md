# CodingTest

## 문자열 반복해서 출력하기

### 문제
문자열 str과 정수 n이 주어집니다.
str이 n번 반복된 문자열을 만들어 출력하는 코드를 작성해 보세요.

### 제한사항
1 ≤ str의 길이 ≤ 10
1 ≤ n ≤ 5

###입출력 예
입력 #1
```
string 5
```
출력 #1
```
stringstringstringstringstring
```

### 풀이
- (1...10).contains(s1.count)
    - 1 ≤ s1.count ≤ 10
- String(repeating: s1, count: a)
    - s1을 a만큼 반복하여 String으로 만들어줍니다.


---

## 대소문자 바꿔서 출력하기

###문제 설명
영어 알파벳으로 이루어진 문자열 str이 주어집니다. 각 알파벳을 대문자는 소문자로 소문자는 대문자로 변환해서 출력하는 코드를 작성해 보세요.

###제한사항
1 ≤ str의 길이 ≤ 20
str은 알파벳으로 이루어진 문자열입니다.

###입출력 예
입력 #1
```
aBcDeFg
```
출력 #1
```
AbCdEfG
```

### 풀이
- isLowercase / isUppercase
    - 소문자일때 true 반환 / 대문자일때 true 반환
    - a.isLowercase
- uppercased() / lowercased()
    - 소문자를 대문자로 변환 / 대문자를 소문자로 변환
    - a.uppercased() // A
    - A.lowercased() // a

### 다른 사람 풀이
```
var result = String()
for s in s1 {
    if s.isUppercase { result.append(s.lowercased()) }
    else { result.append(s.uppercased()) }
}
print(result)
```

----

## 특수문자 출력하기

###문제 설명
다음과 같이 출력하도록 코드를 작성해 주세요.

출력 예시
```
!@#$%^&*(\'"<>?:;
```

### 풀이

특수문자를 출력할때는 print(#""#) 이처럼 #을 넣어주면 됩니다.

### 다른 사람 풀이
```
print("!@#$%^&*(\\'\"<>?:;")
```

----
## 덧셈식 출력하기

###문제 설명
두 정수 a, b가 주어질 때 다음과 같은 형태의 계산식을 출력하는 코드를 작성해 보세요.

a + b = c

###제한사항
1 ≤ a, b ≤ 100

###입출력 예
입력 #1
```
4 5
```
출력 #1
```
4 + 5 = 9
```

### 다른 사람 풀이
```
print(a, "+", b, "=", a + b)
```

----

## 문자열 붙여서 출력하기
###문제 설명
두 개의 문자열 str1, str2가 공백으로 구분되어 입력으로 주어집니다.
입출력 예와 같이 str1과 str2을 이어서 출력하는 코드를 작성해 보세요.

###제한사항
1 ≤ str1, str2의 길이 ≤ 10

###입출력 예
입력 #1
```
apple pen
```
출력 #1
```
applepen
```
입력 #2
```
Hello World!
```
출력 #2
```
HelloWorld!
```

### 풀이
- replacingOccurrences(of:with:)
    - 문자열 전체 뛰어쓰기 제거 (of: " ", with: "")
    - 정확히는 of의 문자를 with로 변경 하는 것입니다. 
- trimmingCharacters(in:)
    - 문자열 앞 뒤 공백 제거
    
----

## 문자열 겹쳐쓰기

###문제 설명
문자열 my_string, overwrite_string과 정수 s가 주어집니다.\n
문자열 my_string의 인덱스 s부터 overwrite_string의 길이만큼을 문자열 overwrite_string으로\n
바꾼 문자열을 return 하는 solution 함수를 작성해 주세요.

###제한사항
my_string와 overwrite_string은 숫자와 알파벳으로 이루어져 있습니다.\n
1 ≤ overwrite_string의 길이 ≤ my_string의 길이 ≤ 1,000\n
0 ≤ s ≤ my_string의 길이 - overwrite_string의 길이\n

###입출력 예
- my_string : He11oWor1d
- overwrite_string : lloWorl
- s : 2
- result : HelloWorld

### 풀이
```
replaceSubrange(i..<j, with: overwrite_string)
```
i부터 j까지 overwrite_string으로 string 변환 함수.
i -> 2 / j -> i + overwrite_string.count

### 다른 사람 풀이

```
    let a = my_string.prefix(s)
    let b = overwrite_string
    let c = my_string.suffix(my_string.count - overwrite_string.count - s)
    return a + b + c
```

----
## 문자열 섞기
### 문제 설명
길이가 같은 두 문자열 str1과 str2가 주어집니다.

두 문자열의 각 문자가 앞에서부터 서로 번갈아가면서 한 번씩 등장하는 문자열을 만들어 return 하는 solution 함수를 완성해 주세요.

### 제한사항
1 ≤ str1의 길이 = str2의 길이 ≤ 10
str1과 str2는 알파벳 소문자로 이루어진 문자열입니다.

###입출력 예
- str1 : aaaa
- str2 : bbbb
- result : abababab

### 다른 사람 풀이

```
func solution(_ str1:String, _ str2:String) -> String {
    return zip(str1, str2).map { String($0) + String($1) }.joined()
}
```

zip 은 str1과 str2를 묶어주는 역할입니다.
```
let zipArray = zip(str1, str2)

for (s1, s2) in zipArray {
print("\(s1) - \(s2)")
}
// 결과 
// a - b 
// a - b 
// a - b 
// a - b
```

