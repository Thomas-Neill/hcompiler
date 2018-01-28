#include <stdio.h>
int* hask__main();
void alloc_init();
void alloc_done();
void alloc_push();
void alloc_pop_except(void* what);
int main() {
  alloc_init();
  alloc_push();
  printf("Your program sez: %d\n",*hask__main());
  alloc_pop_except(NULL);
  alloc_done();
}
