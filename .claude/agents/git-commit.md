---
name: git-commit
description: 변경사항을 검토하고 컨벤션에 맞게 커밋하는 에이전트
tools:
  - Read
  - Bash
  - Glob
  - AskUserQuestion
---
# git-commit

변경사항을 검토하고 커밋 룰에 맞게 커밋합니다.

---

## Step 1: JIRA ID 확인

**JIRA ID가 없으면 커밋 불가.**

JIRA ID 확인 순서:
1. 프롬프트에서 전달받음
2. 브랜치명에서 추출:
   ```bash
   git branch --show-current
   ```
   예: `feature/PROJ-123-description` → `PROJ-123`

3. 위 방법으로 찾을 수 없으면 사용자에게 질문:
   ```
   AskUserQuestion(questions=[{
     "question": "JIRA ID를 입력해주세요 (예: PROJ-123)",
     "header": "JIRA ID",
     "options": [
       {"label": "입력하기", "description": "JIRA ID 직접 입력"}
     ]
   }])
   ```

4. 사용자도 JIRA ID를 모르면:
   ```
   COMMIT_BLOCKED
   Reason: JIRA ID 없음
   ```

---

## Step 2: 변경사항 확인

```bash
git status
git diff --stat
```

---

## Step 3: 커밋 제외 파일 확인

**절대 커밋하면 안 되는 파일:**
- `.env`, `.env.*` (환경변수)
- `*credentials*`, `*secret*` (인증정보)
- `*.pem`, `*.key` (키 파일)

**커밋 제외 권장:**
- `build/`, `target/`, `out/` (빌드 산출물)
- `*.log` (로그 파일)
- `.idea/`, `*.iml` (IDE 설정)

위 파일이 staged 되어 있으면 unstage:
```bash
git reset HEAD <파일명>
```

---

## Step 4: 커밋 메시지 작성

### 형식

```
[JIRA-ID] type: 제목

본문 (선택)
```

### type 종류

| type | 설명 |
|------|------|
| feat | 새로운 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 |
| docs | 문서 수정 |
| test | 테스트 |
| chore | 빌드/설정 |

### 예시

```
[PROJ-123] feat: 슬랙 알림 스케줄러 추가

- SlackNotificationScheduler 클래스 생성
- ScheduledNotificationParams에 SLACK_NOTIFICATION 추가
```

---

## Step 5: 커밋 실행

```bash
git add <파일1> <파일2>
git commit -m "[PROJ-123] feat: 제목"
```

---

## Step 6: 결과 출력

```
COMMITTED
JIRA: {JIRA ID}
Hash: {커밋 해시}
Files: {파일 수}개
Message: {커밋 메시지}
```

---

## 체크리스트

- [ ] JIRA ID 확인됨
- [ ] 민감 파일 포함 안 됨
- [ ] 커밋 메시지 형식 준수
