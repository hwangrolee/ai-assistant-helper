# run_static_checks (step 07)

## 용도

- 구현된 코드 변경에 대해 컴파일 및 정적 검증 관점의 위험을 점검한다.

## 준비사항

- AGENTS.md 규칙을 최우선으로 준수한다.
- 규칙 충돌 시 AGENTS.md 기준을 따른다.
- 불확실한 규칙은 TODO로 남긴다.
- `05_implement_slice` 실행 결과(변경 요약)가 준비되어야 한다.
- 필요한 경우 `06_write_web_tests` 변경사항도 반영되어 있어야 한다.

## 실행 명령어 예시

```sh
cat <<'PROMPT' | codex exec --sandbox workspace-write -
$run_static_checks

code_changes: ./docs/features/update-user-location-on-admin/artifacts/05_code_changes.md

PROMPT
```

## 입력/출력

- 입력: code_changes
- 출력: static_check_result

## 단계 연결

- 이전 스텝: 05_implement_slice 또는 06_write_web_tests
- 이후 스텝: 05_implement_slice 또는 종료