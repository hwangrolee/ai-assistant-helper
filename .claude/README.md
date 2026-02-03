# 클로드 코드 양식

## agents

클로드 코드에서 작업 중인 세션에 엮이지 않고 독립적으로 실행시키기 위해 사용. 현 세션에서 대화한 내용이 agents 에서 실행되는 프롬프트에는 영향이 가지 않고 다른 콘텍스트에서 동작하기 때문에 사용.

agents 는 별도의 task tool 이기 때문에 세션에서 내가 작성한 프롬프트에 따라 알아서 실행될 수 있다.

## hooks

코드 수정 후 코드 포메팅, 린트, 테스트 등 훅 기능을 담당.

## plugins

내가 사용 중인 플러그인 목록

## skills

직접 실행시키는 명령어로 사용 가능. 나는 개발 기획 문서를 만들기 위해 사용한다.


## 현재 구조에서 1개의 피처를 개발하기 위해 사용하는 루틴

### 1. 기획서 초안 작성

직접 작성해야한다. 기획자, 디자이너, 개발자 등이 작성한 기획문서를 바탕으로 개발 기획서 초안을 작성한다. 그리고 해당 파일은 코딩할 프로젝트의 루트 경로(클로드 코드를 실행하는 경로)에 PLAN.md 이름으로 저장한다.

## 2. 상세 기획서 작성

```
/define-requirements @PLAN.md 파일을 바탕으로 기획문서 작성해. 답변은 한글로 출력해. PLAN.md 못찾으면 중단해.
```

## 3. 플랜 정의

work_plan.json 파일에 해야할 업무를 태스크 단위로 정리한다. 아무리 프롬프트를 잘 작성해도 간혹 빼먹는 경우가 있기 때문에 ralph 플러그인을 사용해서 최대 10번까지 반복을 하되 최근 3개에서 수정사항이 없다면 종료하는 식으로 ralph 를 사용한다.

```
/ralph-loop:ralph-loop "docs/specs/ 디렉토리의 요구사항 문서를 분석하여 docs/specs/work_plan.json을 생성하세요.

## 실행 방법
  Task tool로 planning 에이전트 호출:
  - subagent_type: planning
  - prompt: docs/specs/ 디렉토리의 요구사항 문서를 분석하여 work_plan.json 생성

  ## 매 실행 후 확인
  1. docs/planning_validation_log.json 파일 읽기
  2. logs 배열의 마지막 2개 항목 확인

  ## 종료 조건
  logs 배열에서 마지막 2개 로그의 changedTask가 모두 빈 배열이면:
  <promise>PLANNING COMPLETE</promise> 출력

  ## 종료 시 출력 형식
  ════════════════════════════════════════════════════════════
  ✅ Planning 검증 완료: 2회 연속 변경 없음
  ════════════════════════════════════════════════════════════
  - 총 실행 횟수: {logs 개수}회
  - 총 Task 수: {tasks 개수}개
  <promise>PLANNING COMPLETE</promise>
  ════════════════════════════════════════════════════════════" --completion-promise "PLANNING COMPLETE" --max-iterations 10
```

## 4. 구현 프롬프트

구현은 work_plan.json 에서 순차적으로 가저와서 구현한다.

```
/ralph-loop:ralph-loop "docs/specs/work_plan.json을 읽고 Task를 구현합니다.

## Step 1: 상태 확인

work_plan.json을 읽고 현재 상태 확인:
- 모든 Task가 COMPLETED → <promise>ALL_TASKS_COMPLETED</promise> 출력 후 종료
- BLOCKED Task 있음 → BLOCKED 상태와 사유 출력 후 종료
- 실행 가능한 pending Task 있음 → Step 2로

## Step 2: implement 에이전트 호출

Task(subagent_type=\"implement\", prompt=\"work_plan.json에서 실행 가능한 Task 구현\")

(implement 내부에서 code-review, security-review까지 처리됨)

## Step 3: 결과 확인

work_plan.json을 다시 읽고 상태 확인 후 다음 iteration

## 종료 조건

모든 Task가 COMPLETED 상태가 되면:
<promise>ALL_TASKS_COMPLETED</promise>" --completion-promise "ALL_TASKS_COMPLETED" --max-iterations 50
```