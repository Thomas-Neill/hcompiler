#include <stdio.h>
int* go();
void alloc_init();
void alloc_done();
void alloc_push();
void alloc_pop_except(void* what);
int main() {
  alloc_init();
  alloc_push();
  printf("Your program sez: %d\n",*go());
  alloc_pop_except(NULL);
  alloc_done();
}
