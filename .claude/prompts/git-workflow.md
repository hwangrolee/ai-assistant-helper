# Git Workflow

변경사항을 분류하여 브랜치 생성부터 PR 머지까지 자동 처리합니다.

## 사용법

```
[설명] 커밋해줘

- 브랜치: [브랜치명]
- 이슈: [이슈 제목]
```

---

## 워크플로우

### Step 1: 변경사항 분류

`git status/diff`로 변경사항 확인 후 **기능 단위**로 그룹화:

- 같은 기능에 속하는 파일들을 하나의 그룹으로
- 서로 다른 기능은 별도 그룹으로 분리
- .DS_Store, .env 등은 제외

### Step 2: 그룹별 반복 (각 그룹마다 3~9 실행)

3. `git checkout -b [브랜치]` → 브랜치 생성
4. `git add [그룹 파일들]` → Staging
5. `gh issue create` → Issue 생성
6. `git commit` → 커밋 (conventional commits)
7. `git push -u origin [브랜치]` → 푸시
8. `gh pr create` → PR 생성 (Issue 연결)
9. `gh pr merge --squash` → 머지
10. `git checkout main && git pull` → main으로 복귀

---

## 기본값

| 항목 | 값 |
|------|-----|
| 분류 기준 | 기능 단위 |
| 머지 방식 | squash |
| 베이스 | main |
