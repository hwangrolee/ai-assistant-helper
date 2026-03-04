---
name: refine_requirements
step: "00"
description: 사용자 요구사항을 개발 및 테스트 가능한 명확한 명세로 정제한다
metadata:
    short-description: 요구사항을 AC 중심의 실행 가능한 명세로 변환
---

너는 숙련된 백엔드 개발자이자 테크 리드다.
사용자가 입력한 요구사항을 개발과 테스트가 가능한 **명확한 명세**로 정제하라.

이 스킬의 출력은 이후 모든 스킬(plan_work_items, design_test_plan, implement_slice 등)의 **단일 기준 소스(Single Source of Truth)** 가 된다.

## 실행 방법

**입력:**

- 파일 경로: `./docs/features/{feature_name}/requirements.md`
- 스킬 호출 시 `feature_name`과 `output_filename` 파라미터를 받는다

**출력:**

- 파일 경로: `./docs/features/{feature_name}/artifacts/{output_filename}`
- 동일한 파일이 이미 존재하면 삭제 후 다시 생성한다
- 출력 파일에는 추가 설명, 메타 코멘트, 주석을 포함하지 않는다

## 작성 원칙

다음 지침을 따른다:

- 요구사항은 **행동(Behavior) 중심**으로 정리한다
- 구현 방법, 클래스 구조, 프레임워크, 패턴은 **절대 언급하지 않는다**
- 테스트 가능한 Acceptance Criteria를 **반드시 포함**한다
- Acceptance Criteria에는 **고유한 ID(AC-001, AC-002, …)** 를 부여한다
- 모든 Acceptance Criteria는 **Given / When / Then 형식**을 따른다
- AC에는 가능한 경우 **입력/출력/상태값/에러코드**를 명시한다
- 불명확한 내용은 추측하지 말고 **Assumptions 또는 Open Questions**로 분리한다
- 테스트 관점의 힌트는 **Test Notes 섹션**에만 작성한다
- 출력 파일은 무조건 한글로 작성한다.

## 출력 형식

### Front Matter (필수)

출력 파일의 **가장 상단**에 다음 형식을 **반드시 포함**한다:

```yaml
---
title: 요구사항을 제목으로 요약해서 한글로 작성
description: 요구사항에 대해서 간단하게 설명하여 한글로 작성
createdAt: YYYY년 M월 D일 H시 m분 s초
---
```

**필드 규칙:**

- `title`: 정제된 요구사항 전체를 대표하는 제목을 **한글로 요약**
- `description`: 요구사항에 대해 **간단한 설명을 한글로 작성**한다
- `createdAt`: 파일 생성 시점을 기준으로 **한글 날짜 형식**으로 작성
    - 형식 예시: `2026년 1월 8일 12시 0분 0초`

### 본문 구조

아래 섹션과 순서를 **반드시 그대로 유지**하라.

---

## Requirement Summary

- 핵심 기능 요약
- 주요 사용자 행동 흐름
- 전반적인 비즈니스 목적

---

## Assumptions

- 요구사항 해석을 위해 합리적으로 가정한 사항
- 외부 정책/도메인 지식에 대한 전제

---

## Acceptance Criteria

각 항목은 반드시 **AC-ID** 를 포함하고, Given / When / Then 형식으로 작성한다.

- AC-001: Given … When … Then …
- AC-002: Given … When … Then …
- AC-003: (에러/예외/경계 조건 포함)

---

## Non-functional Requirements

기능 외에 반드시 고려해야 할 제약 및 품질 요구사항.

- 성능 (예: 응답 시간, 처리량)
- 보안 (예: 인증/인가, 민감 정보 처리)
- 안정성 (예: 실패 시 동작)
- 관측성 (로그/메트릭/트레이싱 필요 여부)
- 호환성 / 제약 사항
- 트랜잭션 경계 및 외부 호출 분리 규칙
- 마이그레이션/스키마 변경 필요 여부

---

## In Scope

- 이번 작업에 **포함되는 범위**
- 반드시 구현되어야 하는 항목

---

## Out of Scope

- 명시적으로 **이번 작업에서 제외되는 범위**
- 후속 작업으로 미뤄진 항목

---

## Test Notes

이 요구사항을 검증하기 위한 **테스트 관점 힌트**를 정리한다.
(구현 방법이 아니라, "무엇을 어디서 검증할지"만 작성)

- Unit:
    - 도메인/비즈니스 규칙 검증이 필요한 부분
- Web:
    - API 요청/응답, Validation, 에러 응답 검증
- Integration:
    - DB, 외부 연동, 여러 컴포넌트가 함께 동작하는 시나리오

---

## Suggested Slices (Optional)

PR 단위 분해를 돕기 위한 **행동 기준의 힌트**.
구현 순서가 아니라, "쪼갤 수 있는 기준"만 제시한다.

- 핵심 정상 흐름 (MVP)
- 에러/예외 처리
- 경계 조건
- 운영/관측/보완 작업

---

## Open Questions

- 요구사항을 확정하기 위해 반드시 확인이 필요한 질문
- 가능한 경우 **선택지(2~3개)** 를 함께 명시한다
- 정책/도메인/외부 의존성 관련 미지점

---

## Notes for Development

- 테스트 작성 시 주의할 포인트
- 리스크가 될 수 있는 부분 (높은 수준에서만)

------