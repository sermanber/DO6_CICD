#include "s21_cat.h"

int main(int argc, char **argv) {
  int num_non_blank = 0, usd_simb_end = 0, num_all = 0, squeeze_blank = 0,
      shows_tabs = 0, shows_tabs_wov = 0, usd_simb_end_wov = 0;
  int num_str = 1;

  int rez;
  int option_index;
  const char *short_options = "benstET";

  const struct option long_options[] = {
      {"number-nonblank", no_argument, NULL, 'b'},
      {"number", no_argument, NULL, 'n'},
      {"squeeze-blank", no_argument, NULL, 's'},
      {NULL, 0, NULL, 0}};
  while ((rez = getopt_long(argc, argv, short_options, long_options,
                            &option_index)) != -1) {
    switch (rez) {
      case 'b':
        num_non_blank = 1;
        break;
      case 'e':
        usd_simb_end = 1;
        break;
      case 'n':
        num_all = 1;
        break;
      case 's':
        squeeze_blank = 1;
        break;
      case 't':
        shows_tabs = 1;
        break;
      case 'E':
        usd_simb_end_wov = 1;
        break;
      case 'T':
        shows_tabs_wov = 1;
        break;
      case '?':
        shows_tabs_wov = 1;
        break;
    }
  }
  for (int i = optind; i < argc; i++) {
    num_str =
        print_file(argv[i], num_non_blank, usd_simb_end, num_all, squeeze_blank,
                   shows_tabs, num_str, shows_tabs_wov, usd_simb_end_wov);
  }
  return 0;
}

int print_file(char *file, int num_non_blank, int usd_simb_end, int num_all,
               int squeeze_blank, int shows_tabs, int num_str,
               int shows_tabs_wov, int usd_simb_end_wov) {
  FILE *f = fopen(file, "rt");
  char previos = '\n';
  char pre_previos = 0;
  int flag = 1;

  if (f != NULL) {
    int c = fgetc(f);
    while (c != EOF) {
      if (num_non_blank && previos == '\n' && c != previos) {
        printf("%6d	", num_str++);
      }
      if (num_all && previos == '\n') {
        printf("%6d	", num_str++);
      }
      if (shows_tabs) {
        flag = (print_visible(c, usd_simb_end, shows_tabs));
      }
      if (shows_tabs_wov && c == '\t') {
        printf("^I");
        flag = 0;
      }
      if (squeeze_blank && c == '\n' && previos == '\n' &&
          pre_previos == '\n') {
        flag = 0;
      }
      if (usd_simb_end) {
        flag = (print_visible(c, usd_simb_end, shows_tabs));
      }
      if (usd_simb_end_wov && c == '\n') {
        printf("$%c", c);
      } else if (flag) {
        putchar(c);
      }
      flag = 1;
      pre_previos = previos;
      previos = c;
      c = fgetc(f);
    }
    fclose(f);
  } else {
    perror("Ошибка открытия файла");
  }
  return num_str;
}

int print_visible(char c, int usd_simb_end, int shows_tabs) {
  int flag = 0;
  if (c >= 0 && c < 32 && c != 9 && c != 10) {
    printf("^%c", c + 64);
  } else if (c == 127) {
    printf("^?");
  } else if (c == '\n' && usd_simb_end) {
    printf("$\n");
  } else if (c == '\t' && shows_tabs) {
    printf("^I");
  } else {
    flag = 1;
  }
  return flag;
}
