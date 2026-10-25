FLAG = -Wall -Werror -Wextra -std=c11

all: s21_grep

s21_grep: clean
	gcc $(FLAG) s21_grep.c -o s21_grep
	
test:
	bash test_grep.sh

clean:
	rm -f s21_grep
	-clear