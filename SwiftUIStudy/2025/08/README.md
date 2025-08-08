# 2025.08
## 08.08
FullScreen Router

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
