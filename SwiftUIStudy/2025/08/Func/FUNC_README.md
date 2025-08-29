# Func

### @discardableResult

> discardable : 제외 가능 , 무시할

discardable 은 결과를 무시할 수 있습니다.

```
import Foundation

func sum() {
  add(a: 1, b: 2)
}

func add(a: Int, b: Int) -> Int {
  return a + b
}

```
discardable을 사용하지 않으면 sum함수에서 결과를 정해주지 않았기에 경고가 나타나게 됩니다.

에러가 아닌 이유는 굳이 안해주더라도 문제 될 것은 없기 때문이기에 그냥 알려주는 것입니다.

```
import Foundation

func sum() {
  add(a: 1, b: 2)
}

@discardableResult
func add(a: Int, b: Int) -> Int {
  return a + b
}
```

discardable을 사용해주면 경고가 나타나지 않습니다.

이처럼 결과값을 굳이 사용하지 않아도 되는 상황에서 경고를 안 띄우게 만들 수 있습니다.

ex) 어떤 행동의 업데이트 성공 여부? / 리턴 값을 이용해서 사용할 때도 있지만 안 쓸 때도 있을때


---

##FUNC Param

```
    private func isSameMonth(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        let ca = cal.dateComponents([.year, .month], from: a)
        let cb = cal.dateComponents([.year, .month], from: b)
        return ca.year == cb.year && ca.month == cb.month
    }
```

a 값을 Optional로 받되 안 받았을때는 그냥 함수 false로 되도록 할때,

이렇게 하지 않으면 함수를 사용하는 측에서 분기를 쳐줘야하는데 그때마다 하는게 여간 귀찮은 것이 아닙니다.
