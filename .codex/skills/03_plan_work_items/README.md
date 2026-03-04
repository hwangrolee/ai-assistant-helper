# plan_work_items (step 03)

## 용도

- 변경 지점 분석을 바탕으로 작업을 PR 단위로 분해하고 실행 계획(JSON)을 생성한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `02_locate_change_points` 실행 결과 파일이 존재해야 한다.
- `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}` 경로가 유효해야 한다.
- `./docs/features/{feature_name}/artifacts/{change_points_filename}` 경로가 유효해야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$plan_work_items

feature_name: update-user-location-on-admin
feature_key: FEAT
refined_requirements_filename: 01_refined_requirements.md
change_points_filename: 03_change_points.md
output_filename: 04_work_plan.json

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`
- 입력: `./docs/features/{feature_name}/artifacts/{change_points_filename}`
- 출력: `./docs/features/{feature_name}/artifacts/{output_filename}`

## 단계 연결

- 이전 스텝: 02_locate_change_points
- 이후 스텝: 04_design_test_plan