(*HzLogger datatypes*)
(*******************************)

TYPE
	HzLogWriteInternalType : {REDUND_UNREPLICABLE} 	STRUCT 
		eventLogWrite_FB : {REDUND_UNREPLICABLE} ArEventLogWrite; (*FB instance*)
		stringLength : {REDUND_UNREPLICABLE} UDINT; (*Length of input string*)
		tempStringComplete : {REDUND_UNREPLICABLE} STRING[hzlogLOGGER_STRING_LEN]; (*Temporary  string *)
		tempStringValue : {REDUND_UNREPLICABLE} STRING[hzlogLOGGER_STRING_LEN]; (*Temporary  string *)
	END_STRUCT;
END_TYPE
