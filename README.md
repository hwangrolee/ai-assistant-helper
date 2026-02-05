# AI Assistant Helper

Claude Code를 활용한 AI 기반 개발 워크플로우 설정 및 템플릿 저장소입니다.

## 개요

이 저장소는 Claude Code의 agents, hooks, plugins, skills 등 AI 어시스턴트 관련 설정을 관리합니다. 개발 프로젝트에서 일관된 AI 지원 워크플로우를 구축하기 위한 템플릿과 가이드를 제공합니다.

## 구조

```
.claude/
├── agents/          # 독립 실행 에이전트 정의
├── hooks/           # 코드 포매팅, 린트, 테스트 훅
├── plugins/         # 사용 중인 플러그인 목록
├── prompts/         # 재사용 가능한 프롬프트 템플릿
└── skills/          # 직접 실행 가능한 커맨드
```

## 주요 기능

### Agents
- `planning` - 요구사항 분석 및 work_plan.json 생성
- `implement` - 태스크 구현 (코드 리뷰, 보안 리뷰 포함)
- `code-review` - 코드 리뷰 수행
- `security-review` - 보안 취약점 검토
- `git-commit` - 커밋 메시지 생성
- `pr-description` - PR 설명 생성

### Skills
- `/define-requirements` - 기획 초안을 상세 요구사항 문서로 확장
- `/create-spec` - 구현 명세 생성

### Plugins
- `ralph-loop` - 반복 실행 및 자동 종료 조건 관리

## 개발 워크플로우

1. **기획서 초안 작성** - PLAN.md 파일로 저장
2. **상세 기획서 작성** - `/define-requirements` 스킬 사용
3. **플랜 정의** - planning 에이전트로 work_plan.json 생성
4. **구현** - implement 에이전트로 순차적 태스크 구현

자세한 사용법은 [.claude/README.md](.claude/README.md)를 참조하세요.

## 라이선스

Private Repository
