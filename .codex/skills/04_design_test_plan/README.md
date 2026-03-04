# design_test_plan (step 04)

## 용도

- PR 단위 작업 계획을 바탕으로 테스트 전략과 PR별 테스트 게이트를 정의한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `03_plan_work_items` 실행 결과 파일이 존재해야 한다.
- `./docs/features/{feature_name}/artifacts/{work_plan_filename}` 경로가 유효해야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$design_test_plan

feature_name: update-user-location-on-admin
work_plan_filename: 04_work_plan.json
output_filename: 05_test_plan.md

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/artifacts/{work_plan_filename}`
- 출력: `./docs/features/{feature_name}/artifacts/{output_filename}`

## 단계 연결

- 이전 스텝: 03_plan_work_items
- 이후 스텝: 05_implement_slice