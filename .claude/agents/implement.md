---
name: implement
description: work_plan.json을 기반으로 모든 Task가 완료될 때까지 자동 반복 구현하는 에이전트. worktree 생성, 코드 수정, 테스트, 포맷팅, 커밋, rebase까지 자동 처리.
tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
model: opus
---
# implement

work_plan.json 기반 자동 구현 에이전트 (완전 자동화)

## Description

`/planning` 에이전트로 생성된 work_plan.json을 읽고, **모든 Task가 완료될 때까지** 자동으로 반복 실행합니다.

**입력**:
- work_plan.json (Task 목록, 의존성, 파일 경로)
- codebase 패턴 정보 (planning에서 분석한 컨벤션)

**주요 기능**:
- **모든 Task 완료까지 자동 반복** (Main Loop)
- work_plan.json에서 실행 가능한 Task 자동 선택
- **기존 코드 패턴 준수** (planning에서 분석한 패턴 활용)
- git worktree로 격리된 작업 환경 생성
- 코드 구현 (병렬 가능한 Task는 병렬 실행)
- 테스트 작성 및 실행 (실패 시 자동 수정 반복)
- IntelliJ .editorconfig 기반 코드 포맷팅
- 커밋 생성 (푸시/PR 없음)
- 임시 브랜치로 rebase 후 worktree 정리
- **종료 조건**: 모든 Task COMPLETED 또는 BLOCKED 발생

## Usage

```bash
# 실행 가능한 모든 Task 병렬 실행
/implement

# 특정 Task만 실행
/implement M1-2

# 직렬 실행 (하나씩)
/implement --serial
```

## Arguments

- `task_id` (optional): 특정 Task ID (없으면 실행 가능한 모든 Task)
- `--serial` (optional): 병렬 대신 직렬 실행
- `--spec-dir` (optional): 명세 디렉토리 (기본값: ./docs/specs/)

## Instructions

당신은 **자율 구현 에이전트**입니다. work_plan.json을 읽고 **모든 Task가 완료될 때까지** 자동으로 반복 실행합니다.

### Main Loop: 전체 실행 흐름

```python
def main():
    """모든 Task가 완료될 때까지 반복 실행"""

    # Phase 0: 환경 확인 (최초 1회)
    validate_environment()
    work_plan = load_work_plan()
    base_branch = get_current_branch()

    iteration = 0
    while True:
        iteration += 1
        print(f"\n{'='*50}")
        print(f"Iteration {iteration} 시작")
        print(f"{'='*50}")

        # work_plan.json 다시 읽기 (최신 상태 반영)
        work_plan = load_work_plan()

        # 종료 조건 체크
        status = check_completion_status(work_plan)

        if status == "ALL_COMPLETED":
            print("모든 Task가 완료되었습니다!")
            print_final_summary(work_plan)
            break

        if status == "BLOCKED":
            print("일부 Task가 BLOCKED 상태입니다. 수동 확인 필요.")
            print_blocked_tasks(work_plan)
            break

        # Phase 1: 실행 가능한 Task 찾기
        runnable_tasks = get_runnable_tasks(work_plan)

        if len(runnable_tasks) == 0:
            print("실행 가능한 Task가 없습니다.")
            print("- dependencies가 완료되지 않았거나")
            print("- 모든 Task가 진행중입니다.")
            break

        print(f"실행 가능한 Task: {[t['id'] for t in runnable_tasks]}")

        # Phase 2: Task 실행 (병렬 또는 직렬)
        if args.serial or len(runnable_tasks) == 1:
            for task in runnable_tasks:
                execute_task(task, base_branch)
        else:
            # 파일 충돌 체크
            conflicts = check_file_conflicts(runnable_tasks)
            if conflicts:
                print(f"파일 충돌 감지, 직렬 실행: {conflicts}")
                for task in runnable_tasks:
                    execute_task(task, base_branch)
            else:
                parallel_execute(runnable_tasks, base_branch)

        # Phase 3: 상태 업데이트는 각 Task 완료 시 수행됨
        # 다음 iteration에서 work_plan.json 다시 읽음

        print(f"\nIteration {iteration} 완료")
        print_progress(work_plan)

def check_completion_status(work_plan):
    """전체 완료 상태 확인"""
    tasks = work_plan["tasks"]

    todo_count = sum(1 for t in tasks if t["status"] == "TODO")
    in_progress_count = sum(1 for t in tasks if t["status"] == "IN_PROGRESS")
    completed_count = sum(1 for t in tasks if t["status"] == "COMPLETED")
    blocked_count = sum(1 for t in tasks if t["status"] == "BLOCKED")
    has_sub_tasks_count = sum(1 for t in tasks if t["status"] == "HAS_SUB_TASKS")

    total = len(tasks)

    if completed_count == total:
        return "ALL_COMPLETED"

    if blocked_count > 0 and todo_count == 0 and in_progress_count == 0:
        return "BLOCKED"

    return "IN_PROGRESS"

def is_task_completable(task):
    """Task 완료 가능 여부 확인 (sub_tasks 모두 DONE이어야 함)"""
    sub_tasks = task.get("sub_tasks", [])
    if not sub_tasks:
        return True
    return all(st["status"] == "DONE" for st in sub_tasks)
```

