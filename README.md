# AI Assistant Helper

AI 기반 개발 도구들의 설정과 워크플로우를 관리하는 저장소입니다.

## 개요

다양한 AI 어시스턴트 도구들의 설정 파일, 커스텀 에이전트, 플러그인 등을 관리합니다. 프로젝트 간 일관된 AI 지원 환경을 구축하기 위한 템플릿과 가이드를 제공합니다.

## 구조

```
.
├── .claude/         # Claude Code 설정
├── .mcp.json        # MCP (Model Context Protocol) 설정
└── README.md
```

## 지원 도구

### Claude Code
Anthropic의 CLI 기반 AI 코딩 어시스턴트입니다.
- 커스텀 에이전트, 훅, 플러그인, 스킬 설정
- 자세한 내용: [.claude/README.md](.claude/README.md)

### MCP (Model Context Protocol)
AI 모델과 외부 서비스 간 연동을 위한 프로토콜입니다.
- 현재 설정: GitHub API 연동
- 설정 파일: `.mcp.json`

## 사용 방법

이 저장소의 설정 파일들을 자신의 프로젝트에 복사하여 사용합니다.

```bash
# Claude Code 설정 복사
cp -r .claude/ /path/to/your/project/

# MCP 설정 복사
cp .mcp.json /path/to/your/project/
```

## 라이선스

Private Repository
