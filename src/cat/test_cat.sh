#!/bin/bash

SUCCESS=0
FAIL=0
LEAKTESTSUCCESS=0
LEAK=0

echo -e "Hello world\nwersgdzg\n\n\n423525\n098sfd75gf09\nfoo bar\n" > test1.txt
echo -e "Line with \n\n\n\nnon-printable characters:\nHello\x01World\x02! This is an example line with control characters.\nHere are some numbers: \x03\x04\x05\x06.\nA new line with a bell character: \x07. This is a message.\nMore random text with different characters: \x08Backspace\x0CFormfeed\x0E\x0F.\nEnd of lines with non-printable: \x10\x11\x12.\nRepeating: \x01\x02\x03\x04\x05\x01\x02\x03\x04\x05.\nFinal line with non-printable characters: \x1A\x1B\x1C and congratulations on your file.\n" > test2.txt
echo -e "no matches\t\t\ here\n\n\nthis is safe\n" > test3.txt
echo -e "" > test4.txt

function run_test {
    local flags="$1"
    shift
    local files=("$@")
    
    echo "Запуск теста: cat $flags ${files[*]}"
    if diff <(cat $flags "${files[@]}") <(./s21_cat $flags "${files[@]}");
    then 
        (( SUCCESS++ ))
    else
        (( FAIL++ ))
        echo "-----------------------------"
    fi
}

function check_memory_leaks {
    local flags="$1"
    shift
    local files=("$@")
    
    valgrind --leak-check=full --track-origins=yes --error-exitcode=1 ./s21_cat $flags "${files[@]}" &> valgrind_output.txt
    
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
run_test "-b" "test1.txt" "test2.txt" "test4.txt"
run_test "--number-nonblank" "test2.txt" "test3.txt"
run_test "-e" "test1.txt" "test2.txt" "test3.txt"
run_test "-n" "test2.txt" "test3.txt"
run_test "--number" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
run_test "-s" "test1.txt" "test2.txt" "test3.txt"
run_test "--squeeze-blank" "test1.txt" "test2.txt"
run_test "-t" "test2.txt" "test3.txt" "test4.txt"
run_test "-T" "test1.txt" "test2.txt" "test3.txt"
run_test "-E" "test2.txt" "test3.txt" "test4.txt"
run_test "-b" "test1.txt" "test2.txt" "test3.txt"
run_test "-s" "test1.txt" "test2.txt" "test3.txt"
run_test "-b" "test1.txt" "test2.txt" "test3.txt" "test5.txt"
run_test "test5.txt"
# Пример тестирования с несколькими флагами
run_test "-b -t" "test1.txt" "test2.txt" "test4.txt"
run_test "-T -E" "test1.txt" "test2.txt" "test3.txt"
run_test "--number-nonblank --squeeze-blank" "test2.txt" "test3.txt"
run_test "--number-nonblank -E -T" "test1.txt" "test2.txt" "test3.txt"
run_test "-e -n" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
run_test "-b -e" "test1.txt" "test2.txt"
run_test "--number-nonblank --squeeze-blank" "test2.txt" "test3.txt"
run_test "-E --number-nonblank" "test2.txt" "test3.txt"
run_test "-t -b" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
# # Тестирование на утечки
check_memory_leaks "-b" "test1.txt" "test2.txt" "test4.txt"
check_memory_leaks "--number-nonblank" "test2.txt" "test3.txt"
check_memory_leaks "-e" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "-n" "test2.txt" "test3.txt"
check_memory_leaks "--number" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
check_memory_leaks "-s" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "--squeeze-blank" "test1.txt" "test2.txt"
check_memory_leaks "-t" "test2.txt" "test3.txt" "test4.txt"
check_memory_leaks "-T" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "-E" "test2.txt" "test3.txt" "test4.txt"
check_memory_leaks "-b" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "-s" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "-b -t" "test1.txt" "test2.txt" "test4.txt"
check_memory_leaks "-T -E" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "--number-nonblank --squeeze-blank" "test2.txt" "test3.txt"
check_memory_leaks "--number-nonblank -E -T" "test1.txt" "test2.txt" "test3.txt"
check_memory_leaks "-e -n" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
check_memory_leaks "-b -e" "test1.txt" "test2.txt"
check_memory_leaks "--number-nonblank --squeeze-blank" "test2.txt" "test3.txt"
check_memory_leaks "-E --number-nonblank" "test2.txt" "test3.txt"
check_memory_leaks "-t -b" "test1.txt" "test2.txt" "test3.txt" "test4.txt"
# Не передан флаг
check_memory_leaks "test1.txt" "test2.txt" "test4.txt"
# Не существующий флаг
check_memory_leaks "-p" "test2.txt"
# Не существующий файл
check_memory_leaks "-e" "test5.txt"

rm test1.txt test2.txt test3.txt test4.txt valgrind_output.txt

echo "Успешные тесты: $SUCCESS"
echo "Неуспешные тесты: $FAIL"
echo "Успешные тесты на утечки: $LEAKTESTSUCCESS"
echo "Неуспешные тесты на утечки: $LEAK"

if [ "$FAIL" -ne 0 ] || [ "$LEAK" -ne 0 ]; then
    exit 1
fi
exit 0
