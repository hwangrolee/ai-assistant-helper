---
name: refactoring-review
description: 코드 가독성과 리뷰 용이성 관점에서 리팩토링 필요성을 점검. 리포트만 생성.
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---
# refactoring-review

가독성/리뷰 용이성 관점에서 리팩토링 필요 부분을 점검. **코드 수정 안 함.**

**출력**: `docs/refactoring_report.md`

---

## 리팩토링 철학

```
목적: 중복 제거나 코드 스멜 제거 자체가 아님

리팩토링의 진짜 목적:
1. 코드리뷰 용이성 - 리뷰어가 빠르게 이해 가능한가?
2. 가독성 향상 - 다른 개발자가 의도 파악 가능한가?

과도한 추상화(Over-Engineering)도 리팩토링 대상.
"DRY를 위한 DRY"는 안티패턴.
```

### 판단 기준

| 유형 | 질문 | YES | NO |
|------|------|-----|-----|
| 코드 스멜 | 수정하면 리뷰가 쉬워지는가? | 리포트 | 무시 |
| 과도한 추상화 | 인라인하면 리뷰가 쉬워지는가? | 리포트 | 무시 |

---

## Phase 1: 점검 대상 파악

```bash
# 전체 점검
Glob(pattern="**/*.java", path="대상경로")

# 변경된 파일만
git diff --name-only HEAD~5 -- "*.java"
```

- `CLAUDE.md`, `README.md`에서 컨벤션 확인
- 기존 코드 2-3개 샘플링

---

## Phase 2: 가독성/리뷰 관점 점검

**모든 항목에서 "리뷰 용이성 향상 여부" 판단 필수**

### 2.1 코드 스멜

| 항목 | 탐지 기준 | 리팩토링 조건 |
|------|----------|--------------|
| 긴 메서드 | 50줄 초과 | 책임 혼재로 흐름 파악 어려울 때만 |
| 큰 클래스 | 500줄 초과 | 응집도 낮고 관련 없는 기능 섞일 때만 |
| 깊은 중첩 | 4단계 이상 | Early return으로 개선 가능할 때 |
| 긴 파라미터 | 5개 이상 | 객체로 묶으면 의도 명확해질 때 |
| 중복 코드 | 10줄 이상 | 추출 시 변경점 집중 + 리뷰 용이할 때만 |
| 불명확한 이름 | 단일 문자, 약어 | 리뷰어 혼란 유발 시 |

**리팩토링 대상 아님:**
- 길지만 단계가 명확한 메서드
- 추출해도 가독성 향상 없는 단순 반복
- 테스트 코드의 중복 (가독성 > DRY)

### 2.2 과도한 추상화 (Over-Engineering)

| 항목 | 증상 | 제안 |
|------|------|------|
| 과도한 유틸 추출 | 3~5줄을 위한 별도 클래스 | 인라인 |
| 불필요한 인터페이스 | 구현체 1개 + 확장 계획 없음 | 제거 |
| 과도한 상속 | 3단계 이상, 중간 클래스가 빈 껍데기 | 단순화 |
| 스트림 과용 | 5단계 이상 체인 | 명령형 분리 |
| 제네릭 남용 | 불필요한 타입 파라미터 | 구체 타입 |

### 2.3 탐지 방법

```bash
Grep(pattern="\\{.*\\{.*\\{.*\\{", glob="**/*.java")  # 깊은 중첩
Grep(pattern="@Autowired", glob="**/*.java")          # 필드 주입
Grep(pattern="System\\.out\\.print", glob="**/*.java") # System.out
Glob(pattern="**/*Util*.java")                        # 유틸 클래스
Grep(pattern="implements \\w+", glob="**/*.java")     # 인터페이스 구현
```

---

## Phase 3: 컨벤션 점검

| 항목 | 올바른 패턴 | 위반 패턴 |
|------|-------------|-----------|
| @Transactional | Service 레이어 | Controller, Repository |
| DI 방식 | 생성자 주입 | 필드 주입 (@Autowired) |
| 예외 처리 | 커스텀 예외 + @ExceptionHandler | try-catch 남용 |
| 로깅 | SLF4J + @Slf4j | System.out.println |

---

## Phase 4: 구조적 문제 점검

```
올바른 방향: Controller -> Service -> Repository -> Entity

위반: Repository->Service, Controller->Repository 직접 호출, Entity->Service
```

```bash
Grep(pattern="@Service", path="**/repository/**/*.java")
Grep(pattern="Repository", path="**/controller/**/*.java")
```

---

## Phase 5: 리포트 생성

### 심각도

| 심각도 | 기준 | 예시 |
|--------|------|------|
| HIGH | 의도 파악 불가, 오해 유발 | 불명확한 변수명, 과도한 상속 |
| MEDIUM | 리뷰 시간 증가 | 책임 혼재 메서드, 불필요한 추상화 |
| LOW | 리뷰에 큰 영향 없음 | 경미한 네이밍, 사소한 중복 |

### 템플릿

```markdown
# Refactoring Report

**생성일**: {날짜}
**점검 범위**: {대상 경로}

## 요약
| 심각도 | 수 |
|--------|-----|
| HIGH | {n} |
| MEDIUM | {n} |
| LOW | {n} |

## HIGH
#### [H001] {제목}
- 파일: {경로}
- 라인: {번호}
- 문제: {설명}
- 개선 효과: {가독성/리뷰 개선점}
- 권장 수정: {방법}

## MEDIUM
...

## LOW
...
```

---

## Phase 6: 결과 출력

```
# 이슈 발견
[Refactoring Review] 점검 완료
HIGH: {n} | MEDIUM: {n} | LOW: {n}
리포트: docs/refactoring_report.md
REFACTORING_NEEDED

# 이슈 없음
[Refactoring Review] 점검 완료 - 이슈 없음
CLEAN
```

---

## 체크리스트

- [ ] 점검 대상 파일 모두 읽음
- [ ] 코드 스멜 점검
- [ ] 과도한 추상화 점검
- [ ] 컨벤션 점검
- [ ] 구조적 문제 점검
- [ ] 리포트 생성됨

---

## Notes

- 코드 수정 금지
- 오탐 최소화 - 확실한 문제만, 애매하면 LOW
- 레거시는 관대하게, 신규는 엄격하게
- 구체적 제안 - 실행 가능한 방법
