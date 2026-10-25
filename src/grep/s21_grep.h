#ifndef S21_GREP_H
#define S21_GREP_H

#include <getopt.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUFFER_SIZE 1024

void search_file(char *str, char *filename, int template_e, int regi_i,
                 int invert_v, int coincidence_с, int coin_f_l, int numstr_n);
void search_files(char *str, char *filename, int template_e, int regi_i,
                  int invert_v, int coincidence_с, int coin_f_l, int numstr_n);

#endif