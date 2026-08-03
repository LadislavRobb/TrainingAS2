
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "HeinzAux.h"
#ifdef __cplusplus
	};
#endif
#include <string.h>

/* Monitors state timeouts */
/**************************************************************************************
* FBName: HzAuxStateMonTimeout(plcbit Enable, plctime Time, struct TON* pTimer )                                   
* @brief Monitors state timeouts
*                                                                                         
*
* @param Time        input monitoring time (TIME)
* @param pTimer      input pointer to external timer TON
* @return            output BOOL monitoring time exceeded
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
plcbit HzAuxStateMonTimeout(plcbit Enable, plctime Time, struct TON* pTimer ) {
	if (!Enable) return(0);
	if (pTimer == NULL) return(0); 	
	pTimer->PT = Time;
	return(pTimer->Q);
}
