# Gemini CLI 활용 가이드 (User Usage Pattern)

이 문서는 제가 이 프로젝트를 진행하며 **Gemini CLI를 효과적으로 활용하는 방식**을 정리한 가이드입니다. 상세 설정 데이터는 [.gemini/config.json](./config.json) 파일에 정의되어 있습니다.

---

## 나의 Gemini CLI 활용 패턴 (My Workflow)

저는 단순히 코드를 바로 생성하기보다, 체계적인 기획과 설계를 거쳐 구현하는 방식을 선호합니다.

1. **선 기획, 후 개발 (/plan, /conductor 중심)**
   - 기본 대화 모드로 바로 구현을 지시하기보다, 먼저 /plan 명령을 통해 전체적인 구조와 구현 전략을 잡는 것으로 시작합니다.
   - 규모가 있는 작업은 /conductor 확장을 사용하여 단계별 트랙(Track)을 생성하고, 기획이 충분히 확정된 상태에서 개발에 들어갑니다.

2. **효율 중심의 실행 (yolo 모드 및 ralph-loop 활용)**
   - 기획이 확정된 후의 반복적인 수정이나 단순 구현 단계에서는 yolo 모드를 적극적으로 활용하여 승인 절차를 최소화합니다.
   - 특히, 최근에는 **ralph-loop**을 효과적으로 활용하기 위해 노력하고 있습니다. 에이전트가 스스로 문제를 진단하고 해결하는 자동화 루프를 통해 복잡한 반복 작업을 효율적으로 처리하는 방식에 익숙해지는 과정에 있습니다.

3. **Git Worktree 활용 및 환경 익숙해지기**
   - 동시성 작업 환경에 익숙해지기 위해 git worktree 기능을 적극적으로 활용합니다.
   - 단, 혼자 작업하는 경우 여러 워크트리에서의 병렬 작업은 머지 단계에서 코드 충돌을 야기할 수 있습니다. 따라서 실제 병렬 구현보다는 브랜치 간 빠른 전환과 worktree 기능 자체에 능숙해지는 것에 초점을 맞추어 사용합니다.

---

## 확장 프로그램 (Extensions)

현재 프로젝트에서 활성화된 주요 확장 프로그램 목록입니다.

| 이름 | 버전 | 설명 | 비고 |
| :--- | :--- | :--- | :--- |
| **conductor** | 0.4.1 | 기획 -> 플랜 -> 개발 절차를 지원하는 엔진 | **주로 활용** |
| **context7** | 1.0.0 | 실시간 기술 문서 스캔 및 검색 | |
| **github** | 1.0.0 | GitHub API 연동 및 이슈/PR 관리 | |
| **supabase** | 0.1.1 | 데이터베이스 및 서버리스 함수 관리 | |
| **monday** | 0.0.41 | monday.com 보드 및 아이템 연동 | |
| **Stitch** | 0.1.4 | UI 디자인 및 프론트엔드 코드 생성 보조 | |
| **ralph** | 1.0.1 | 에이전트 루프 및 실행 보조 | **활용 및 숙달 노력 중** |

---

## 전문 스킬 (Skills)

특정 작업에 특화된 에이전트 스킬들입니다.

### 문서 및 검색 (context7)
- find-docs: 최신 라이브러리/프레임워크 문서 검색 및 코드 예제 제공
- context7-mcp, context7-cli: 기술 문서 동기화 및 관리

### 데이터베이스 (supabase)
- supabase-postgres-best-practices: Postgres 성능 및 보안 베스트 프랙티스

---

## MCP 서버 (Model Context Protocol)

현재 구성된 MCP 서버 정보입니다. 상세 설정은 프로젝트 루트의 .mcp.json 등을 참조하세요.

- **github**: 이슈 및 PR 관리용 stdio 서버
- **supabase**: 프로젝트 원격 데이터베이스 연동용 http 서버
- **monday**: 프로젝트 관리 보드 연동용 http 서버
- **context7**: 외부 기술 문서 검색용 stdio 서버

---

## 관리 명령어

```bash
# 확장 프로그램 및 MCP 상태 확인
gemini extensions list
gemini mcp list

# 기획 모드 진입 예시
/plan "새로운 기능에 대한 설계를 시작해줘"

# 기획 확정 후 YOLO 모드로 실행 예시
gemini -y "기획된 내용을 바탕으로 코드를 작성해줘"

# Git Worktree 관련 예시
git worktree add ../feature-branch feature-branch
git worktree list
```
