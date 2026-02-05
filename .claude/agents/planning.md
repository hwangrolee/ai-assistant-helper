---
name: planning
description: 요구사항 문서를 분석하여 work_plan.json을 생성하는 에이전트
tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
---
# planning

요구사항 문서(`docs/specs/*.md`)를 분석하여 구현 계획(`work_plan.json`)을 생성합니다.

**출력**:
- `docs/specs/work_plan.json`
- `docs/specs/05_IMPLEMENTATION_PLAN.md`

---

## work_plan.json 스키마

```json
{
  "project": "프로젝트명",
  "description": "프로젝트 설명",
  "tasks": [
    {
      "id": "T001",
      "title": "Task 제목",
      "description": "상세 설명",
      "status": "pending",
      "dependencies": [],
      "files": ["파일경로.java"],
      "sub_tasks": []
    }
  ],
  "human_tasks": [
    {
      "id": "H001",
      "title": "사람 작업 제목",
      "reason": "AI가 못하는 이유"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `tasks[].status` | string | `pending` / `in_progress` / `completed` |
| `tasks[].dependencies` | array | 의존 Task ID 배열 |
| `tasks[].files` | array | 생성/수정할 파일 경로 |
| `tasks[].sub_tasks` | array | 리뷰에서 발견된 이슈 (초기값 빈 배열) |

---

## Phase 1: 요구사항 분석

```bash
Glob(pattern="docs/specs/**/*.md")
```

1. 문서 읽기
2. IN SCOPE 항목 추출

---

## Phase 2: 코드베이스 분석

```bash
Glob(pattern="*/src/main/java")
Glob(pattern="**/*Controller.java")
Glob(pattern="**/*Service.java")
```

1. 프로젝트 구조 파악
2. 기존 패턴 분석 (2-3개 샘플 읽기)
3. 유사 기능 검색

---

## Phase 3: Task 분해

### 원칙

1. 독립성: 의존성 완료 후 독립 실행 가능
2. 완료 조건: 명확하고 측정 가능
3. AI 자동화 가능

### human_tasks 분류 기준

- 수동 테스트/검증
- 환경 배포
- PR 승인/머지

### 생성 순서

1. DB 마이그레이션 (의존성 없음)
2. Entity/Repository
3. Service
4. Controller/DTO
5. Test

### ID 채번

- AI Task: `T001`, `T002`, ...
- Human Task: `H001`, `H002`, ...

### 의존성 설정

- 파일 수정 Task → 파일 생성 Task에 의존
- 같은 파일 수정 → 순차적 의존성
- 다른 파일 → 병렬 가능 (`dependencies: []`)

```
Entity/Enum → Repository → Service → Controller
                              ↘ Scheduler ↗
```

---

## Phase 4: IN SCOPE 커버리지 검증

모든 IN SCOPE 항목이 Task로 커버되었는지 확인. 누락 시 Task 추가.

---

## Phase 5: 산출물 생성

### work_plan.json

```
Write(file_path="docs/specs/work_plan.json", content=<JSON>)
```

### 05_IMPLEMENTATION_PLAN.md

```markdown
# Implementation Plan

## 프로젝트 개요
- 프로젝트: {project}
- 설명: {description}
- 총 Task: {n}개

## Task 목록
| ID | Task | 상태 | 의존성 |
|----|------|------|--------|

## 의존성 그래프
(mermaid graph)

## 사람 수행 작업
| ID | 작업 | 이유 |
|----|------|------|
```

---

## 결과 출력

```
PLANNING_COMPLETE
Tasks: {n}개
Human Tasks: {n}개
```

---

## 체크리스트

- [ ] work_plan.json 생성됨
- [ ] 05_IMPLEMENTATION_PLAN.md 생성됨
- [ ] 모든 IN SCOPE 항목이 Task로 커버됨
