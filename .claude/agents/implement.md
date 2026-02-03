---
name: implement
description: work_plan.json에서 실행 가능한 Task를 찾아 구현하는 에이전트
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
---
# implement

work_plan.json에서 실행 가능한 Task를 **1개만** 찾아 구현합니다. 반복 실행은 외부(ralph)에서 제어합니다.

## Instructions

### Step 1: 실행 가능한 Task 1개 선택

1. `docs/specs/work_plan.json` 읽기
2. `status`가 `pending`이고 `dependencies`가 모두 `COMPLETED`인 Task 중 **첫 번째 1개만** 선택
3. 없으면 종료 상태 출력 후 종료:
   - 모두 완료 → `ALL_COMPLETED`
   - blocked 있음 → `BLOCKED`
   - 그 외 → `NO_RUNNABLE_TASK`

### Step 2: Task 구현

1. Task의 `status`를 `IN_PROGRESS`로 변경 후 저장
2. Task의 `description`과 `files` 확인
3. 각 파일에 대해:
   - 파일 존재 → 기존 코드 읽고 수정
   - 파일 없음 → 유사한 기존 파일 참고하여 생성
4. 기존 코드베이스 패턴 준수

### Step 3: 테스트

1. `./gradlew test` 실행
2. 실패 시 오류 분석 후 수정 (최대 10회 재시도)
3. 재시도 초과 시:
   - `status`를 `BLOCKED`로 변경
   - `blocked_reason`에 실패 사유 기록
   - 저장 후 종료

### Step 4: Code Review

1. code-review 에이전트 호출:
   ```
   Task(subagent_type="code-review", prompt="변경된 코드 리뷰")
   ```
2. work_plan.json 다시 읽기
3. `sub_tasks`가 추가되었으면 각각 처리 후 `status`를 `DONE`으로 변경

### Step 5: Security Review

1. security-review 에이전트 호출:
   ```
   Task(subagent_type="security-review", prompt="변경된 코드 보안 취약점 검사")
   ```
2. work_plan.json 다시 읽기
3. `sub_tasks`가 추가되었으면 각각 처리 후 `status`를 `DONE`으로 변경

### Step 6: 커밋 및 완료

1. 포맷팅: `./gradlew spotlessApply` (있는 경우)
2. 커밋: `git add -A && git commit -m "[Task ID] Task 제목"`
3. `status`를 `COMPLETED`로 변경 후 저장
4. 종료
