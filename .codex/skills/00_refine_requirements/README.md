# refine_requirements (step 00)

## 용도

- 사용자 요구사항을 개발 및 테스트 가능한 명확한 명세로 정제한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `./docs/features/{feature_name}/requirements.md` 파일이 존재해야 한다.
- 요구사항은 한글/영문 혼용 가능하나 모호한 표현은 최소화한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$refine_requirements

feature_name: update-user-location-on-admin
output_filename: 01_refined_requirements.md

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/requirements.md`
- 출력: `./docs/features/{feature_name}/artifacts/{output_filename}`

## 단계 연결

- 이전 스텝: 없음
- 이후 스텝: 01_inspect_codebase