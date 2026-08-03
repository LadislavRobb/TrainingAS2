
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
#include "CheckLib.h"
#ifdef __cplusplus
	};
#endif

#include <string.h>

typedef enum  
{
	stateTimeout_ST_IDLE,
	stateTimeout_ST_WRITE_PAR,
	stateTimeout_ST_EVALUATION,
	stateTimeout_ST_TIMEOUT_REACHED,
}StateTimeoutStatesEnum;

typedef struct
{
	TON_typ TimerOn;
}StateTimeoutHiddenFbType;

typedef struct 
{
	StateTimeoutHiddenFbType Fb;
	unsigned long StateOld;
	StateTimeoutStatesEnum State;
} StateTimeoutHiddenInternalType;

enum ErrorStatusIdEnum 
{
	NOT_ENOUGHT_ALLOCATED_MEMORY = 111111,
	EMPTY_INTERNAL_POINTER = 111112,
};

/* TODO: Add your comment here */
void StateTimeOut(struct StateTimeOut* inst)
{
	if (inst->Enable)
	{
		inst->Internal.InternalDataLen = sizeof(StateTimeoutHiddenInternalType);
		inst->StatusID = 0;
		
		if (sizeof(inst->Internal.InternalMem) < inst->Internal.InternalDataLen)
		{
			inst->Error = 1;
			inst->StatusID = NOT_ENOUGHT_ALLOCATED_MEMORY;
			return;	
		}
		
		StateTimeoutHiddenInternalType* pLocal = (StateTimeoutHiddenInternalType*) &inst->Internal.InternalMem;
		StateTimeoutHiddenFbType* pFb = &pLocal->Fb;
		
		if ((pLocal == NULL) || (pFb == NULL))
		{
			inst->Error = 1;
			inst->StatusID = EMPTY_INTERNAL_POINTER;
			return;
		}
		
		pFb->TimerOn.IN = 0;
		
		const unsigned int DEFAULT_TIMEOUT = 5000;
		
		/**********************************************************/
		/* */
		/**********************************************************/
		switch (pLocal->State)
		{
			/*************** STATE ***************/
			case stateTimeout_ST_IDLE:
				
				if (inst->StartCheck)
				{
					inst->StartCheck = 0;
					inst->TimeOutReached = 0;
					inst->StateTransitionendInTime = 0;
					pLocal->StateOld = inst->State;
					pLocal->State = stateTimeout_ST_WRITE_PAR;
				}
				
				break;
			
			/*************** STATE ***************/
			case stateTimeout_ST_WRITE_PAR:
								
				if (inst->TimeOut == 0)
				{
					pFb->TimerOn.PT = DEFAULT_TIMEOUT;

				}
				else 
				{
					pFb->TimerOn.PT = inst->TimeOut; 
				}
				
				pLocal->State = stateTimeout_ST_EVALUATION;
				
				break;
			
			/*************** STATE ***************/
			case stateTimeout_ST_EVALUATION:
				
				pFb->TimerOn.IN = 1;
				
				if ((inst->State != pLocal->StateOld) && (!pFb->TimerOn.Q))
				{
					pLocal->StateOld = inst->State;
					inst->TimeOutReached = 0;
					inst->StateTransitionendInTime = 1;
					pLocal->State = stateTimeout_ST_IDLE;
				}
				else if(pFb->TimerOn.Q)
				{
					inst->StateTransitionendInTime = 0;
					pLocal->State = stateTimeout_ST_TIMEOUT_REACHED;
				}
				
				break;
			
			/*************** STATE ***************/
			case stateTimeout_ST_TIMEOUT_REACHED:
				
				inst->TimeOutReached = 1;
				pLocal->State = stateTimeout_ST_IDLE;
				
				break;
		}
		/*************** SEQUENCE END ***************/
		
		/* call fubs */
		TON(&pFb->TimerOn);
		/* write status */
		inst->Internal.State = (UINT)pLocal->State;
	}
	else
	{
		inst->Error = 0;
		inst->StatusID = 0;
		inst->StartCheck = 0;
		inst->TimeOutReached = 0;
		inst->StateTransitionendInTime = 0;
	}
}
