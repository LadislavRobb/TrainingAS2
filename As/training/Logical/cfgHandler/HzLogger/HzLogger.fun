
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK HzLogWrite (*Single write to user log*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Ident : {REDUND_UNREPLICABLE} ArEventLogIdentType; (*Ident of user logger*)
		Severity : {REDUND_UNREPLICABLE} USINT; (*Event ID*)
		Facility : {REDUND_UNREPLICABLE} UINT; (*Event ID*)
		ErrorCode : {REDUND_UNREPLICABLE} UINT; (*Event ID*)
		CompleteID : {REDUND_UNREPLICABLE} DINT; (*Alternative complete EventID, if it is zero FB uses separate IDs params.*)
		CreatorName : {REDUND_UNREPLICABLE} STRING[36]; (*ObjectID creator string , zero it will be determined by AR*)
		AdditionalDataString : {REDUND_UNREPLICABLE} STRING[hzlogLOGGER_STRING_LEN]; (*Additonal data string put here user data*)
	END_VAR
	VAR_OUTPUT
		Done : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		StatusID : {REDUND_UNREPLICABLE} DINT;
	END_VAR
	VAR
		Internal : {REDUND_UNREPLICABLE} HzLogWriteInternalType; (*Internal FB data*)
	END_VAR
END_FUNCTION_BLOCK
