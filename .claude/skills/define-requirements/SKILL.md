---
name: define-requirements
description: AI 개발을 위한 상세 기획문서(요구사항 명세) 생성 스킬. 사용자의 기획 초안을 받아 완전한 요구사항 문서로 확장합니다.
tools: ["Read", "Grep", "Glob", "Write", "AskUserQuestion"]
context: fork
model: sonnet
---
# define-requirements

AI 개발을 위한 상세 기획문서(요구사항 명세) 생성 스킬

## Description

사용자가 작성한 기획 초안을 받아서, AI가 독립적으로 개발할 수 있는 수준의 상세한 요구사항 명세 문서를 생성합니다.

**주요 기능**:
- 기획 초안을 구조화된 문서 세트로 확장
- 모듈별 상세 명세 (API, DB, 로직, 테스트) 작성
- 예외 처리, 테스트 시나리오, 완료 조건 명시

**적합한 상황**:
- 2주 이상 소요되는 중대형 프로젝트
- AI에게 개발을 위임할 예정
- 여러 모듈/API가 관련된 기능
- 명확한 구현 명세가 필요한 경우

**부적합한 상황**:
- 단순 버그 수정 (1-2일 작업)
- 탐색적 프로토타이핑
- 요구사항이 불명확한 초기 단계

**다음 단계**:
- 이 스킬 완료 후 `planning` 에이전트를 실행하여 work_plan.json 생성
- 그 후 `implement` 에이전트로 구현 진행

## Usage

```bash
# 기본 사용
/define-requirements [초안 파일 경로]

# 특정 모듈만 상세화
/define-requirements [초안 파일 경로] --module=order

# 출력 디렉토리 지정
/define-requirements [초안 파일 경로] --output=./docs/specs/
```

## Arguments

- `draft_path` (required): 기획 초안이 작성된 마크다운 파일 경로
- `--module` (optional): 특정 모듈만 상세화 (전체 프로젝트가 아닌 경우)
- `--output` (optional): 출력 디렉토리 (기본값: ./docs/specs/)

## Instructions

당신은 대규모 프로젝트의 **테크니컬 라이터**입니다. 사용자의 기획 초안을 받아 AI 개발자가 독립적으로 작업할 수 있는 완전한 요구사항 명세를 작성합니다.

**중요**: 이 스킬은 `context: fork`로 설정되어 격리된 환경에서 실행됩니다. verbose 출력은 메인 대화를 오염시키지 않으며, 완료 후 요약만 반환됩니다.

### Phase 1: 초안 분석 (5분)

#### 1.1 기획 초안 읽기

STEP 1: Read 도구로 draft_path 파일 읽기

추출할 정보:
- 핵심 기능 목록
- API 엔드포인트 (있는 경우)
- 데이터베이스 변경사항
- 비즈니스 로직 (수도코드)
- 기술 스택 (있는 경우)

#### 1.2 코드베이스 탐색 (개요 수준)

STEP 2-1: 프로젝트 구조 파악

**Multi Module 프로젝트 여부 확인**:
```
1. Glob: "settings.gradle", "build.gradle", "pom.xml"
2. Read: settings.gradle 또는 root pom.xml
   → include(...) 또는 <modules> 태그로 Multi Module 판단
```

**Multi Module인 경우 추가 분석**:
```
파악할 내용:
- 모듈 목록 및 이름 (api, domain, common, batch 등)
- 각 모듈의 책임 범위:
  * api: REST Controller, DTO
  * domain: Entity, Repository, Service (비즈니스 로직)
  * common: Utils, Config, Exception
  * batch: 배치 작업 (선택)
  * infrastructure: 외부 연동 (선택)
```

**참고**: 상세한 코드 분석은 `planning` 에이전트에서 수행합니다.

#### 1.3 범위 확인 질문

STEP 3: AskUserQuestion 도구로 불명확한 부분 질문

질문 예시:
1. "이 기능의 우선순위는?"
    - Must Have (반드시 구현)
    - Should Have (가능하면 구현)
    - Could Have (시간 있으면)

2. "예상 작업 기간은?"
    - 1-2주
    - 2주-1개월
    - 1개월 이상

3. "성능 요구사항이 있나요?"
    - TPS 목표
    - 응답시간 목표
    - 동시 사용자 수

4. "제외할 기능이 명확한가요?"
    - Phase 2로 미룰 기능
    - 아예 하지 않을 기능

### Phase 2: 문서 구조 설계 (2분)

#### 2.1 프로젝트 규모 판단

```python
if 예상_기간 <= 2주:
    규모 = "소규모"
    문서 = [
        "PROJECT_OVERVIEW",
        "MODULE_SPEC"
    ]

elif 예상_기간 <= 4주:
    규모 = "중규모"
    문서 = [
        "PROJECT_OVERVIEW",
        "DATABASE_DESIGN",
        "API_SPECIFICATION",
        "MODULES/*"
    ]

else:
    규모 = "대규모"
    문서 = [
        "PROJECT_OVERVIEW",
        "ARCHITECTURE",
        "DATABASE_DESIGN",
        "API_SPECIFICATION",
        "MODULES/*",
        "CROSS_CUTTING_CONCERNS",
        "DEPLOYMENT"
    ]
```

