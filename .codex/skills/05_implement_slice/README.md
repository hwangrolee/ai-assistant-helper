# implement_slice (step 05)

## 용도

- work_plan에서 다음 작업(PR)을 선택해 구현하고 STATUS를 DONE으로 갱신한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `03_plan_work_items` 실행 결과 파일이 존재해야 한다.
- `./docs/features/{feature_name}/artifacts/{work_plan_filename}` 경로가 유효해야 한다.
- 필요한 경우 `refined_requirements_filename`, `change_points_filename` 파일이 존재해야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$implement_slice

feature_name: update-user-location-on-admin
work_plan_filename: 04_work_plan.json
issue_id: FEAT-001
mode: full
refined_requirements_filename: 01_refined_requirements.md
change_points_filename: 03_change_points.md

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/artifacts/{work_plan_filename}`
- 입력: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`
- 입력: `./docs/features/{feature_name}/artifacts/{change_points_filename}`
- 출력: work_plan 동일 경로 업데이트
- 출력: 코드 변경 사항 반영

## 단계 연결

- 이전 스텝: 04_design_test_plan
- 이후 스텝: 06_write_web_tests 또는 07_run_static_checks