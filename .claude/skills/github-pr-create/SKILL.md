---
name: github-pr-create
description: GitHub PR을 생성하는 스킬. 브랜치 간 변경사항을 분석하고, pr-description 에이전트로 설명을 생성한 후 MCP로 PR을 생성합니다.
tools: ["Read", "Grep", "Glob", "Bash", "Task", "mcp__github__create_pull_request", "mcp__github__get_pull_request", "mcp__github__list_pull_requests"]
context: fork
---
# create-pr

GitHub Pull Request 생성 스킬

## 고정 값

| 항목 | 값 | 비고 |
|------|-----|------|
| **jira domain** | `triplecomma` | JIRA 링크: `https://triplecomma.atlassian.net/browse/{JIRA_ID}` |
| **reviewers (기본값)** | `sanghoon-triplecomma`, `triplebobkim`, `KimDaeho1226` | 사용자가 `reviewer` 파라미터를 전달하면 그 값으로 대체. **확인 없이 기본값 자동 사용** |
| **assignees** | `hwangrolee-triplecomma` | 항상 이 사용자를 assignee로 지정 |

## 사용자 입력 파라미터

사용자는 아래 형식으로 PR 생성을 요청합니다. `to`와 `from`만 필수입니다:

```
/create-pr
  - to : {base_branch}
  - from : {head_branch}
  - pr title : {pr_title} (선택, 없으면 자동 생성)
  - reviewer : {reviewers} (선택, 없으면 기본값 3명 자동 사용)
```

## 실행 절차

### Step 1: 필수 입력값 확인

**입력:** 사용자 요청
**출력:** `base_branch`, `head_branch`, `pr_title`(nullable), `reviewers` 리스트

- **`to`와 `from`이 없으면** AskUserQuestion으로 사용자에게 요청한다. 둘 다 반드시 확보한 후 다음 단계로 진행한다.
- **reviewer**: 사용자가 `reviewer` 파라미터를 명시한 경우에만 그 값을 사용한다. 명시하지 않으면 **확인 없이** 기본값 3명을 자동 사용한다. (AskUserQuestion 호출하지 않음)
- **`head_branch`에서 JIRA ID 추출:** 예) `feature/TECH-56-xxx` → `TECH-56`
  - 변수명: `jira_id`

### Step 2: git fetch + 리포지토리 정보 확인

**입력:** 없음
**출력:** `owner`, `repo`

아래 명령을 **병렬로** 실행한다:

```bash
# 최신 원격 브랜치 동기화
git fetch origin
```

```bash
# 리포지토리 정보 추출
git remote -v | head -2
```

원격 저장소 URL에서 `owner`와 `repo`를 추출한다.

### Step 3: 브랜치 간 변경사항 분석

**입력:** `base_branch`, `head_branch`
**출력:** `commit_log`, `diff_stat`

아래 명령을 **병렬로** 실행한다:

```bash
# 커밋 목록 → commit_log
git log origin/{base_branch}..origin/{head_branch} --oneline
```

```bash
# 변경 파일 통계 → diff_stat
git diff origin/{base_branch}..origin/{head_branch} --stat
```

### Step 4: PR Description 생성

**입력:** `base_branch`, `head_branch`, `jira_id`, `owner`, `repo`, `commit_log`, `diff_stat`
**출력:** `pr_description` (마크다운 문자열)

`pr-description` 에이전트(Task tool, subagent_type=pr-description)를 호출한다.

호출 시 아래 prompt를 **그대로** 사용한다 (중괄호 변수만 실제 값으로 치환):

---

PR description을 생성하세요.

- base branch: {base_branch}
- head branch: {head_branch}
- JIRA ID: {jira_id}
- JIRA URL: https://triplecomma.atlassian.net/browse/{jira_id}
- repository: {owner}/{repo}

[커밋 목록]
{commit_log}

[변경 파일 통계]
{diff_stat}

---

에이전트가 반환한 결과에서 `PR_DESCRIPTION_START`와 `PR_DESCRIPTION_END` 마커 사이의 내용을 추출하여 `pr_description` 변수에 저장한다.

### Step 5: PR Title 결정

**입력:** `pr_title`(nullable), `jira_id`, `commit_log`, `pr_description`
**출력:** `pr_title` (확정)

- 사용자가 `pr title`을 지정한 경우: 그대로 사용
- 비어있거나 지정하지 않은 경우: 커밋 내용과 PR description을 기반으로 자동 생성
  - 형식: `{type}({jira_id}): 간결한 한국어 설명`
  - 70자 이내
  - type은 변경 성격에 따라 선택한다:
    - `feat`: 새로운 기능 추가
    - `fix`: 버그 수정
    - `chore`: 유지보수, 중단 처리, 설정 변경
    - `refactor`: 리팩토링
    - `docs`: 문서 변경
  - 예시: `feat(TECH-56): 슬랙 알림 스케줄러 추가`, `chore(TECH-56): 슬랙 알림 배치 스케줄러 중단 처리`
  - **반드시 이 형식을 준수한다. 대괄호(`[...]`) 등 다른 형식은 사용하지 않는다.**
  - 사용자에게 묻지 않고 자동으로 생성한다

