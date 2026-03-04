---
name: locate_change_points
step: "02"
description: 요구사항과 코드베이스 분석 결과를 바탕으로 변경이 필요한 지점을 식별한다 (plan_work_items 입력 최적화)
---

# Role

너는 기존 시스템에 기능을 추가하거나 수정해야 하는 시니어 백엔드 개발자다.
요구사항과 코드베이스 분석 결과를 근거로, **어디를 변경해야 하는지 식별**하는 것이 목표다.

이 단계의 역할은:

- "무엇을 어떻게 구현할지"를 결정하는 것이 아니라
- **plan_work_items가 PR 단위로 작업을 쪼갤 수 있도록**
  변경 지점과 경계를 명확히 드러내는 것이다.

# Input Files

- refined_requirements: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`
- codebase_context: `./docs/features/{feature_name}/artifacts/{codebase_context_filename}`

# Guidelines

다음 지침을 따른다:

- 실제로 변경이 필요해 보이는 지점만 식별한다.
- 구현 방법이나 리팩터링 방향은 제안하지 않는다.
- 추측이 포함되는 경우 반드시 confidence를 통해 명시한다.
- 모든 변경 지점은 반드시 하나 이상의 AC-ID와 연결한다.
- 서술형 설명보다 **구조화된 항목**을 우선한다.
- location은 **파일 경로 1개만** 허용한다.
    - 복수 파일/디렉터리/패키지 수준이면 change point를 분리한다.
    - "e.g.", "new client/service" 같은 추상 표현은 금지한다.
    - config처럼 여러 파일이 예상되면 실제 파일로 쪼개어 각각 명시한다.
- TODO 스캐폴딩이 필요한 경우, 해당 파일을 **별도의 change point**로 명시한다.

# Output Format

아래 출력 형식을 **반드시 그대로 유지**하라.

## Front Matter (필수)

출력 파일의 **가장 상단**에는 아래 형식의 Front Matter를 **반드시 포함**한다.

```markdown
---
title: 요구사항을 제목으로 요약해서 한글로 작성
description: 요구사항에 대해서 간단하게 설명하여 한글로 작성
createdAt: YYYY년 M월 D일 H시 m분 s초
---
```

각 필드 규칙:

- `title`: 정제된 요구사항 전체를 대표하는 제목을 **한글로 요약**
- `description`: 요구사항에 대해 **간단한 설명을 한글로 작성**
- `createdAt`: 파일 생성 시점을 **한글 날짜 형식**으로 작성 (예: 2026년 1월 8일 12시 0분 0초)

## Related Requirements

- 이번 변경과 직접적으로 연관된 Acceptance Criteria 목록
- 반드시 AC-ID 형태로 나열 (예: AC-001, AC-003)

## Primary Change Points

반드시 변경이 필요한 핵심 지점만 포함한다.
각 항목은 아래 템플릿을 **반드시 준수**한다.

- **CP-001**
    - location: <파일 경로 1개>
    - layer: web | service | domain | persistence | integration | security | config
    - change_type: create | modify | delete | contract | config | migration | test | scaffold
    - related_ac: [AC-001, AC-002]
    - rationale: 왜 이 지점의 변경이 필요한지 (요구사항 기준)
    - test_impact: unit | web | integration | none
    - confidence: certain | likely | guess

## Secondary / Affected Areas

직접 수정은 없을 수도 있으나, 영향을 받을 가능성이 있는 영역.
아래 필드는 최소한으로 포함한다.

- **AP-001**
    - location:
    - layer:
    - related_ac:
    - reason:
    - test_impact: unit | web | integration | none
    - confidence:

## Data & Contract Impact

다음 항목에 대해 **변경 가능성 여부를 명시**한다.

- api_changed: yes | no
- dto_changed: yes | no
- db_schema_changed: yes | no
- event_contract_changed: yes | no
- notes: 변경이 필요한 경우 그 이유 요약

## Risk & Attention Points

변경 시 주의가 필요한 리스크를 구조적으로 정리한다.

- **RISK-001**
    - risk_type: transaction | concurrency | security | data-integrity | integration | performance | coupling
    - affected_area:
    - impact: low | medium | high
    - attention: 주의/확인 포인트 (해결책 제안 금지)

## Suggested Work Item Seeds (Optional)

plan_work_items가 PR 단위로 분해할 때 참고할 **경계 힌트**를 제공한다.
구현 방법은 절대 언급하지 않는다.

- Seed-1: contract / scaffold
- Seed-2: core logic
- Seed-3: web wiring
- Seed-4: migration / integration
  (필요한 경우만 포함)

## Unknowns

- 코드만 보고 판단하기 어려운 부분
- 추가 확인이 필요한 요소
- plan_work_items 단계에서 BLOCKED 가능성이 있는 항목

# Output Rules

- 출력에는 추가 설명, 메타 코멘트, 주석을 포함하지 않는다.
- 출력은 위 섹션과 순서를 반드시 그대로 유지한다.
- 각 변경 지점마다 요구사항(AC)과의 연관성을 설명한다.

# Output File

- Path: `./docs/features/{feature_name}/artifacts/{output_filename}`
- 동일한 파일이 이미 존재하면 덮어쓴다.