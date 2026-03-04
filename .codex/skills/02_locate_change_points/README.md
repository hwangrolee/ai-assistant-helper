# locate_change_points (step 02)

## 용도

- 요구사항과 코드베이스 분석 결과를 바탕으로 변경이 필요한 지점을 식별한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `01_inspect_codebase` 실행 결과 파일이 존재해야 한다.
- `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}` 경로가 유효해야 한다.
- `./docs/features/{feature_name}/artifacts/{codebase_context_filename}` 경로가 유효해야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$locate_change_points

feature_name: update-user-location-on-admin
refined_requirements_filename: 01_refined_requirements.md
codebase_context_filename: 02_codebase_context.md
output_filename: 03_change_points.md

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`
- 입력: `./docs/features/{feature_name}/artifacts/{codebase_context_filename}`
- 출력: `./docs/features/{feature_name}/artifacts/{output_filename}`

## 단계 연결

- 이전 스텝: 01_inspect_codebase
- 이후 스텝: 03_plan_work_items