### Step 6: PR 생성 + Body/Reviewer/Assignee 설정

**입력:** `owner`, `repo`, `pr_title`, `base_branch`, `head_branch`, `pr_description`, `reviewers`, `assignees`
**출력:** `pr_number`, `pr_url`

#### 6-1. PR 생성 (MCP 필수)

**반드시 `mcp__github__create_pull_request`를 사용한다.** `gh` CLI는 사용하지 않는다.

> **⚠️ MCP body 파라미터에 `\n` 이스케이프를 사용하면 리터럴 텍스트로 들어가 마크다운이 깨진다.**
> body는 placeholder 값을 넣고, 6-2에서 실제 body를 업데이트한다.

```
mcp__github__create_pull_request:
  owner: {owner}
  repo: {repo}
  title: {pr_title}
  head: {head_branch}
  base: {base_branch}
  body: "PR description is being generated..."
```

생성된 PR에서 `pr_number`를 추출한다.

#### 6-2. Body 업데이트 + Reviewer + Assignee (병렬 실행)

> **🚨 이 단계는 반드시 실행해야 한다. 절대 건너뛰지 않는다.**

아래 3개 요청을 **병렬로** 실행한다:

**1) PR Body 업데이트 (python3으로 JSON 안전 처리):**

```bash
python3 -c "
import json, sys, os, urllib.request
body = sys.stdin.read()
data = json.dumps({'body': body}).encode()
req = urllib.request.Request(
    'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}',
    data=data, method='PATCH',
    headers={
        'Authorization': 'token ' + os.environ['GITHUB_TOKEN'],
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
)
resp = urllib.request.urlopen(req)
print('Body updated:', resp.status)
" <<'BODY_EOF'
{pr_description}
BODY_EOF
```

> `{pr_description}` 자리에 Step 4에서 추출한 마크다운 내용을 그대로 넣는다. python3의 `json.dumps`가 특수문자를 자동 이스케이핑하므로 마크다운이 깨지지 않는다.

**2) Reviewer 추가:**

```bash
python3 -c "
import json, os, urllib.request
data = json.dumps({'reviewers': [{reviewers_json_array}]}).encode()
req = urllib.request.Request(
    'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers',
    data=data, method='POST',
    headers={
        'Authorization': 'token ' + os.environ['GITHUB_TOKEN'],
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
)
resp = urllib.request.urlopen(req)
print('Reviewers added:', resp.status)
"
```

> `{reviewers_json_array}`: 예) `'sanghoon-triplecomma', 'triplebobkim', 'KimDaeho1226'`

**3) Assignee 추가:**

```bash
python3 -c "
import json, os, urllib.request
data = json.dumps({'assignees': ['hwangrolee-triplecomma']}).encode()
req = urllib.request.Request(
    'https://api.github.com/repos/{owner}/{repo}/issues/{pr_number}/assignees',
    data=data, method='POST',
    headers={
        'Authorization': 'token ' + os.environ['GITHUB_TOKEN'],
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
)
resp = urllib.request.urlopen(req)
print('Assignees added:', resp.status)
"
```

3개 요청 모두 **응답 status를 검증**하여 성공 여부를 확인한다.

### Step 7: 결과 출력

PR 생성 완료 후 아래 형식으로 결과를 출력한다:

```
**PR #{number}**: {html_url}

| 항목 | 내용 |
|------|------|
| **Title** | {title} |
| **Base** | `{base_branch}` |
| **Head** | `{head_branch}` |
| **Commits** | {count}개 |
| **Changes** | {files} files, +{additions} / -{deletions} |
| **Reviewers** | {reviewer_names} |
| **Assignees** | {assignee_names} |
```

## 주의사항

- GitHub 제어는 **무조건 MCP**를 사용한다. `gh` CLI는 사용하지 않는다.
- PR description은 **반드시 pr-description 에이전트**를 통해 생성한다.
- reviewer, assignee의 `@` 접두사는 제거 후 사용한다.
- **Step 6-2(Body 업데이트 + Reviewer + Assignee)는 절대 건너뛰지 않는다.** PR 생성 직후 반드시 실행해야 한다.
- PR body 업데이트는 반드시 **python3**을 사용한다. curl + heredoc은 특수문자 이스케이핑 문제로 사용하지 않는다.
