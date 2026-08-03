(*General state functions*)

{REDUND_ERROR} FUNCTION HzAuxStateMonTimeout : BOOL (*Monitors state timeouts*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enabling function*)
		Time : TIME; (*Monitoring time if the time is over -> Output is true*)
		pTimer : TON; (*Pointer to used local TON timer *)
	END_VAR
END_FUNCTION
(*String operation File name generator*)

{REDUND_OK} FUNCTION HzAuxDateTimeS : UINT (*Generates date and time string in special format*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		OutString : STRING[hzauxSIZE_STRING_DEFAULT]; (*Output string *)
	END_VAR
END_FUNCTION

{REDUND_OK} FUNCTION HzAuxVal2String : UINT (*Conversion value into string in specific format*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		InOutString : STRING[hzauxSIZE_STRING_DEFAULT]; (*Output string where the generated string is added*)
		Value : DINT; (*Int value for conversion*)
		Format : UINT; (*Format 0 the raw value,  >=1 fill string with 0 to this defined size*)
	END_VAR
END_FUNCTION

{REDUND_OK} FUNCTION HzAuxImgFileNameS : UINT (*Generates Image file name*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		InOutString : STRING[hzauxSIZE_STRING_DEFAULT]; (*Output string where the generated string is added*)
		FileExtension : STRING[hzauxSIZE_STRING_DEFAULT]; (*File extension, adds into file name.*)
		Value : DINT; (*In case empty file name, is this number used for filename*)
	END_VAR
END_FUNCTION
(**)
(*Auxiliary safety string operations*)

{REDUND_ERROR} FUNCTION HzAuxStr_Cpy : UDINT (*Copy string into string buffer (safe)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Destignation string, is overwritten*)
		SizeDestString : UDINT; (*Size of target  string*)
		pSource : STRING[80]; (*Source string which is copied into dest string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Cat : UDINT (*Append string to string buffer (safe)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*String where function adds at the end*)
		SizeDestString : UDINT; (*Size of target  string*)
		pSource : STRING[80]; (*This string is addes at the end of  desc string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Cat_Float : UDINT (*Append float value  to string buffer (safe)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*String where function adds at the end*)
		SizeDestString : UDINT; (*Size of target  string*)
		Value : REAL; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Cat_Int : UDINT (*Append Int value  to string buffer (safe)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*String where function adds at the end*)
		SizeDestString : UDINT; (*Size of target  string*)
		Value : DINT; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Gen_AddTxtFloat : UDINT (*Generates string in format Text +  value, Ads text to the original string*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Target string*)
		SizeDestString : UDINT; (*Size of target  string*)
		pText : STRING[80]; (*Text copied to Target string *)
		Value : REAL; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Gen_AddTxtInt : UDINT (*Generates string in format Text+ value Ads text to the original string
*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Target string*)
		SizeDestString : UDINT; (*Size of target  string*)
		pText : STRING[80]; (*Text copied to Target string *)
		Value : DINT; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Gen_AddTxtFloatSvg : UDINT (*Generates string in format Text +  value, Ads text to the original string in SVG format *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Target string*)
		SizeDestString : UDINT; (*Size of target  string*)
		pText : STRING[80]; (*Text copied to Target string *)
		Value : REAL; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Gen_AddTxtIntSvg : UDINT (*Generates string in format Text+ value Ads text to the original string in SVG format
*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Target string*)
		SizeDestString : UDINT; (*Size of target  string*)
		pText : STRING[80]; (*Text copied to Target string *)
		Value : DINT; (*Value for conversion to string*)
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION HzAuxStr_Gen_AddTxtAsParSvg : UDINT (*Generates string in format Text+ value Ads text to the original string in SVG format
*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pDest : STRING[80]; (*Target string*)
		SizeDestString : UDINT; (*Size of target  string*)
		pText : STRING[80]; (*Text copied to Target string *)
		pTextPar : STRING[80]; (*Text copied to Target string like parameter*)
	END_VAR
END_FUNCTION
(**)
(*Conversion function*)

FUNCTION HzAngleConvertor0_360 : REAL (*Conversion multiturn angle to one revolut 0-360*)
	VAR_INPUT
		InAngle : REAL;
	END_VAR
END_FUNCTION

FUNCTION HzAngleConvertorDINT : DINT (*Conversion multiturn angle to plus/minus one revolution -360 ..+360 degre * 1000.*)
	VAR_INPUT
		InAngle : REAL;
	END_VAR
END_FUNCTION
