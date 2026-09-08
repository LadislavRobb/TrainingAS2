
TYPE
	DiagType : {REDUND_UNREPLICABLE} 	STRUCT  (*Diagnostics structure*)
		cnt_memoryLost : {REDUND_UNREPLICABLE} UDINT;
		cntLoad : {REDUND_UNREPLICABLE} UDINT;
		cntSave : {REDUND_UNREPLICABLE} UDINT;
		cntError : {REDUND_UNREPLICABLE} UDINT;
		cntErrorReset : {REDUND_UNREPLICABLE} UDINT;
		cntDetection : {REDUND_UNREPLICABLE} UDINT; (*Change detection counter*)
		cntDetectionIni : {REDUND_UNREPLICABLE} UDINT;
	END_STRUCT;
END_TYPE

(* *)
(*Change detection structure*)
(**********************************)

TYPE
	CfgChangeDetectionType : {REDUND_UNREPLICABLE} 	STRUCT  (*Change detection structure / storing adresses and sizes of configurations elements*)
		actStructureAdr : {REDUND_UNREPLICABLE} UDINT; (*Adress of actual config structure*)
		size : {REDUND_UNREPLICABLE} UDINT; (*Cfg structure size*)
		savedStructureAdr : {REDUND_UNREPLICABLE} UDINT; (*Data adress of saved, state of config structure for comparing*)
	END_STRUCT;
END_TYPE
