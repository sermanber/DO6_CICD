#include "s21_grep.h"

void search_file(char *str, char *filename, int template_e, int regi_i,
                 int invert_v, int coincidence_с, int coin_f_l, int numstr_n) {
  int flag = 1, match_str = 0, flag_file = 0, line_number = 0,
      compil_flag = REG_EXTENDED;
  char buffer[BUFFER_SIZE];
  regex_t regex;

  FILE *file = fopen(filename, "rt");
  if (!file) {
    printf("Ошибка открытия файла\n");
    exit(EXIT_FAILURE);
  }
  if (regi_i) {
    compil_flag = REG_ICASE;
  }
  if (regcomp(&regex, str, compil_flag) != 0 && template_e && flag) {
    fprintf(stderr, "Регулярное выражение не скомпилировалось\n");
    flag = 0;
  }
  while (fgets(buffer, BUFFER_SIZE, file) && flag) {
    line_number++;
    regmatch_t matches[1];
    if (regexec(&regex, buffer, 1, matches, 0) != 0 && invert_v) {
      printf("%s", buffer);
    } else if (regexec(&regex, buffer, 1, matches, 0) == 0) {
      flag_file++;
      if (numstr_n) {
        printf("%d:%s", line_number, buffer);
      }
      if (coincidence_с) {
        match_str++;
      }
      if (template_e || regi_i) {
        printf("%s", buffer);
      }
    }
  }
  if (coincidence_с && flag) {
    printf("%d\n", match_str);
  }
  if (flag_file && coin_f_l && flag) {
    printf("%s\n", filename);
  }
  regfree(&regex);
  fclose(file);
}

void search_files(char *str, char *filename, int template_e, int regi_i,
                  int invert_v, int coincidence_с, int coin_f_l, int numstr_n) {
  int flag = 1, match_str = 0, flag_file = 0, line_number = 0,
      compil_flag = REG_EXTENDED;
  char buffer[BUFFER_SIZE];
  regex_t regex;

  FILE *file = fopen(filename, "rt");
  if (!file) {
    printf("Ошибка открытия файла\n");
    exit(EXIT_FAILURE);
  }
  if (regi_i) {
    compil_flag = REG_ICASE;
  }
  if (regcomp(&regex, str, compil_flag) != 0 && template_e && flag) {
    fprintf(stderr, "Регулярное выражение не скомпилировалось\n");
    flag = 0;
  }
  while (fgets(buffer, BUFFER_SIZE, file) && flag) {
    line_number++;
    regmatch_t matches[1];
    if (regexec(&regex, buffer, 1, matches, 0) != 0 && invert_v) {
      printf("%s:%s", filename, buffer);
    } else if (regexec(&regex, buffer, 1, matches, 0) == 0) {
      flag_file++;
      if (numstr_n) {
        printf("%s:%d:%s", filename, line_number, buffer);
      }
      if (coincidence_с) {
        match_str++;
      }
      if (template_e || regi_i) {
        printf("%s:%s", filename, buffer);
      }
    }
  }
  if (coincidence_с && flag) {
    printf("%s:%d\n", filename, match_str);
  }
  if (flag_file && coin_f_l && flag) {
    printf("%s\n", filename);
  }
  regfree(&regex);
  fclose(file);
}

int main(int argc, char **argv) {
  int template_e = 0, regi_i = 0, invert_v = 0, coincidence_с = 0, coin_f_l = 0,
      numstr_n = 0, flag = 1, rez = 0;
  char *str = NULL, *filename = NULL;

  while ((rez = getopt(argc, argv, "e:i:v:c:l:n:")) != -1) {
    str = optarg;
    switch (rez) {
      case 'e':
        template_e = 1;
        break;
      case 'i':
        regi_i = 1;
        break;
      case 'v':
        invert_v = 1;
        break;
      case 'c':
        coincidence_с = 1;
        break;
      case 'l':
        coin_f_l = 1;
        break;
      case 'n':
        numstr_n = 1;
        break;
      case '?':
        flag = 0;
        printf("Неизвестный флаг\n");
        break;
    }
  }
  if (!str) {
    printf("Шаблон не передан\n");
    flag = 0;
  }
  if (flag) {
    if (optind + 1 == argc) {
      filename = argv[optind];
      search_file(str, filename, template_e, regi_i, invert_v, coincidence_с,
                  coin_f_l, numstr_n);
    } else {
      for (int i = optind; i < argc; i++) {
        filename = argv[i];
        search_files(str, filename, template_e, regi_i, invert_v, coincidence_с,
                     coin_f_l, numstr_n);
      }
    }
  } else {
    printf("Нет такого файла или каталога\n");
  }
  return 0;
}