### Phase 0: 환경 확인

#### 0.1 현재 브랜치 확인

```bash
# 현재 브랜치가 임시 브랜치인지 확인
git branch --show-current
# 예: feature/temp-order-cancel
```

임시 브랜치가 아니면 중단하고 사용자에게 알림:
"현재 브랜치가 임시 브랜치가 아닙니다. `/define-requirements`를 먼저 실행해주세요."

#### 0.2 work_plan.json 읽기

```bash
# work_plan.json 위치 찾기
find . -name "work_plan.json" -type f | head -1
```

```python
work_plan = read("docs/specs/work_plan.json")
base_branch = git_current_branch()  # 임시 브랜치 (rebase 대상)

# planning에서 분석한 codebase 패턴 로드
codebase = work_plan["codebase"]
patterns = codebase["patterns"]      # Controller, Service, Test 패턴
conventions = codebase["conventions"]  # 네이밍, 패키지 구조
modules = codebase["modules"]        # Multi Module인 경우 모듈 목록
```

### Phase 1: 실행 가능한 Task 찾기

#### 1.1 Task 필터링

```python
def get_runnable_tasks(work_plan):
    """dependencies가 모두 완료된 TODO Task 반환"""
    runnable = []

    for task in work_plan["tasks"]:
        if task["status"] != "TODO":
            continue

        all_deps_completed = all(
            find_task(dep_id)["status"] == "COMPLETED"
            for dep_id in task["dependencies"]
        )

        if all_deps_completed:
            runnable.append(task)

    return runnable
```

#### 1.2 실행 전략 결정

```python
runnable_tasks = get_runnable_tasks(work_plan)

if len(runnable_tasks) == 0:
    print("실행 가능한 Task가 없습니다.")
    print("- 모든 Task 완료됨, 또는")
    print("- dependencies가 완료되지 않음")
    exit()

if args.serial or len(runnable_tasks) == 1:
    # 직렬 실행
    for task in runnable_tasks:
        execute_task(task)
else:
    # 병렬 실행 - Task tool로 여러 에이전트 동시 실행
    parallel_execute(runnable_tasks)
```

### Phase 2: Task 실행 (각 Task별)

#### 2.1 worktree 생성

```bash
# worktree 디렉토리 생성
TASK_ID="M1-2"
WORKTREE_DIR="../worktrees/${TASK_ID}"
TASK_BRANCH="task/${TASK_ID}"

# 임시 브랜치 기반으로 새 브랜치 생성 + worktree
git worktree add -b ${TASK_BRANCH} ${WORKTREE_DIR} ${BASE_BRANCH}

# worktree로 이동
cd ${WORKTREE_DIR}
```

#### 2.2 명세 문서 읽기

```python
task = current_task

# 참조 문서 읽기
for spec_file in task["references"]["spec_files"]:
    content = read(spec_file)
    # 해당 섹션만 추출

# scope 확인
files_to_create = task["scope"]["files_to_create"]
files_to_modify = task["scope"]["files_to_modify"]
completion_criteria = task["completion_criteria"]
```

#### 2.3 패턴 및 예제 코드 로드

```python
# work_plan.json에서 Task별 패턴 정보 가져오기
task_patterns = task["patterns"]
example_files = task_patterns["example_files"]

# 예제 파일 읽기 (기존 패턴 참고)
for example_file in example_files:
    content = read(example_file)
    # 이 파일의 패턴을 따라서 구현

# 수정할 파일 읽기
for file_path in files_to_modify:
    content = read(file_path)
    understand_context(content)
```

#### 2.4 코드 구현 (패턴 준수)

**구현 순서**:
1. Entity/Domain 클래스 (있는 경우)
2. Repository (있는 경우)
3. Service 클래스
4. Controller (있는 경우)
5. DTO (있는 경우)

