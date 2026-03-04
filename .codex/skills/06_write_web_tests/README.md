# write_web_tests (step 06)

## 용도

- Controller 계층에 대한 Web 테스트(MockMvc)를 작성한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `05_implement_slice` 실행 결과(변경 요약)가 준비되어야 한다.
- 테스트 대상 Controller의 엔드포인트/응답 계약이 확정되어야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$write_web_tests

refined_requirements: ./docs/features/update-user-location-on-admin/artifacts/01_refined_requirements.md
code_changes: ./docs/features/update-user-location-on-admin/artifacts/05_code_changes.md
test_plan: ./docs/features/update-user-location-on-admin/artifacts/05_test_plan.md

PROMPT
```

## 입력/출력

- 입력: refined_requirements
- 입력: code_changes
- 입력: test_plan
- 출력: web_test_code

## 단계 연결

- 이전 스텝: 05_implement_slice
- 이후 스텝: 07_run_static_checks 또는 05_implement_slice