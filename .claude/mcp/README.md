# MCP (Model Context Protocol) 설정

MCP는 Claude Code가 외부 서비스와 통신할 수 있게 해주는 프로토콜입니다.

## 설정 파일

프로젝트 루트의 `.mcp.json` 파일에서 MCP 서버를 설정합니다.

## 현재 사용 중인 MCP 서버

### GitHub

GitHub API와 연동하여 이슈, PR, 저장소 관리 등을 수행합니다.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${PERSONAL_GITHUB_TOKEN}"
      }
    }
  }
}
```

**환경 변수:**
- `PERSONAL_GITHUB_TOKEN`: GitHub Personal Access Token

**주요 기능:**
- 이슈 생성/수정/조회
- PR 생성/수정/머지
- 저장소 검색
- 파일 내용 조회/수정
- 브랜치 생성

## 환경 변수 설정

`.mcp.json`에서 `${VAR_NAME}` 형식으로 환경 변수를 참조할 수 있습니다.

환경 변수는 다음 위치에서 설정:
- `~/.zshrc` 또는 `~/.bashrc`
- 프로젝트의 `.env` 파일 (gitignore에 추가 필요)

## 새 MCP 서버 추가

```json
{
  "mcpServers": {
    "server-name": {
      "command": "실행 명령어",
      "args": ["인자1", "인자2"],
      "env": {
        "ENV_VAR": "값"
      }
    }
  }
}
```

## 참고 자료

- [MCP 공식 문서](https://modelcontextprotocol.io/)
- [MCP GitHub 서버](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
