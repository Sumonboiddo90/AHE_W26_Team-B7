#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define GPIO_BASE 0x40000000   /* AXI GPIO: replace with your address */
#define DIN       0x00         /* ch 2 data (outputs): to the reconfigurable module   */
#define DOUT      0x08         /* ch 1 data (inputs):  from the reconfigurable module */

static const char *identify(void)
{
  Xil_Out32(GPIO_BASE + DIN, 0x0001);
  usleep(100);
  u32 r = Xil_In32(GPIO_BASE + DOUT) & 0xFFFF;
  if (r == 0x0001) return "RM A (pass-through)";
  if (r == 0xFFFE) return "RM B (invert)";
  if (r == 0x0100) return "RM C (swap bytes)";
  return "unknown";
}

int main(void)
{
  u16 cnt = 0;
  while (1) {
    const char *name = identify();
    Xil_Out32(GPIO_BASE + DIN, cnt);
    usleep(1000);
    u32 out = Xil_In32(GPIO_BASE + DOUT) & 0xFFFF;
    xil_printf("loaded: %s   in=%04x out=%04x\r\n", name, cnt, out);
    cnt++;
    usleep(250000);
  }
}