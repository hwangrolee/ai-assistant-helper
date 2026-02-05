# Ralph Implement Loop

work_plan.json 기반으로 Task를 자동 구현하는 루프입니다.

## 실행 명령어

```bash
/ralph-loop:ralph-loop "docs/specs/work_plan.json을 읽고 Task를 구현합니다.

## Step 1: 상태 확인

work_plan.json을 읽고 현재 상태 확인:
- 모든 Task가 completed → <promise>ALL_TASKS_COMPLETED</promise> 출력 후 종료
- sub_tasks가 있는 Task 있음 → Step 2로 (sub_tasks 처리)
- 실행 가능한 pending Task 있음 → Step 2로

## Step 2: Task 구현

Task(subagent_type=\"implement\", prompt=\"work_plan.json에서 실행 가능한 Task 구현 (sub_tasks 포함)\")

- IMPLEMENTED → Step 3로
- BUILD_FAILED → 종료

## Step 3: 코드 리뷰

Task(subagent_type=\"code-review\", prompt=\"변경된 코드 리뷰\")

- APPROVED → Step 4로
- BLOCKED → Step 3-1로

### Step 3-1: 코드 리뷰 이슈를 sub_tasks에 추가

BLOCKED 응답의 이슈들을 work_plan.json의 해당 Task의 sub_tasks에 추가:
```json
{
  \"id\": \"T001-1\",
  \"type\": \"CODE_REVIEW\",
  \"severity\": \"CRITICAL|HIGH\",
  \"file\": \"파일경로\",
  \"line\": 45,
  \"description\": \"이슈 설명\",
  \"suggested_fix\": \"수정 방법\"
}
```
저장 후 다음 iteration (implement가 sub_tasks 처리)

## Step 4: 보안 리뷰

Task(subagent_type=\"security-review\", prompt=\"변경된 코드 보안 리뷰\")

- SECURE → Step 5로
- VULNERABLE → Step 4-1로

### Step 4-1: 보안 이슈를 sub_tasks에 추가

VULNERABLE 응답의 이슈들을 work_plan.json의 해당 Task의 sub_tasks에 추가:
```json
{
  \"id\": \"T001-2\",
  \"type\": \"SECURITY\",
  \"severity\": \"CRITICAL|HIGH\",
  \"file\": \"파일경로\",
  \"line\": 45,
  \"description\": \"이슈 설명\",
  \"suggested_fix\": \"수정 방법\"
}
```
저장 후 다음 iteration (implement가 sub_tasks 처리)

## Step 5: 커밋

Task(subagent_type=\"git-commit\", prompt=\"변경사항 커밋\")

- COMMITTED → Step 6로
- COMMIT_BLOCKED → AskUserQuestion으로 JIRA ID 요청 후 다시 커밋

## Step 6: Task 완료 처리

work_plan.json에서 해당 Task의 status를 completed로 변경 후 다음 iteration

## 종료 조건

모든 Task가 completed 상태가 되면:
<promise>ALL_TASKS_COMPLETED</promise>" --completion-promise "ALL_TASKS_COMPLETED" --max-iterations 50
```

---

## 사전 조건

1. `docs/specs/work_plan.json` 파일 존재
2. pending 상태인 Task가 1개 이상 존재
3. JIRA ID가 브랜치명에 포함 (예: `feature/GOLD-386-description`)

---

## 에이전트 흐름

```
implement → code-review → security-review → git-commit → 완료
    ↓           ↓              ↓               ↓
BUILD_FAILED  BLOCKED      VULNERABLE    COMMIT_BLOCKED
    ↓           ↓              ↓               ↓
  종료     sub_tasks 추가  sub_tasks 추가  JIRA ID 요청
              ↓              ↓
         implement가     implement가
          처리 후 재리뷰   처리 후 재리뷰
```

---

## 관련 에이전트

| 에이전트 | 역할 | 결과 |
|----------|------|------|
| implement | Task 구현 + sub_tasks 처리 + 빌드 | IMPLEMENTED / BUILD_FAILED |
| code-review | 코드 리뷰 | APPROVED / BLOCKED |
| security-review | 보안 리뷰 | SECURE / VULNERABLE |
| git-commit | 커밋 | COMMITTED / COMMIT_BLOCKED |

---

## sub_tasks 스키마

```json
{
  "id": "T001-1",
  "type": "CODE_REVIEW | SECURITY",
  "severity": "CRITICAL | HIGH | MEDIUM",
  "file": "파일경로",
  "line": 45,
  "description": "이슈 설명",
  "suggested_fix": "수정 방법"
}
```

---

## 이슈 처리 흐름

| 상황 | 처리 |
|------|------|
| code-review BLOCKED | ralph-loop가 sub_tasks 추가 → implement가 수정 |
| security-review VULNERABLE | ralph-loop가 sub_tasks 추가 → implement가 수정 |
| git-commit COMMIT_BLOCKED | 사용자에게 JIRA ID 요청 |
