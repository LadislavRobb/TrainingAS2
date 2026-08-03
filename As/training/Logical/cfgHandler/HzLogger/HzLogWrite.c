
#include <bur/plctypes.h>
#include <string.h>

#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "HzLogger.h"
#ifdef __cplusplus
	};
#endif

/**************************************************************************************
* FBName: HzLogWrite                                         
* @brief FB Write event to user logger
*                                                                                         
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************//* TODO: Add your comment here */
void HzLogWrite(struct HzLogWrite* inst) {
	// global off diagnostic writing to logger 
	if (!hzlogDEBUG_MODE_ON) {
		inst->Done = 1;
		inst->Error = 0;
		inst->StatusID = 0;
		return;
	}	
	
	// preparing entry data 
	inst->Internal.eventLogWrite_FB.Execute = 1;
	inst->Internal.eventLogWrite_FB.Ident = inst->Ident;

	if (inst->CompleteID != 0) {
		// use CompleteID parameter for eventID 
		inst->Internal.eventLogWrite_FB.EventID = inst->CompleteID;
	} else {
		// use Severity,Facility, ErrorCode for eventID
		inst->Internal.eventLogWrite_FB.EventID = ArEventLogMakeEventID(inst->Severity, inst->Facility, inst->ErrorCode);
	}
	
	inst->Internal.eventLogWrite_FB.RecordID = 0;
	inst->Internal.stringLength = strlen(inst->AdditionalDataString);
	inst->Internal.eventLogWrite_FB.AddDataSize = inst->Internal.stringLength + 1; 
	inst->Internal.eventLogWrite_FB.AddDataFormat = arEVENTLOG_ADDFORMAT_TEXT; 	
	inst->Internal.eventLogWrite_FB.AddData = (UDINT)inst->AdditionalDataString;
	HzAuxStr_Cpy(inst->Internal.eventLogWrite_FB.ObjectID,sizeof(inst->Internal.eventLogWrite_FB.ObjectID),inst->CreatorName);
	
	// writing 
	ArEventLogWrite(&inst->Internal.eventLogWrite_FB);
	
	// output 
	inst->Done = inst->Internal.eventLogWrite_FB.Done;
	inst->Error = inst->Internal.eventLogWrite_FB.Error;
	inst->StatusID = inst->Internal.eventLogWrite_FB.StatusID;

	// reseting Fb instance 
	inst->Internal.eventLogWrite_FB.Execute = 0;
	ArEventLogWrite(&inst->Internal.eventLogWrite_FB);
} // end HzLogWrite()
