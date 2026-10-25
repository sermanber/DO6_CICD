#!/bin/bash

SUCCESS=0
FAIL=0
LEAKTESTSUCCESS=0
LEAK=0

echo -e "Hello world\nwersgdzg\n2423525\n098sfd75gf09\nfoo bar\n" > test1.txt
echo -e "foo bar\nbaz qux\nhello test\n" > test2.txt
echo -e "no matches here\nthis is safe\n" > test3.txt

function run_test {
    local pattern="$1"
    local flags="$2"
    shift
    shift
    local files=("$@")
    
    echo "Запуск теста: grep -$flags \"$pattern\" ${files[*]}"
    if diff <(grep -$flags "$pattern" "${files[@]}") <(./s21_grep -$flags "$pattern" "${files[@]}"); then 
        (( SUCCESS++ ))
    else
        (( FAIL++ ))
        echo "-----------------------------"
    fi
}

function check_memory_leaks {
    local pattern="$1"
    local flags="$2"
    shift
    shift
    local files=("$@")
    
    valgrind --leak-check=full --track-origins=yes --error-exitcode=1 ./s21_grep -$flags "$pattern" "${files[@]}" &> valgrind_output.txt
    
    # Проверка на наличие утечек
    if grep -q "ERROR SUMMARY: 0 errors from 0 contexts" valgrind_output.txt; 
    then
        echo "Утечек памяти не обнаружено."
        (( LEAKTESTSUCCESS++ ))
    else
        echo "Обнаружены утечки памяти!"
        (( LEAK++ ))
    fi
}

# Пример тестирования с несколькими файлами
run_test "hello" "e" "test1.txt" "test2.txt"
run_test "HELLO" "i" "test2.txt" "test3.txt"
run_test "foo" "v" "test1.txt" "test2.txt" "test3.txt"
run_test "hello" "c" "test2.txt" "test3.txt"
run_test "nonexist" "n" "test1.txt" "test2.txt" "test3.txt"
run_test "foo" "l" "test1.txt" "test2.txt" "test3.txt"
run_test "hello" "l" "test1.txt" "test2.txt"
run_test "HELLO" "n" "test2.txt" "test3.txt"
run_test "foo" "c" "test1.txt" "test2.txt" "test3.txt"
run_test "hello" "v" "test2.txt" "test3.txt"
run_test "nonexist" "i" "test1.txt" "test2.txt" "test3.txt"
run_test "foo" "e" "test1.txt" "test2.txt" "test3.txt"
# Пример тестирования с одним файлом
run_test "hello" "e" "test1.txt"
run_test "HELLO" "i" "test3.txt"
run_test "foo" "v" "test1.txt"
run_test "hello" "c" "test2.txt"
run_test "nonexist" "n" "test3.txt"
run_test "foo" "l" "test2.txt"
run_test "hello" "l" "test1.txt"
run_test "HELLO" "n" "test3.txt"
run_test "foo" "c" "test1.txt"
run_test "hello" "v" "test2.txt"
run_test "nonexist" "i" "test3.txt"
run_test "foo" "e" "test2.txt"
# Тестирование на утечки
check_memory_leaks "hello" "e" "test1.txt" "test2.txt"
check_memory_leaks "HELLO" "i" "test2.txt" "test3.txt"
check_memory_leaks "foo" "v" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "hello" "c" "test2.txt" "test3.txt"
check_memory_leaks "nonexist" "n" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "foo" "l" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "hello" "e" "test1.txt"
check_memory_leaks "HELLO" "i" "test3.txt"
check_memory_leaks "foo" "v" "test1.txt"
check_memory_leaks "hello" "c" "test2.txt"
check_memory_leaks "nonexist" "n" "test3.txt"
check_memory_leaks "foo" "l" "test2.txt"
# Не передан шаблон
check_memory_leaks "l" "test2.txt"
# Не существующий флаг
check_memory_leaks "foo" "p" "test2.txt"
# Не существующий файл
check_memory_leaks "foo" "l" "test4.txt"

rm test1.txt test2.txt test3.txt valgrind_output.txt

echo "Успешные тесты: $SUCCESS"
echo "Неуспешные тесты: $FAIL"
echo "Успешные тесты на утечки: $LEAKTESTSUCCESS"
echo "Неуспешные тесты на утечки: $LEAK"

if [ "$FAIL" -ne 0 ] || [ "$LEAK" -ne 0 ]; then
    exit 1
fi
exit 0