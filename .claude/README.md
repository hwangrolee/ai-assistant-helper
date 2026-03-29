# Claude Code 설정 가이드

이 디렉토리는 Claude Code의 커스텀 설정을 관리합니다.

## 디렉토리 구조

```
.claude/
├── agents/          # 독립 실행 에이전트 정의
│   ├── planning.md       # 요구사항 → work_plan.json 생성
│   ├── implement.md      # 태스크 구현
│   ├── code-review.md    # 코드 리뷰
│   ├── security-review.md # 보안 리뷰
│   ├── git-commit.md     # 커밋 메시지 생성
│   ├── pr-description.md # PR 설명 생성
│   └── refactoring-review.md # 리팩토링 검토
├── hooks/           # 자동 실행 훅
│   └── hooks.json        # 훅 설정
├── mcp/             # MCP 서버 설정 가이드
│   └── README.md
├── plugins/         # 플러그인 목록
│   └── README.md
├── prompts/         # 재사용 프롬프트
│   └── ralph-implement-loop.md
└── skills/          # 직접 실행 커맨드
    └── define-requirements/
```

## Agents

현재 세션과 독립적으로 실행되는 에이전트입니다. Task tool을 통해 자동으로 호출됩니다.

| 에이전트 | 설명 |
|---------|------|
| `planning` | 요구사항 문서를 분석하여 work_plan.json 생성 |
| `implement` | work_plan.json의 태스크를 순차적으로 구현 |
| `code-review` | 코드 리뷰 수행 (수정하지 않음) |
| `security-review` | 보안 취약점 탐지 (수정하지 않음) |
| `git-commit` | 변경사항 검토 및 커밋 |
| `pr-description` | PR 설명 생성 |
| `refactoring-review` | 리팩토링 필요성 검토 |

## Hooks

코드 수정 후 자동으로 실행되는 작업들입니다.
- 코드 포매팅
- 린트 검사
- 테스트 실행

## Plugins

### ralph-loop
반복 실행을 관리하며 종료 조건을 자동으로 판단합니다.
- 최대 반복 횟수 설정
- 완료 조건 감지 시 자동 종료

## MCP (Model Context Protocol)

외부 서비스와 연동하기 위한 프로토콜입니다. 프로젝트 루트의 `.mcp.json`에서 설정합니다.

### 현재 사용 중인 서버
- `github` - GitHub API 연동 (이슈, PR, 저장소 관리)

자세한 내용은 [mcp/README.md](mcp/README.md)를 참조하세요.

## Skills

슬래시 커맨드로 직접 실행 가능한 기능들입니다.

- `/define-requirements` - 기획 초안을 상세 요구사항 문서로 확장

### 핵심 스킬 활용 전략 (Core Command Usage)

현재 작업 성격에 따라 Claude Code의 기본 스킬들을 선택적으로 활용하며, 주로 **/plan**, **/batch**, **/superpowers**를 핵심적으로 사용합니다.

- **/plan**: 대규모 작업을 시작하기 전, AI와 함께 단계별 실행 계획을 수립하고 논리적 오류를 사전에 검토합니다.
- **/batch**: 여러 파일에 걸친 공통 수정 사항이나 반복적인 리팩토링 작업을 일괄 처리하여 효율을 높입니다.
- **/superpowers**: 터미널 접근, 시스템 제어, 파일 수정 등 AI의 권한을 최대로 활성화하여 복잡한 환경에서의 제어력을 확보합니다.
- **/specify**: Brownfield 프로젝트에서 깊이 있는 문서를 생성하여 컨텍스트를 확실히 유지하는 데에는 매우 효율적입니다. 다만, 토큰을 과도하게 소모하는 문제로 인해 현재 실무 환경에서는 활용하지 않고 있습니다.

이러한 기본 스킬들을 조합하여 AI가 작업의 전체 맥락을 완벽히 이해하도록 유도한 뒤 실제 구현에 착수합니다.

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

## Claude MCP 로 GITHUB 관리하기

```sh
Git Commit 을 위해 변경사항을 분류해서 해당 파일만 Staging -> 브랜치 생성 -> Github Issue 생성 -> 커밋 추가 -> 푸시 -> Githu PR 생성 -> 머지해줘
```
