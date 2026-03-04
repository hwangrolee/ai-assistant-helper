---
name: write_web_tests
step: "06"
description: Controller 계층에 대한 Web 테스트(MockMvc)를 작성한다
inputs:
    -   name: refined_requirements
        description: 정제된 요구사항 명세 (Acceptance Criteria 포함)
    -   name: code_changes
        description: implement_slice 스킬의 출력 결과 (변경된 코드 요약)
    -   name: test_plan
        description: design_test_plan 스킬의 출력 결과
outputs:
    -   name: web_test_code
        description: Controller / Validation / Error Handling에 대한 테스트 코드
---

너는 Spring Boot 기반 백엔드 서비스의 테스트를 작성하는 숙련된 개발자다.
구현된 코드 변경과 테스트 전략을 바탕으로,
**Controller 계층의 동작을 검증하는 Web 테스트를 작성**하라.

다음 지침을 따른다:

- 테스트 대상은 Controller 계층으로 한정한다.
- WebMvcTest + MockMvc 사용을 기본으로 한다.
- Service 계층은 Mock 처리한다.
- HTTP 요청/응답의 행동을 검증하는 데 집중한다.
- 구현되지 않은 요구사항이 있으면 테스트로 추측하지 않는다.
- Controller가 DTO 변환을 수행하는 경우, 변환 결과를 응답 계약 기준으로 검증한다.

아래 출력 형식을 **반드시 그대로 유지**하라.

## Test Scope

- 테스트 대상 Controller
- 검증하려는 주요 API 엔드포인트

## Test Configuration

- 사용 애노테이션
    - @WebMvcTest
    - @MockBean
- 필요한 설정 또는 커스텀 설정

## Test Cases

각 테스트 케이스마다 아래 정보를 포함한다.

### Test Case <번호>

- 목적
- 관련 요구사항 / AC
- 요청 정보
    - HTTP Method
    - URL
    - Request Body / Params
- 기대 결과
    - HTTP Status
    - Response Body
    - Validation / Error 응답

## Test Code

- 테스트 클래스 구조
- 주요 테스트 메서드 예시
- MockMvc 사용 코드

## Edge & Error Cases

- Validation 실패 케이스
- 잘못된 요청
- 예외 처리 검증

## Notes

- 테스트 작성 시 주의할 점
- 이후 통합 테스트로 넘겨야 할 영역