#### 2.2 사용자 승인

STEP 4: 생성할 문서 목록을 사용자에게 제시

"기획 초안을 분석했습니다.

**프로젝트 규모**: 중규모 (3-4주 예상)

**생성할 문서**:
- 00. PROJECT_OVERVIEW.md (프로젝트 개요, 제약사항)
- 02. DATABASE_DESIGN.md (스키마, 마이그레이션)
- 03. API_SPECIFICATION.md (전체 API 목록)
- 05. MODULES/ORDER.md (주문 모듈 상세)
- 05. MODULES/PAYMENT.md (결제 모듈 상세)

이 구조로 진행할까요?"

승인받으면 다음 Phase로

### Phase 3: 문서 작성 (20-40분)

#### 3.1 PROJECT_OVERVIEW.md 작성

작성 내용:
- 프로젝트 목표 (1-2문장)
- 전체 스코프 (기간, 규모, 주요 기능)
- 범위 내/외 명확화 (포함/제외 기능)
- 핵심 제약사항 (성능, 보안, 데이터, 하위 호환)
- 기술 스택
- 우선순위 (MoSCoW)
- 참고 문서

**작성 원칙**:
- 모호한 표현 절대 금지 ("적절히", "가능하면")
- 숫자로 측정 가능한 목표
- 제외 항목 명시적으로

#### 3.2 DATABASE_DESIGN.md 작성

각 테이블마다:
1. CREATE TABLE SQL
2. 컬럼 설명 및 제약조건
3. 인덱스 전략
4. 마이그레이션 스크립트 (경로: db/migration/V*.sql)
5. 롤백 스크립트 (경로: db/migration/V*.rollback.sql)
6. 영향도 분석

#### 3.3 API_SPECIFICATION.md 작성

전체 API 목록 테이블 작성.
각 API의 상세 내용은 MODULES 문서에서 다룸.

#### 3.4 MODULES/[모듈명].md 작성 (가장 중요)

각 모듈마다:

1. **모듈 개요**
    - 책임 범위
    - 의존 모듈
    - 외부 연동

2. **API 명세**
    - Request/Response (JSON 예시)
    - Validation Rules (정규식, 범위)
    - Error Cases (모든 예외 상황)

3. **비즈니스 로직 (수도코드)**
    - 실행 흐름 (step-by-step)
    - 트랜잭션 범위 명시
    - 동시성 제어 방법
    - 예외 처리 위치

⚠️ 중요: 수도코드는 Python/Java 스타일로 작성
- 변수명, 함수명 명확히
- if/for 조건 구체적으로
- 주석으로 의도 설명

4. **데이터베이스 설계**
    - 테이블 스키마 (SQL)
    - 인덱스 전략

5. **예외 처리 상세**
    - 예외 종류
    - 발생 조건
    - 재시도 전략
    - 로그 레벨

6. **테스트 시나리오**
    - 단위 테스트 (함수명까지)
    - 통합 테스트 (Given-When-Then)
    - 동시성 테스트
    - E2E 체크리스트

7. **성능 요구사항**
    - 목표 지표 (TPS, 응답시간)
    - 최적화 포인트
    - 모니터링 지표

**작성 원칙**:
- **모호함 제거**: "적절히", "필요시" 금지
- **구체적 예시**: 실제 JSON, SQL 포함
- **완전성**: AI가 다른 문서 안 봐도 구현 가능하도록
- **테스트 가능**: 완료 조건이 측정 가능해야 함

### Phase 4: 검증 및 완성 (5분)

#### 4.1 상위-하위 문서 일관성 검증 (⚠️ 중요)

