#include <math.h>
#include <stdlib.h>
#include <stdio.h>
float sine(float x) {
  return sinf(x);
}

int printb(char c) {
  if(c) {
    printf("True!\n");
  } else {
    printf("False :)\n");
  }
  return 0;
}
