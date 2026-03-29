# AI Assistant Helper

이 저장소는 AI를 단순한 코드 생성기가 아닌 전략적 파트너로 활용하여, 기획부터 구현까지의 전 과정을 최적화하는 AI-Native 개발 방법론과 환경 설정을 관리합니다.

---

## 핵심 개발 철학 (Core Methodology)

### 1. Planning First, Execution Fast
모든 개발은 코드를 작성하기 전 AI와 함께 완벽한 지도를 그리는 것으로 시작합니다. 견고한 설계는 구현 속도를 비약적으로 높이고 시행착오를 최소화합니다.

### 2. 실용적인 도구 활용 (Leveraging Existing Ecosystem)
스킬(Skill)을 직접 제작하기보다 이미 잘 만들어진 생태계의 도구를 적극적으로 활용합니다. 과거의 경험을 통해 일회성 도구 제작에 에너지를 쏟기보다 검증된 도구를 숙달하고 조합하는 것이 실질적인 제품 구현에 훨씬 효율적임을 확인했습니다.

### 3. 동시성 환경 숙달 (Git Worktree)
동시성 작업 환경에 익숙해지기 위해 git worktree를 상시 활용합니다. 혼자 작업하더라도 브랜치 간 빠른 전환과 병렬적 사고를 유지하며 개발 환경 제어 능력을 키웁니다.

---

## 도구 선택 및 활용 전략 (Tool Selection & Strategy)

수많은 시행착오 끝에 정착한 도구별 역할 분담과 핵심 명령어 활용 방식입니다.

### Gemini CLI: 전략적 기획 및 오케스트레이션
프로젝트의 전체적인 마일스톤과 아키텍처를 정의하는 엔진입니다.
- **/plan**: 대규모 프로젝트의 기술 스택을 정의하고 전체적인 구현 전략을 수립합니다.
- **/conductor**: 복잡한 요구사항을 실행 가능한 개발 트랙(Track)으로 분리하여 프로젝트의 가시성을 확보합니다.
- **상세 가이드**: [.gemini/README.md](.gemini/README.md) 참조.

### Claude Code: 정밀 구현 및 효율화
세밀한 코드 구현과 자동화, 코드 품질 관리를 담당합니다.
- **/plan**: 구현 단계에서의 논리적 흐름을 미리 검증하여 코드의 정합성을 높입니다.
- **/batch**: 여러 파일에 걸친 반복적인 수정을 일괄 처리하여 개발 시간을 획기적으로 단축합니다.
- **/simplify**: 복잡해진 로직을 명확하고 간결하게 정돈하여 유지보수성을 확보합니다.
- **/superpowers**: 터미널 및 시스템 제어 권한을 통해 AI가 개발 환경을 직접 제어하게 함으로써 작업의 완결성을 높입니다.
- **yolo 모드 & ralph-loop**: 기획 확정 후 승인 절차를 최소화하고 자가 교정 루프를 통해 고속으로 기능을 구현합니다.
- **상세 가이드**: [.claude/README.md](.claude/README.md) 참조.

### 제외된 도구: /specify
- **/specify**: 기존 코드베이스(Brownfield) 분석과 깊이 있는 컨텍스트 유지에는 뛰어나지만, 실무 적용 시 과도한 토큰 소모로 인한 비용 및 성능 효율성 문제로 현재는 사용하지 않습니다.

---

## 프로젝트 구조 (Project Structure)

```
.
├── .gemini/         # Gemini CLI 활용 가이드 및 환경 명세
├── .claude/         # Claude Code 에이전트, 훅 및 플러그인 설정
├── .codex/          # SDLC 단계별 전문화된 AI 스킬셋
├── .mcp.json        # MCP 통합 서버 설정
└── README.md        # AI-Native 개발 방법론 요약
```

---

## 사용 방법 (Usage)

이 저장소의 설정과 가이드를 자신의 프로젝트에 적용하여 일관된 AI 협업 환경을 구축합니다.

```bash
# 설정 및 가이드 복사
cp -r .gemini/ /path/to/your/project/
cp -r .claude/ /path/to/your/project/
cp .mcp.json /path/to/your/project/
```

---

## 라이선스

Private Repository