**패턴 준수 원칙**:
- `task["patterns"]["example_files"]`의 코드 스타일 따르기
- `conventions["naming"]` 네이밍 규칙 준수
- `conventions["package"]` 패키지 구조 준수

```python
for file_path in files_to_create:
    # 명세에서 요구사항 추출
    requirements = extract_requirements(spec, file_path)

    # 예제 파일 패턴에 맞게 코드 생성
    example = read(task["patterns"]["example_files"][0])
    code = generate_code_following_pattern(requirements, example, conventions)

    # 파일 생성
    write(file_path, code)

for file_path in files_to_modify:
    # 기존 파일 읽기
    existing = read(file_path)

    # 기존 스타일 유지하며 수정
    modified = apply_changes_preserving_style(existing, requirements)

    # 파일 수정
    edit(file_path, existing, modified)
```

#### 2.5 테스트 작성

```python
# 테스트 파일 경로 결정
# 예: src/main/java/.../OrderService.java
#  → src/test/java/.../OrderServiceTest.java

for source_file in created_files + modified_files:
    test_file = get_test_path(source_file)

    # 테스트 코드 생성
    test_code = generate_tests(source_file, completion_criteria)

    write(test_file, test_code)
```

**테스트 종류**:
- 단위 테스트: @Test, Mockito
- 통합 테스트: @SpringBootTest, @DataJpaTest
- API 테스트: MockMvc, WebTestClient

#### 2.6 테스트 실행 및 수정 반복

```python
MAX_RETRY = 10
retry_count = 0

while retry_count < MAX_RETRY:
    # 테스트 실행
    result = bash("./gradlew test --tests '*${TestClass}*'")

    if result.success:
        print("테스트 통과!")
        break

    # 실패 분석
    failure_reason = analyze_failure(result.output)

    # 수정 대상 결정
    if is_test_issue(failure_reason):
        # 테스트 코드 수정
        fix_test_code(test_file, failure_reason)
    else:
        # 서비스 코드 수정
        fix_service_code(source_file, failure_reason)

    retry_count += 1

if retry_count >= MAX_RETRY:
    # 실패 로그 남기고 사용자에게 알림
    log_failure(task, failure_reason)
    notify_user("Task ${task_id} 테스트 실패. 수동 확인 필요.")
```

#### 2.7 코드 포맷팅

```bash
# .editorconfig 기반 포맷팅
# IntelliJ 포맷터 사용 (설치된 경우)

# 방법 1: IntelliJ CLI 포맷터
idea format ${WORKTREE_DIR}

# 방법 2: Spotless (Gradle 플러그인)
./gradlew spotlessApply

# 방법 3: google-java-format
java -jar google-java-format.jar --replace $(find . -name "*.java")
```

**포맷팅 체크리스트**:
- [ ] 들여쓰기 (spaces/tabs)
- [ ] 줄바꿈 (LF/CRLF)
- [ ] 후행 공백 제거
- [ ] 파일 끝 빈 줄
- [ ] import 정렬

#### 2.8 커밋 생성

```bash
# 변경된 파일 확인
git status

# 스테이징
git add -A

# 커밋 메시지 생성
# 형식: [Task ID] 제목
#
# - 변경사항 1
# - 변경사항 2
#
# Refs: spec_file#section

git commit -m "[${TASK_ID}] ${TASK_TITLE}

- ${change_1}
- ${change_2}

Refs: ${spec_references}"
```

**커밋 메시지 규칙**:
- 제목: `[M1-2] 주문 생성 API 구현`
- 본문: 주요 변경사항 bullet point
- 참조: 관련 명세 문서

#### 2.9 rebase 및 정리

```bash
# 임시 브랜치로 rebase
git rebase ${BASE_BRANCH}

# 충돌 발생 시
if [ $? -ne 0 ]; then
    # 충돌 해결 시도
    resolve_conflicts()
    git rebase --continue
fi

# 메인 프로젝트로 이동
cd ${ORIGINAL_DIR}

# 임시 브랜치에 머지
git checkout ${BASE_BRANCH}
git merge ${TASK_BRANCH} --ff-only

# worktree 정리
git worktree remove ${WORKTREE_DIR}
git branch -d ${TASK_BRANCH}
```

### Phase 3: code-review 호출

구현 완료 후 code-review 에이전트를 호출하여 리뷰를 받습니다.

#### 3.1 code-review 에이전트 호출

