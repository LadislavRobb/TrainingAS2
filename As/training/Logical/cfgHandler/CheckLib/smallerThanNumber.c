
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Add your comment here */
plcbit smallerThanNumber(signed short num_to_check, signed short border)
{
	return	(num_to_check <= border);
}
