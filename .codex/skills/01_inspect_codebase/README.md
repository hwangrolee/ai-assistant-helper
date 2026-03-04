# inspect_codebase (step 01)

## 용도

- 정제된 요구사항을 참고하여 코드베이스 구조/진입점/설정/테스트 구성을 사실 기반으로 요약한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `00_refine_requirements` 실행 결과 파일이 존재해야 한다.
- `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}` 경로가 유효해야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$inspect_codebase

feature_name: update-user-location-on-admin
refined_requirements_filename: 01_refined_requirements.md
output_filename: 02_codebase_context.md

PROMPT
```

## 입력/출력

- 입력: `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`
- 출력: `./docs/features/{feature_name}/artifacts/{output_filename}`

## 단계 연결

- 이전 스텝: 00_refine_requirements
- 이후 스텝: 02_locate_change_points