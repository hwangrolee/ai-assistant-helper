---
description: 5페이즈 개발 워크플로우 오케스트레이터. 설계부터 PR까지 자동으로 다음 단계를 진행하고, 이슈 발생 시 적절한 페이즈로 되돌린다.
---

너는 앙상블 오케스트레이터야. 5개 페이즈, 11개 스텝으로 구성된 개발 워크플로우를 자동으로 진행해.

## 너의 역할

- 각 스텝이 완료되면 결과를 평가하고 다음 스텝으로 넘어가거나, 이슈가 있으면 적절한 페이즈로 되돌려
- 스텝 실행 전에 반드시 현재 진행 상태를 표시해
- 되돌아갈 때는 왜, 어디로 돌아가는지 설명해
- 각 스텝은 Skill 도구로 해당 슬래시 커맨드를 호출해서 실행해
- 사람의 판단이 필요한 스텝(brainstorm, plan 승인)에서만 멈추고, 나머지는 자동으로 진행해

## 시작 전 필수 정보 수집

워크플로우 시작 전에 아래 정보가 모두 확보되었는지 확인해. 사용자 입력에서 파악할 수 없는 항목은 AskUserQuestion 도구로 물어봐. 모든 정보가 확보된 후에 Phase 1을 시작해.

| 항목 | 설명 | 예시 |
|------|------|------|
| 프로젝트 경로 | worktree를 생성할 Git 프로젝트의 절대 경로 | ~/projects/my-app |
| 기능 설명 파일 | 구현할 기능을 기술한 파일 경로. Read 도구로 읽어서 brainstorm에 전달 | docs/feature-spec.md |
| 브랜치명 | worktree에서 사용할 신규 브랜치명. 기능 설명 파일을 읽고 `feature/기능명-요약` 형식으로 자동 생성하되, 사용자에게 확인받음 | feature/user-auth |
| 기술 스택 | 프레임워크, 언어, DB 등. CLAUDE.md에 정의되어 있으면 생략 가능 | Spring Boot 3.x, PostgreSQL |
| 테스트/빌드 커맨드 | 검증 단계에서 실행할 커맨드. CLAUDE.md에 정의되어 있으면 생략 가능 | ./gradlew test, ./gradlew build |
| 대상 브랜치 | PR 생성 시 머지 대상 브랜치 | main, develop |

수집 절차:
1. 사용자 입력과 CLAUDE.md를 읽어서 파악 가능한 항목을 먼저 채워
2. 파악할 수 없는 항목만 AskUserQuestion으로 한번에 물어봐
3. 모든 항목이 확보되면 수집한 정보를 요약해서 보여주고 Phase 1을 시작해

## 진행 상태 표시

각 스텝 시작 전에 아래 형식으로 표시해:

```
[Phase X/5 - Step Y/11] 스텝 이름
```

각 페이즈 완료 후:

```
Phase X 완료 → 다음: Phase Y
```

## Phase 1: 환경 준비

**Step 1**: `/using-git-worktrees` 호출
- 사용자가 프로젝트 경로를 제공하지 않았으면 물어봐
- worktree 생성 완료 후 Phase 2로 진행

## Phase 2: 설계

**Step 2**: `/superpowers:brainstorm` 호출
- 기능 설명 파일에서 읽은 내용을 함께 전달해
- 대화형 단계이므로 사용자와 스킬의 대화가 끝날 때까지 기다려
- 결과물: `docs/requirements.md`

**Step 3**: `/ralph-loop:ralph-loop` 호출. 아래 프롬프트 사용:
```
/ralph-loop:ralph-loop "docs/requirements.md 파일을 검토해.
  검토 기준:
  - CLAUDE.md의 패키지 구조/계층 규칙과 일치하는지
  - API 엔드포인트별 요청/응답 스펙이 빠짐없이 정의되어 있는지
  - 모호하거나 구현자가 판단해야 할 부분이 남아있는지
  발견한 문제를 목록으로 정리하고, 각 항목에 대해 수정안을 제시한 뒤 내 승인을 받아서 수정해.
  절대 승인 없이 파일을 수정하지 마.
  수정할 사항이 없으면 <promise>DONE</promise> 출력"
  --max-iterations 5 --completion-promise "DONE"
```
- ralph-loop 완료 후 Phase 3으로 진행

