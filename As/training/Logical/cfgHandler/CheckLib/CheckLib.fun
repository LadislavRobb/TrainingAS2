
{REDUND_ERROR} FUNCTION RiseActiveCmd : BOOL (*TODO: Rise ActiveCmd input to TRUE*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pActiveCmd : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION FallActiveCmd : BOOL (*TODO: Fall ActiveCmd input to FALSE*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pActiveCmd : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION RisingSetCmd : BOOL (*TODO: Rises command input to TRUE if rising edge detected*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pCommandOut : BOOL;
		pEdgeVar : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION FallingSetCmd : BOOL (*TODO: Rises command input to TRUE if rising edge detected*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pCommandOut : BOOL;
		pEdgeVar : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION ValueRange : BOOL (*TODO: Check range of variable*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		LowBound : UINT;
		UpBound : UINT;
	END_VAR
	VAR_IN_OUT
		pVar : UINT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION RisingEdgeNeg : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pCommandOut : BOOL;
		pEdgeVar : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION FallingEdgeNeg : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_IN_OUT
		pCommand : BOOL;
		pCommandOut : BOOL;
		pEdgeVar : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION biggerThanNumber : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		num_to_check : INT;
		border : INT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION smallerThanNumber : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		num_to_check : INT;
		border : INT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION_BLOCK StateTimeOut (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL;
		StartCheck : BOOL;
		TimeOut : UINT; (*[ms], default value 5s*)
		State : UINT;
	END_VAR
	VAR_OUTPUT
		Error : BOOL;
		StateTransitionendInTime : BOOL; (*State changed in time*)
		TimeOutReached : BOOL; (*State was not changed in time*)
		StatusID : UDINT;
	END_VAR
	VAR
		Internal : StateTimeoutInternalType;
	END_VAR
END_FUNCTION_BLOCK
