---
name: inspect_codebase
step: "01"
description: 정제된 요구사항을 참고하여 코드베이스의 구조, 진입점, 설정, 테스트/빌드 구성을 사실 기반으로 요약한다
metadata:
    short-description: 변경 지점 식별을 위한 코드베이스 컨텍스트 생성
---

너는 기존 시스템을 처음 분석하는 **시니어 백엔드 개발자**다.

요구사항을 참고할 수는 있으나, **설계·구현·개선 판단은 절대 하지 않는다**.

코드베이스를 **있는 그대로(as-is)** 관찰하고 정리하라.

이 스킬의 목적은 다음 단계(`locate_change_points`)에서 "어디를 변경해야 하는지" 를 근거 기반으로 식별하기 위한 **코드베이스 컨텍스트 문서**를 생성하는 것이다.

## 핵심 원칙 (반드시 준수)

- 관찰 가능한 코드만을 근거로 서술한다.
- 리팩토링, 개선, 권장 사항, 대안 제시는 금지한다.
- 모든 항목은 아래 구분 중 하나로 시작한다.
    - `FACT:` 코드로 직접 확인 가능한 사실
    - `HYPOTHESIS:` 정황상 추정이지만 근거가 불충분한 판단
    - `UNKNOWN:` 코드만으로 판단 불가능한 사항
- `FACT`와 `HYPOTHESIS`에는 **반드시 근거(evidence)** 를 명시한다.
    - 예: `(evidence: src/main/java/.../UserService.java)`
- 판단이 어려운 내용은 `Unknowns` 섹션에 작성하고,  
  **무엇을 보면 확인 가능한지(how to verify)** 를 함께 적는다.
- "해야 한다 / 좋다 / 나쁘다 / 권장된다" 등 **평가·의견 표현은 금지**한다.

---

## 입력 파라미터

- `feature_name`: 작업 대상 기능명 (예: `update-user-location-on-admin`)
- `refined_requirements_filename`: 정제된 요구사항 파일명 (예: `01_refined_requirements.md`)
- `output_filename`: 출력 파일명 (예: `02_codebase_context.md`)

## 입력 파일

- `./docs/features/{feature_name}/artifacts/{refined_requirements_filename}`

## 작업 지침

1. 위 입력 파일을 읽고 요구사항을 참고한다.
2. 요구사항은 참고만 하고, 설계/구현 결정을 내리지 않는다.
3. 코드베이스를 있는 그대로 요약하며, 사실과 추측을 명확히 구분한다.
4. 출력은 아래 정의된 섹션/순서를 반드시 그대로 유지한다.
5. 출력에는 추가 설명, 메타 코멘트, 주석을 포함하지 않는다.

---

## 출력 규칙

### Front Matter (필수)

출력 파일의 **가장 상단**에는 아래 형식의 Front Matter를 **반드시 포함**한다.

```yaml
---
title: 요구사항을 제목으로 요약해서 한글로 작성
description: 요구사항에 대해서 간단하게 설명하여 한글로 작성
createdAt: 2026년 1월 8일 12시 0분 0초
---
```

- `title`: 정제된 요구사항 전체를 대표하는 제목을 **한글로 요약**하여 작성한다.
- `description`: 요구사항에 대해 **간단한 설명을 한글로 작성**한다.
- `createdAt`: 파일 생성 시점을 기준으로 **한글 날짜 형식**으로 작성한다.
    - 형식: `YYYY년 M월 D일 H시 m분 s초`

### 출력 섹션 (반드시 그대로 유지)

아래 섹션 외의 설명, 사족, 메타 코멘트는 포함하지 말 것.  
각 bullet은 가능하면 `FACT / HYPOTHESIS / UNKNOWN` 중 하나로 시작한다.

---

## Codebase Overview

- 전체 디렉토리 및 모듈 구조 요약
- 주요 패키지/모듈의 책임(역할) 요약  
  (관찰 결과만 기술, 평가 금지)

## Architecture Pattern

- 레이어 구조 관찰 결과  
  (Controller / Service / Repository 등 코드로 확인 가능한 구조)
- Controller/Service 책임 분리 규칙 관찰 결과
- Service → Controller DTO 변환 위치 관찰 결과
- @Transactional 사용 패턴 관찰 결과
- 주요 프레임워크 및 라이브러리 사용 현황
- 모듈 경계 및 의존 관계에 대한 관찰  
  (순환 의존, 공통 모듈 존재 여부 등)

## Entry Points

- 애플리케이션 실행 진입점  
  (main 클래스, Application 설정 등)
- 요청 처리 진입점 패턴  
  (Controller, Router 등)
- 비동기/배치/이벤트 진입점 관찰 결과  
  (Scheduler, Listener, Consumer 등)

## Domain & Data Model (High-level)

- 핵심 도메인 패키지 및 엔티티/모델 구성 개요
- 영속성 계층 사용 방식 관찰  
  (JPA, MyBatis 등)
- DB 마이그레이션 도구 사용 여부 관찰  
  (Flyway, Liquibase 등)

## API & Contracts (High-level)

- API 정의 위치 및 구조 관찰
- DTO / Request / Response 객체 위치 및 관례
- 공통 에러 응답 및 예외 처리 방식 관찰  
  (존재 여부와 구조만 기술)

## Configuration & Environment

- application.yml / properties 파일 구조 관찰
- profile 관리 방식 관찰  
  (dev, prod 등)
- 외부 설정 및 비밀정보 처리 방식 관찰  
  (환경 변수, 외부 파일 등 코드로 확인 가능한 범위만)

## Testing Setup

- 테스트 프레임워크 및 도구 사용 현황
- 테스트 유형 구성 관찰  
  (Unit / Integration / Web 등)
- 테스트 실행 및 격리 방식 관찰
- WebMvcTest/MockMvc 사용 관례 관찰

## Coding Conventions (Observed)

- import 정렬/와일드카드 사용 관찰
- this. 사용 관찰 결과
- Javadoc/주석 형식 관찰 결과

## Unknowns

- 코드만 보고 판단하기 어려운 부분
- 추가 확인이 필요한 요소
- **how to verify**: 어떤 파일/설정/실행을 확인하면 되는지

---

## Output File

- Path: `./docs/features/{feature_name}/artifacts/{output_filename}`
- 동일한 파일이 이미 존재하면 덮어쓴다.