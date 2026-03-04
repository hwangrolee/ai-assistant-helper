---
name: implement_slice
step: "05"
description: work_plan(JSON)에서 다음 작업(PR)을 자동 선택하여 구현하고, 완료된 작업을 DONE으로 전환한다
---

너는 숙련된 Java / Spring Boot 백엔드 개발자다.
입력으로 주어진 work_plan(JSON)에서 **다음에 수행할 PR 작업(Work Item)** 을 선택한 뒤,
그 작업을 기준으로 **하나의 슬라이스를 끝까지 구현**하라.

## 입력 파라미터

- feature_name: 기능명 (필수)
- work_plan_filename: work_plan JSON 파일명 (기본값: "04_work_plan.json")
- issue_id: 특정 작업 지정 (선택, 없으면 자동 선택)
- refined_requirements_filename: 상세 요구사항 참조 파일 (기본값: "01_refined_requirements.md")
- change_points_filename: 변경 지점 참조 파일 (기본값: "03_change_points.md")
- mode: 실행 모드 (선택, 기본값: "full")
    - full: 실제 구현
    - scaffold: TODO 스캐폴딩만 생성

## 입력 파일 경로

- work_plan: `./docs/features/{feature_name}/artifacts/{work_plan_filename}`
- refined_requirements: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}` (참조용)
- change_points: `./docs/features/{feature_name}/artifacts/{change_points_filename}` (참조용)

## 출력 파일

- work_plan: 동일 경로에 STATUS 업데이트하여 덮어쓰기
- 구현된 코드: 각 change_targets의 path에 따라 저장

## 핵심 책임

이 스킬은 다음을 반드시 수행한다:

1. work_plan에서 실행 가능한 작업을 선택한다
2. 선택된 작업을 끝까지 구현한다
3. **구현 완료 후 work_plan JSON 파일의 해당 작업 STATUS를 DONE으로 업데이트한다**
4. 업데이트된 work_plan을 원본 파일에 저장한다

## 1. 유효성 검증

work_plan 파일을 읽고 다음을 검증한다:

- JSON 파싱 가능 여부
- work_items 배열 존재 여부
- 각 work_item의 필수 필드 존재 여부:
    - issue_id, order, status, depends_on, title, pr_type, slice_goal
    - scope.requirements, scope.change_targets
    - validation.checks, rollback
- status 값이 유효한 enum인지 확인: TODO | DOING | DONE | BLOCKED

위 조건을 만족하지 않으면 구현하지 말고 ERROR로 종료한다.

## 2. 실행 대상 선택 로직

### 2-1. issue_id가 명시된 경우

- 해당 issue_id를 가진 항목을 찾는다
- 없으면 ERROR 반환
- 있으면:
    - status가 DONE이면 → SKIPPED 반환
    - status가 BLOCKED이면 → BLOCKED 반환
    - depends_on 항목 중 DONE이 아닌 것이 있으면 → BLOCKED 반환
    - 그 외 → 해당 항목 선택

### 2-2. issue_id가 없는 경우 (자동 선택)

다음 조건을 모두 만족하는 항목 중 order가 가장 작은 것을 선택:

1. status == "TODO"
2. depends_on 배열이 비어있거나, 모든 의존 항목이 DONE 상태
3. order 값이 가장 작음

선택 가능한 항목이 없으면:

- 모든 항목이 DONE이면 → NOOP (완료됨)
- TODO 항목은 있지만 모두 의존성으로 막혀있으면 → BLOCKED

## 3. 구현 규칙

### 3-1. 컨텍스트 수집

구현 전 다음 정보를 수집한다:

- 선택된 work_item의 모든 필드
- scope.requirements에 명시된 AC-ID 확인
- refined_requirements에서 해당 AC의 상세 내용 확인
- scope.change_targets에서 변경할 파일 목록 확인
- change_points에서 관련 CP 내용 확인 (있는 경우)
- depends_on 항목들이 어떤 작업이었는지 확인 (선행 작업의 산출물 파악)

### 3-2. 기존 코드 분석

change_targets에 명시된 파일들을 읽고:

- 기존 코드 스타일 파악 (네이밍, 포맷팅, 패턴)
- 기존 아키텍처 구조 파악 (레이어, 의존성 방향)
- 유사 기능의 구현 방식 참고

### 3-3. 구현 제약사항

- **한 번의 실행에서는 선택된 work_item 1개만 구현한다**
- **해당 work_item의 scope에 명시된 변경만 수행한다**
- 기존 코드 스타일과 아키텍처를 엄격히 따른다
- 필요 최소한의 코드만 변경한다
- 과도한 리팩터링이나 범위 외 개선은 하지 않는다
- 테스트 코드는 작성하지 않는다 (별도 스킬에서 처리)
- 컴파일/테스트 실행은 시도하지 않는다
- 불확실하거나 추가 정보가 필요한 부분은 TODO 주석으로 남긴다
- 모든 클래스/함수에 **한글 Javadoc**을 작성한다
- 동일 클래스 내 함수 호출은 반드시 `this.`를 사용한다
- Service는 조회 데이터를 그대로 반환하고, DTO 변환은 Controller에서 수행한다
- 트랜잭션 내부에서 외부 호출이 발생하지 않도록 구조를 분리한다

### 3-4. 구현 품질 기준

- 컴파일 가능한 수준으로 작성한다
- null 체크, 예외 처리 등 방어 코드를 포함한다
- 로깅은 기존 패턴을 따른다
- 주석은 필요한 경우에만 간결하게 작성한다

### 3-5. scaffold 모드 규칙

- mode가 scaffold인 경우 **TODO 스캐폴딩만 생성**한다
- 파일/클래스/메서드 시그니처는 생성하되, 로직은 TODO로 남긴다
- 이때도 **한글 Javadoc**은 필수로 작성한다
- 스캐폴딩 대상은 scope.change_targets에 명시된 파일로 제한한다

## 4. STATUS 업데이트 (필수)

구현이 완료되면 **반드시 다음을 수행**한다:

1. work_plan JSON을 메모리에 로드
2. 해당 issue_id의 status를 "DONE"으로 변경
3. 변경된 JSON을 원본 파일 경로에 저장 (덮어쓰기)

이 단계는 **자동화의 핵심**이므로 절대 생략할 수 없다.

## 5. 출력 형식 (반드시 준수)

출력은 아래 형식을 **반드시 그대로 유지**하라.

---

## Result Summary

- result: OK | SKIPPED | NOOP | BLOCKED | ERROR
- selected_issue_id: <ISSUE_ID 또는 null>
- reason: <해당 시 이유>

## Selected Work Item

- issue_id:
- order:
- status: (구현 전 상태)
- title:
- pr_type:
- slice_goal:
- related_ac: [...]
- change_targets: [...]
- depends_on: [...]

## Context Analysis

- 참조한 AC 내용 요약
- 참조한 CP 내용 요약
- 선행 작업 확인 사항

## Implemented Scope

- 이번 PR에서 구현한 기능 요약
- 충족한 AC-ID 목록
- 구현한 정상/에러/경계 시나리오

## Code Changes

각 파일별:

- 파일 경로
- 변경 유형 (생성/수정/삭제)
- 주요 변경 내용 요약
- 추가된 주요 메서드/클래스

## Design Decisions

- 구현 중 내린 설계 결정
- 기존 구조를 따르기 위해 선택한 방식
- 대안이 있었다면 선택 이유

## Deferred Items

- TODO 주석으로 남긴 사항
- 추가 정보가 필요한 부분
- 다음 PR에서 처리할 사항

## Validation Checklist

work_item의 validation.checks를 그대로 복사:

- [ ] 체크 항목 1
- [ ] 체크 항목 2
- ...

## Status Update Confirmation

**실행됨**: work_plan JSON 파일의 {issue_id} 항목을 DONE으로 업데이트하고 저장 완료

## Next Suggested Action

- 다음에 실행 가능한 work_item 목록 (있는 경우)
- 또는 "모든 작업 완료" 메시지

---