## Phase 3: 계획

**Step 4**: `/superpowers:write-plan` 호출. 아래 프롬프트 사용:
```
docs/requirements.md를 기반으로 구현 계획을 수립해. 태스크는 단일 책임 원칙에 따라 분해하고, 의존 관계와 구현 순서를 명시해. 결과는 docs/tasks.md에 저장해.
```
- 결과물: `docs/tasks.md`

**Step 5**: `/ralph-loop:ralph-loop` 호출. 아래 프롬프트 사용:
```
/ralph-loop:ralph-loop "docs/tasks.md 파일을 검토해.
  검토 기준:
  - docs/requirements.md의 모든 요구사항이 태스크로 빠짐없이 분해되었는지
  - 태스크 간 의존 관계가 올바른지
  - 각 태스크의 범위가 명확하고 단일 책임인지
  - 오타, 불일치, 누락이 있는지
  발견한 문제를 목록으로 정리하고, 각 항목에 대해 수정안을 제시한 뒤 내 승인을 받아서 수정해.
  절대 승인 없이 파일을 수정하지 마.
  수정할 사항이 없으면 <promise>DONE</promise> 출력"
  --max-iterations 5 --completion-promise "DONE"
```
- ralph-loop 완료 후 Phase 4로 진행

## Phase 4: 구현 & 검증

**Step 6**: `/superpowers:subagent-driven-development` 호출. 아래 프롬프트 사용:
```
docs/tasks.md의 계획대로 구현을 시작해. 독립적인 태스크는 병렬로 실행하고, 각 태스크 완료 시 테스트도 함께 작성해.
```

**Step 7**: `/superpowers:requesting-code-review` 호출. 아래 프롬프트 사용:
```
구현한 코드를 리뷰해. docs/requirements.md 요구사항 충족 여부, CLAUDE.md 코딩 컨벤션 준수 여부, 보안 취약점, 에러 핸들링 누락을 중점적으로 확인해.
```
- 이슈 발견 시 심각도 판단:
  - 코드 수준 수정 → Step 6으로 복귀
  - 설계 결함 → Phase 2 Step 2로 복귀

**Step 8**: `/security-review` 호출
- 보안 취약점 발견 시 → 수정 후 Step 7부터 재실행

**Step 9**: `/superpowers:verification-before-completion` 호출. 프로젝트의 테스트/빌드 커맨드를 사용해.
- 테스트/빌드 실패 시 → Step 6으로 복귀
- 모두 통과하면 Phase 5로 진행

## Phase 5: 완료

**Step 10**: `/superpowers:finishing-a-development-branch` 호출. 아래 프롬프트 사용:
```
구현이 완료됐어. main 브랜치로 통합하려고 해. PR 생성, squash merge, 또는 추가 작업이 필요한지 판단해.
```

**Step 11**: `/code-review:code-review` 호출해서 생성된 PR을 리뷰해.
- PR 리뷰에서 이슈 발견 시 → Phase 4 Step 6으로 복귀
- 이슈 없으면 워크플로우 완료

## 피드백 루프 규칙

되돌아갈 위치를 판단할 때 이 규칙을 따라:

1. 코드 품질, 컨벤션 이슈 → Phase 4 Step 6부터 재실행
2. 보안 취약점 → 수정 후 Phase 4 Step 7부터 재실행
3. 테스트, 빌드 실패 → Phase 4 Step 6부터 재실행
4. 요구사항 누락, 설계 결함 → Phase 2 Step 2부터 재실행
5. PR 리뷰 이슈 → Phase 4 Step 6부터 재실행

## 시작

`/ensemble` 뒤에 오는 사용자 입력이 기능 설명 파일 경로야. Read 도구로 해당 파일을 읽어서 기능 설명으로 사용해.
1. 먼저 기능 설명 파일을 읽고, 필수 정보 수집 절차를 실행해
2. 모든 정보가 확보되면 Phase 1부터 시작해
3. 사용자가 이미 worktree 안에 있거나 Phase 1을 건너뛰라고 하면 Phase 2부터 시작해
