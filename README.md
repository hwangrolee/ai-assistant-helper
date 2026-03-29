# AI Assistant Helper

이 저장소는 AI를 단순한 코드 생성기가 아닌 전략적 파트너로 활용하여, 기획부터 구현까지의 전 과정을 최적화하는 AI-Native 개발 방법론과 환경 설정을 관리합니다.

---

## 핵심 개발 철학 (Core Methodology)

**Planning First, Execution Fast**
코드를 작성하기 전에 AI와 함께 완벽한 지도를 그리는 것을 최우선으로 합니다. 설계가 견고할수록 구현 속도는 비약적으로 상승하며 오류는 최소화됩니다.

1. **전략적 기획 (/plan, /conductor)**
   - 모든 작업은 기본 대화 모드가 아닌 /plan 명령으로 시작합니다. 
   - Gemini CLI의 conductor 확장을 통해 요구사항을 정의하고 구현 트랙(Track)을 분리하여 전체적인 아키텍처를 먼저 확정합니다.

2. **고속 구현 (yolo 모드, ralph-loop)**
   - 기획이 확정된 후에는 yolo 모드를 적극적으로 활용하여 도구 승인 절차를 최소화하고 개발 속도를 극대화합니다.
   - ralph-loop을 통해 에이전트가 스스로 문제를 진단하고 자가 교정(Self-healing)하며 작업을 완수하는 자동화 루프에 익숙해지는 과정을 지향합니다.

3. **동시성 환경 숙달 (Git Worktree)**
   - 동시성 작업 환경에 익숙해지기 위해 git worktree를 상시 활용합니다. 혼자 작업하더라도 브랜치 간 빠른 전환과 병렬적 사고를 연습하며 환경 제어 능력을 키웁니다.

4. **실용적인 도구 활용 (Leveraging Existing Ecosystem)**
   - 스킬(Skill)을 직접 제작하기보다, 이미 잘 만들어진 생태계의 도구와 스킬을 적극적으로 활용하여 개발 속도를 높이는 것을 선호합니다.
   - 과거에 스스로 많은 스킬을 만들려는 노력을 기울였으나, 대부분 일회성에 그치는 경우가 많았습니다. 현재는 직접 도구를 만드는 데 드는 불필요한 노력을 줄이고, 검증된 도구를 숙달하여 실질적인 제품 구현에 집중합니다.

---

## 도구별 역할 분담 (Multi-Agent Strategy)

### Gemini CLI
프로젝트의 오케스트레이션과 기획 엔진 역할을 수행합니다.
- **전략 수립**: /plan, /conductor를 통한 마일스톤 관리.
- **문서 연동**: context7을 활용한 최신 기술 스캔 및 할루시네이션 방지.
- **인프라 제어**: Supabase, GitHub MCP를 통한 리소스 관리.
- **상세 가이드**: [.gemini/README.md](.gemini/README.md) 참조.

### Claude Code
세밀한 코드 구현과 품질 관리, 자동화 훅을 담당합니다.
- **정밀 구현**: 커스텀 에이전트를 통한 아키텍처 준수 및 리팩토링.
- **자동화**: 커밋 메시지 생성, PR 설명 작성 등 반복 작업 자동화.
- **검증**: 보안 및 성능 리뷰 에이전트를 통한 코드 품질 보증.
- **상세 가이드**: [.claude/README.md](.claude/README.md) 참조.

---

## 프로젝트 구조 (Project Structure)

```
.
├── .gemini/         # Gemini CLI 활용 가이드 및 환경 명세
├── .claude/         # Claude Code 에이전트, 훅 및 플러그인 설정
├── .codex/          # SDLC 단계별 전문화된 AI 스킬셋
├── .mcp.json        # MCP (Model Context Protocol) 통합 서버 설정
└── README.md        # AI-Native 개발 방법론 요약
```

---

## 사용 방법 (Usage)

이 저장소의 설정과 가이드를 자신의 프로젝트에 적용하여 일관된 AI 협업 환경을 구축합니다.

```bash
# Gemini CLI 가이드 및 설정 복사
cp -r .gemini/ /path/to/your/project/

# Claude Code 에이전트 설정 복사
cp -r .claude/ /path/to/your/project/

# MCP 통합 설정 복사
cp .mcp.json /path/to/your/project/
```

---

## 라이선스

Private Repository