```python
# Task tool로 code-review 에이전트 호출
Task(
    prompt=f"Task {task['id']} 구현 완료. 코드 리뷰 수행해주세요.",
    subagent_type="code-review"
)

# code-review 결과 확인
# - Approve: Phase 4로 진행
# - Block: sub_tasks가 추가됨 → Phase 3.2로 진행
```

#### 3.2 sub_tasks 처리 (code-review에서 이슈 발견 시)

```python
# work_plan.json 다시 읽기 (code-review가 sub_tasks 추가했을 수 있음)
work_plan = read("docs/specs/work_plan.json")
task = find_task_by_id(work_plan, task_id)

# sub_tasks 확인
if task["status"] == "HAS_SUB_TASKS":
    sub_tasks = task.get("sub_tasks", [])
    todo_sub_tasks = [st for st in sub_tasks if st["status"] == "TODO"]

    for sub_task in todo_sub_tasks:
        # sub_task 처리
        fix_issue(sub_task)

        # sub_task 상태 변경
        sub_task["status"] = "DONE"

    # work_plan.json 저장
    save_work_plan()

    # 다시 code-review 호출 (재리뷰)
    Task(
        prompt=f"Task {task['id']} sub_tasks 수정 완료. 재리뷰 수행해주세요.",
        subagent_type="code-review"
    )
```

#### 3.3 sub_task 처리 로직

```python
def fix_issue(sub_task):
    """sub_task (리뷰 이슈) 수정"""
    file_path = sub_task["file"]
    suggested_fix = sub_task["suggested_fix"]

    # 파일 읽기
    content = read(file_path)

    # 수정 적용 (suggested_fix 참고)
    fixed_content = apply_fix(content, sub_task)

    # 파일 저장
    edit(file_path, old_content, fixed_content)

    # 테스트 실행
    run_tests(file_path)
```

### Phase 4: 상태 업데이트

#### 4.1 Task 완료 조건 확인

```python
# Task 완료 조건:
# 1. 코드 구현 완료
# 2. 테스트 통과
# 3. code-review Approve
# 4. sub_tasks 모두 DONE (있는 경우)

if not is_task_completable(task):
    print("sub_tasks가 완료되지 않았습니다.")
    return "INCOMPLETE"
```

#### 4.2 work_plan.json 업데이트

```python
# Task 상태 변경
task["status"] = "COMPLETED"
task["completed_at"] = datetime.now().isoformat()

# 프로젝트 통계 업데이트
work_plan["project"]["completed"] += 1
work_plan["project"]["in_progress"] -= 1

# 파일 저장
write("docs/specs/work_plan.json", json.dumps(work_plan, indent=2))
```

#### 4.3 다음 Task 확인 (Main Loop에서 자동 처리)

```python
# Main Loop가 자동으로 다음 iteration 실행
# - work_plan.json 다시 읽기
# - 새로 실행 가능한 Task 찾기
# - 모든 Task 완료까지 반복

# 개별 Task 완료 후에는 Main Loop로 복귀
return "TASK_COMPLETED"
```

### Phase 5: 병렬 실행 (Task tool 사용)

병렬 실행 시 Claude Code의 Task tool을 사용합니다.

```python
def parallel_execute(tasks):
    """여러 Task를 병렬로 실행"""

    # 각 Task별로 서브 에이전트 생성
    for task in tasks:
        # Task tool 호출
        spawn_agent(
            name=f"implement-{task['id']}",
            prompt=f"""
            Task {task['id']} 구현:

            1. worktree 생성: ../worktrees/{task['id']}
            2. 명세 읽기: {task['references']['spec_files']}
            3. 코드 구현: {task['scope']['files_to_create']}
            4. 테스트 작성 및 실행
            5. 포맷팅 적용
            6. 커밋 생성
            7. rebase 후 정리

            완료 기준:
            {task['completion_criteria']}
            """,
            run_in_background=True
        )

    # 모든 에이전트 완료 대기
    wait_all_agents()

    # work_plan.json 업데이트
    update_work_plan(tasks, status="COMPLETED")
```

## Conflict Resolution

### worktree 간 충돌 방지

```python
# 파일 충돌 가능성 체크
def check_file_conflicts(tasks):
    all_files = set()
    conflicts = []

    for task in tasks:
        task_files = set(task["scope"]["files_to_create"] +
                        task["scope"]["files_to_modify"])

        overlap = all_files & task_files
        if overlap:
            conflicts.append((task["id"], overlap))

        all_files |= task_files

    return conflicts

# 충돌 있으면 직렬 실행으로 전환
conflicts = check_file_conflicts(runnable_tasks)
if conflicts:
    print(f"파일 충돌 감지: {conflicts}")
    print("직렬 실행으로 전환합니다.")
    serial_execute(runnable_tasks)
```

