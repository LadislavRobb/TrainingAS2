
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Rises command output to TRUE if rising edge is detected */
plcbit RisingSetCmd(plcbit* pCommand, plcbit* pCommandOut, plcbit* pEdgeVar)
{
	// declare local variables
	BOOL command_written;
	
	// function body
	if ((*pCommand) && (!*pEdgeVar)) {
		*pEdgeVar = 1;
		*pCommandOut = 1;
		
		command_written = 1;
	} else {
		if (!*pCommand) {
			*pEdgeVar = 0;
		}
		
		command_written = 0;
	}

	
	// return value
	return command_written;
}
