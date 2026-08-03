
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Fals ActiveCmd input to FALSE */
plcbit FallActiveCmd(plcbit* pCommand, plcbit* pActiveCmd)
{
	// declare local variables
	BOOL command_written;
	
	// function body
	if (*pCommand) {
		*pCommand = 0;
		*pActiveCmd = 0;
		
		command_written = 1;
	} else {
		command_written = 0;
	}
	
	// return value
	return command_written;
}