**반드시 실행**: PROJECT_OVERVIEW.md의 모든 기능이 MODULES/*.md에 포함되었는지 검증

```python
# 검증 수도코드
def verify_scope_coverage():
    # 1. PROJECT_OVERVIEW.md에서 "포함 기능 (IN SCOPE)" 섹션 추출
    in_scope_items = extract_in_scope_from_overview()

    # 2. 모든 MODULES/*.md 문서 읽기
    module_docs = read_all_module_docs()

    # 3. 각 IN SCOPE 항목이 MODULES 문서에 구현 명세로 포함되었는지 확인
    missing_items = []
    for item in in_scope_items:
        if not is_covered_in_modules(item, module_docs):
            missing_items.append(item)

    # 4. 누락된 항목이 있으면 경고 및 보완
    if missing_items:
        print("⚠️ 경고: 다음 IN SCOPE 항목이 모듈 문서에 누락됨:")
        for item in missing_items:
            print(f"  - {item}")
        # 누락된 항목을 해당 모듈 문서에 추가
        add_missing_specs_to_modules(missing_items)
```

**검증 체크리스트**:
- [ ] ✅ PROJECT_OVERVIEW.md의 모든 IN SCOPE 항목이 MODULES/*.md에 명세됨
- [ ] ✅ MODULES/*.md의 메서드/클래스가 IN SCOPE 기능을 완전히 커버함
- [ ] ✅ 기존 코드와 새로 구현할 코드가 명확히 구분됨

#### 4.2 자기 검증 체크리스트

실행할 검증:
- [ ] 모든 API에 에러 케이스 정의됨
- [ ] 트랜잭션 범위 명시됨
- [ ] 동시성 이슈 고려됨
- [ ] 테스트 시나리오 구체적 (함수명까지)
- [ ] 성능 목표 숫자로 제시
- [ ] 롤백 계획 있음
- [ ] 제외 사항 명시됨

#### 4.2 문서 간 링크 연결

각 문서에서 다른 문서 참조 시 명확한 경로 사용.

#### 4.3 README.md 생성

명세 사용 가이드 작성:
- 문서 구조 설명
- 읽는 순서
- **프로젝트 구조 (Multi Module인 경우 모듈 설명)**
  ```
  예시:
  - api: REST API 컨트롤러, DTO
  - domain: 비즈니스 로직, Entity, Repository
  - common: 공통 유틸, 예외, 설정
  - batch: 배치 작업 (선택)
  ```

### Phase 5: 사용자 리뷰 (10분)

#### 5.1 생성 완료 알림

**중요**: `context: fork`로 실행되므로, 요약만 메인 대화로 반환

사용자에게 간결한 요약 제시:

"요구사항 명세 작성 완료!

📁 {output_directory}/
├── 00. PROJECT_OVERVIEW.md
├── 02. DATABASE_DESIGN.md
├── 03. API_SPECIFICATION.md
├── 05. MODULES/
│   ├── ORDER.md
│   └── PAYMENT.md
└── README.md

**주요 내용**:
- 기능 A: {설명}
- 기능 B: {설명}
- 예상 작업량: 중규모 (3-4주)

**다음 단계**:
`planning` 에이전트를 실행하여 코드 분석 및 work_plan.json 생성:
→ /planning 또는 '구현 계획 세워줘'"

#### 5.2 수정 요청 처리

사용자 피드백에 따라:
- 우선순위 조정 → OVERVIEW 수정
- 기능 추가/삭제 → 해당 MODULE 수정
- 성능 목표 조정 → MODULE 수정

## Output

생성되는 파일 구조:
```
{output_directory}/
├── 00. PROJECT_OVERVIEW.md
├── 01. ARCHITECTURE.md (optional, 중대형)
├── 02. DATABASE_DESIGN.md
├── 03. API_SPECIFICATION.md
├── 05. MODULES/
│   ├── {MODULE_1}.md
│   ├── {MODULE_2}.md
│   └── ...
├── 06. CROSS_CUTTING_CONCERNS.md (optional, 대형)
├── 07. DEPLOYMENT.md (optional)
└── README.md
```

## Best Practices

### 0. Multi Module 프로젝트 고려사항
```
✅ 반드시 포함:
- 각 모듈의 책임 범위 명확히 파악
- 모듈 간 의존성 그래프 작성

❌ 피해야 할 것:
- 단일 모듈 가정으로 경로 작성 (src/main/java/...)
- 모듈 간 순환 의존성 유발 (domain → api → domain)
```

### 1. 모호함 제거
```
❌ "적절히 예외 처리"
✅ "재고 부족 시 InsufficientStockException 발생, HTTP 400"

❌ "성능 최적화"
✅ "N+1 방지: Fetch Join, 응답 < 2초 (P95)"
```

### 2. AI 친화적 수도코드
```python
# ✅ 명확한 수도코드
def createOrder(userId, items):
    # 1. 재고 확인 (실패 시 즉시 리턴)
    for item in items:
        stock = stockService.getStock(item.productId)
        if stock < item.quantity:
            raise InsufficientStockException(item, stock)

    # 2. 결제 (트랜잭션 밖)
    result = tossApi.pay(totalAmount)
    if not result.success:
        raise PaymentFailedException(result.reason)

    # 3. 주문 생성 (트랜잭션)
    with transaction:
        order = orderRepository.save(newOrder)
        stockService.decrease(items)
```

### 3. 완료 조건의 구체성
```
❌ "주문 API 구현"
✅ "주문 API 구현:
    - [ ] 통합 테스트 3개 이상
    - [ ] 재고 부족 시 400 에러
    - [ ] 동시성 테스트 100회 성공"
```

### 4. 문서 검증 방법
명세 작성 후 테스트:
"05. MODULES/ORDER.md만 보고 주문 API 구현해줘"

→ 구현 가능하면 문서 완전
→ 질문 많으면 보완 필요

## Notes

- 이 스킬은 `context: fork`로 실행되어 메인 대화를 오염시키지 않습니다
- verbose 출력은 격리되며, 완료 후 요약만 반환됩니다
- 생성된 명세는 다른 개발자와 공유 가능한 수준이어야 합니다
- **이 스킬은 "무엇을" 만들지 정의합니다**
- **"어떻게" 만들지는 `planning` 에이전트에서 결정합니다**
- 구현 중 피드백으로 계속 업데이트됩니다
