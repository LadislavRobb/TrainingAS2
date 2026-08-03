
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Rises ActiveCmd input to TRUE */
plcbit RiseActiveCmd(plcbit* pCommand, plcbit* pActiveCmd)
{
	// declare local variables
	BOOL command_written;
	
	// function body
	if (*pCommand) {
		*pCommand = 0;
		*pActiveCmd = 1;
		
		command_written = 1;
	} else {
		command_written = 0;
	}
	
	// return value
	return command_written;
}
