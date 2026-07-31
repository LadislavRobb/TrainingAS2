
#include <bur/plctypes.h>

#ifdef _DEFAULT_INCLUDES
#include <AsDefault.h>
#endif

void _CYCLIC ProgramCyclic(void)
{

	i++;
	if (i > 160) {
		DO1 = !DO1;
		i = 0;
	}	
	
	if (timerFB.Q) {
		timerFB.IN = 0;
		DO2 = !DO2;
	}	
	TON(&timerFB);
	timerFB.IN = 1;

}
