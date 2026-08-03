
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Check range of variable */
plcbit ValueRange(unsigned short LowBound, unsigned short UpBound, unsigned short* pVar)
{
	// declare local variables
	
	
	// function body
	if (UpBound > LowBound) {
		if (*pVar > UpBound) {
			*pVar = UpBound;
			return 1;
		} else if (*pVar < LowBound) {
			*pVar = LowBound;
			return 1;
		} 
	}
	return 0;


	

}