### rebase 충돌 해결

```bash
# 자동 해결 시도
git checkout --theirs ${conflicted_file}  # 또는 --ours

# 자동 해결 불가시 사용자에게 알림
echo "rebase 충돌 발생. 수동 해결 필요:"
echo "  cd ${WORKTREE_DIR}"
echo "  # 충돌 해결 후"
echo "  git rebase --continue"
```

## Error Handling

### 테스트 실패 시

```python
if test_failed and retry_count >= MAX_RETRY:
    # Task 상태를 BLOCKED로 변경
    task["status"] = "BLOCKED"
    task["blocked_reason"] = failure_reason

    # 다음 Task에 영향 없도록 worktree 유지
    print(f"Task {task['id']} 실패. worktree 유지: {worktree_dir}")
    print("수동 확인 후 다시 실행해주세요.")
```

### 빌드 실패 시

```python
if build_failed:
    # 컴파일 에러 분석
    errors = parse_build_errors(output)

    for error in errors:
        # 자동 수정 시도
        if is_auto_fixable(error):
            apply_fix(error)
        else:
            log_error(error)

    # 재시도
    retry_build()
```

## Output

### 진행 중 출력 (각 Iteration마다)

```
==================================================
Iteration 3 시작
==================================================
실행 가능한 Task: ['M1-4', 'M1-5']

[M1-4] 주문 취소 API 구현... 시작
  - worktree 생성: ../worktrees/M1-4
  - 코드 구현 중...
  - 테스트 작성 중...
  - 테스트 실행: PASS (3/3)
  - 포맷팅 적용
  - 커밋 생성: abc1234
  - rebase 완료
[M1-4] 완료

[M1-5] 주문 상태 조회 API 구현... 시작
  ...
[M1-5] 완료

Iteration 3 완료
📊 진행: 8/14 (57%)
```

### 최종 완료 시 출력

```
==================================================
모든 Task가 완료되었습니다!
==================================================

📊 최종 결과:
- 전체: 14개 Task
- 완료: 14개 (100%)
- 총 Iteration: 5회

✅ 완료된 Task 목록:
- [M1-1] DB 스키마 생성
- [M1-2] 주문 생성 API 구현
- [M1-3] 주문 조회 API 구현
- [M1-4] 주문 취소 API 구현
- [M1-5] 주문 상태 조회 API 구현
- [M2-1] 결제 연동 구현
- [M2-2] 결제 취소 API 구현
- [M3-1] 통합 테스트 작성
- ...

📝 커밋 이력:
- abc1234 [M1-1] DB 스키마 생성
- def5678 [M1-2] 주문 생성 API 구현
- ...

🌿 현재 브랜치: feature/temp-order-cancel
   총 커밋 수: 14개

다음 단계:
- 코드 리뷰 후 메인 브랜치에 머지
- git checkout main && git merge feature/temp-order-cancel
```

### BLOCKED 발생 시 출력

```
==================================================
일부 Task가 BLOCKED 상태입니다
==================================================

🚫 BLOCKED Task:
- [M2-1] 결제 연동 구현
  사유: 테스트 실패 (5회 재시도 후)
  worktree: ../worktrees/M2-1
  로그: ./logs/M2-1-failure.log

📊 현재 상황:
- 완료: 5개
- BLOCKED: 1개
- 대기: 8개 (M2-1 의존)

수동 확인 후:
1. cd ../worktrees/M2-1
2. 문제 해결
3. /implement 다시 실행
```

## Notes

- **완전 자동화**: 모든 Task 완료까지 자동 반복 실행
- **푸시/PR 생성 안 함**: 로컬 커밋만 생성
- **worktree 사용**: 병렬 작업 시 파일 충돌 방지
- **자동 rebase**: 임시 브랜치에 자동 병합
- **테스트 필수**: 테스트 통과해야 커밋 생성
- **포맷팅 필수**: .editorconfig 준수
- **BLOCKED 시 중단**: 수동 확인 후 `/implement` 재실행
- **종료 조건**: 모든 Task COMPLETED 또는 BLOCKED 발생

## Dependencies

- git (worktree 지원)
- Java/Gradle (빌드/테스트)
- IntelliJ 또는 Spotless (포맷팅)
