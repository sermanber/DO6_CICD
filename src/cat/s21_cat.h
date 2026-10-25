#ifndef S21_CAT_H
#define S21_CAT_H

#define _GNU_SOURCE
#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int print_file(char *file, int num_non_blank, int usd_simb_end, int num_all,
               int squeeze_blank, int shows_tabs, int num_str,
               int shows_tabs_wov, int usd_simb_end_wov);
int print_visible(char c, int usd_simb_end, int shows_tabs);

#endif