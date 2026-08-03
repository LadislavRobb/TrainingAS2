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
 
#define ONE_ROTATION_360 360000
#define ANGLE_RESOLUTION 1000

/**************************************************************************************
* FBName: HzAngleConvertor0_360                                         
* @brief Conversion multiturn angle value into angle one revolut range 0-360
*                                                                                         
*
* @param InAngle        input angle (real)
* @return               output angle (real)
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
float HzAngleConvertor0_360(float InAngle) {
	DINT tempAngle;
	
	tempAngle = (DINT) (InAngle * ANGLE_RESOLUTION);
	tempAngle = tempAngle % ONE_ROTATION_360;
	if (tempAngle < 0) {
		tempAngle += ONE_ROTATION_360;
	}	
	return( ((float)tempAngle)/ANGLE_RESOLUTION);
} // end HzAuxVal2String()

/**************************************************************************************
* FBName: HzAngleConvertorDINT                                        
* @brief Conversion multiturn angle value into angle +-one revolut range -360..360 
* In DINT format it means +-360 000 deg. (1 deg is 1000)
*
* @param InAngle        input angle (real)
* @return               output angle * 1000 (DINT)
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
DINT HzAngleConvertorDINT(float InAngle) {
	DINT tempAngle;
	
	tempAngle = (DINT) (InAngle * ANGLE_RESOLUTION);
	tempAngle = tempAngle % ONE_ROTATION_360;
	return(tempAngle);
} // end HzAuxVal2String()

