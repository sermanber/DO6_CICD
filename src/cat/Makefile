FLAG = -Wall -Werror -Wextra -std=c11

all: s21_cat

s21_cat: clean
	gcc $(FLAG) s21_cat.c -o s21_cat
	
test:
	bash test_cat.sh

clean:
	rm -f s21_cat
	-clear