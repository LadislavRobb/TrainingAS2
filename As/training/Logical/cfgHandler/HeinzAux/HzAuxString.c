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
 

/**************************************************************************************
* FBName: HzAuxVal2String                                         
* @brief Conversion value into string in specific format
*                                                                                         
* Converts DINT value to the string and add it to the end of input string
* Also is possible to format it with additional zeroes, to have constans string  
* size.
*
* @param InOutString	input/string where generated value string is added
* @param Value          input numeric value
* @param Format         input Format ( 0 without formatting, >1 number of value digits
* @return               0 error typically pointers or size problem 
*                       >= 1 lenght of final string
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
unsigned short HzAuxVal2String(plcstring* InOutString, signed long Value, unsigned short Format) {
	plcstring tempS[hzauxSIZE_STRING_DEFAULT];  // temporary string
	UINT lenghtValue;
	UINT lenghtInOutString;
	UINT lenghtZeroFill;
	UINT lenghtComplete;
	UINT retVal;
	
	// input par checker
	if (InOutString == NULL) return(0); 	
	ValueRange(0,hzauxSTRING_FORMAT_MAX, &Format);
	
	// size of input string
	lenghtInOutString = (UINT )brsstrlen((UDINT)InOutString);  
	
	// conversion value to string
	tempS[0] = 0; // clear string
	lenghtValue = brsitoa(Value,(UDINT)tempS); 
	
	// formatting a and final assigment
	if (Format == hzauxSTRING_FORMAT_NONE) {
		// without adding zero, pure value format
		lenghtComplete = lenghtInOutString + lenghtValue;
		if ( lenghtComplete < hzauxSIZE_STRING_DEFAULT) {
			brsstrcat((UDINT)InOutString,(UDINT)tempS);  // adds value string
			retVal = lenghtComplete;
		} else {
			// Err size overflow 
			retVal = 0;
		}	
	} else {
		// filling zeroes
		if (Format > lenghtValue ) lenghtZeroFill = Format - lenghtValue;
		else                       lenghtZeroFill = 0;
		ValueRange(0,hzauxSTRING_FORMAT_MAX - 1, &lenghtZeroFill);  // Limitation
			
		// check size
		lenghtComplete = lenghtInOutString + lenghtValue + lenghtZeroFill;
		if ( lenghtComplete < hzauxSIZE_STRING_DEFAULT) {
			// to fill zeroes
			while (lenghtZeroFill > 0) {
				brsstrcat((UDINT)InOutString,(UDINT)"0");
				lenghtZeroFill--;
			}	
			brsstrcat((UDINT)InOutString,(UDINT)tempS);  // adds value string
			retVal = lenghtComplete;
		} else {
			// Err size overflow 
			retVal = 0;
		}	
	} // end filling zeroes	
	return(retVal);
} // end HzAuxVal2String()


/******************************************************************************************
* FBName: HzAuxDateTimeS                                        
* @brief Generate date and time string in format yearMonthDay_hourMinuteSecond_milisecond
*                                                                                         
* Sample: 20260223_190721_634
*
* @param IOutString 	input/string where is generated string stored
* @return               0 error typically pointers or size problem 
*                       >= 1 lenght of final string
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                       
***************************************************************************************/
unsigned short HzAuxDateTimeS(plcstring* OutString) {
	struct DTStructureGetTime DTStructureGetTime_FB;
	DTStructure dateTime;
	unsigned short retVal;
	BOOL errorFlag = 0;
	
	
	// reading current time
	DTStructureGetTime_FB.enable = 1;
	DTStructureGetTime_FB.pDTStructure = (UDINT)&dateTime;
	DTStructureGetTime(&DTStructureGetTime_FB);
		
	if ((DTStructureGetTime_FB.status == ERR_OK) && (OutString != NULL)) {
		// OK
		OutString[0] = 0;  // clear string
		retVal = 0;
		// generation time/date string in dedicated format
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.year,hzauxSTRING_FORMAT_NONE);
		if (retVal == 0) errorFlag = 1;
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.month,hzauxSTRING_FORMAT_2DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.day,hzauxSTRING_FORMAT_2DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		brsstrcat((UDINT)OutString,(UDINT)"_");
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.hour,hzauxSTRING_FORMAT_2DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.minute,hzauxSTRING_FORMAT_2DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.second,hzauxSTRING_FORMAT_2DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		brsstrcat((UDINT)OutString,(UDINT)"_");
		
		retVal = HzAuxVal2String(OutString,(DINT)dateTime.millisec,hzauxSTRING_FORMAT_3DIGITS);
		if (retVal == 0) errorFlag = 1;
		
		// final error 
		if (errorFlag) retVal = 0;
	} else {
		// error null pointer or error reading time
		retVal = 0;
	}	
	return(retVal);
}

/**************************************************************************************
* FBName: HzAuxImgFileNameS                                         
* @brief Generates image file name including extension
*                                                                                         
* Converts DINT value to the string and add it to the end of input string
* Also is possible to format it with additional zeroes, to have constans string  
* size.
*
* @param InOutString	input/string where generated value string is added
* @param Value          input numeric value it is used for file name incase empty InOutString
*                       othervice filename remain original
* @param FileExtension  adds this extensio at the end of name.
* @return               0 error typically pointers or size problem 
*                       >= 1 lenght of final string
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
unsigned short HzAuxImgFileNameS(plcstring* InOutString,plcstring* FileExtension, signed long Value) {
	UINT lenghtInOutString;
	UINT pointPosition;
	UINT retVal;
	BOOL errorFlag = 0;
	
	// input par checker
	if (InOutString == NULL) return(0); 
	if (FileExtension == NULL) return(0); 
	
	// file name generation
	if (InOutString[0] == 0) {
		// empty string
		if ((strlen(FileExtension) + 12) < hzauxSIZE_STRING_DEFAULT) {
			retVal = HzAuxVal2String(InOutString,Value,11);  // generates string from value
			if (retVal == 0) errorFlag = 1;
			// adds File extension
			strcat(InOutString,".");
			strcat(InOutString,FileExtension);
		} else {
			// to much big file extension
			errorFlag = 1;
		}	
	} else {
		// file name exists not empty
		lenghtInOutString = strlen(InOutString); 
		if (lenghtInOutString >= 4) pointPosition = lenghtInOutString - 4;
		else pointPosition = 0;
		
		if (InOutString[pointPosition] == '.') {
			InOutString[pointPosition + 1] = 0;  // remove extension after .
			// add new extension
			if ((strlen(InOutString) + strlen(FileExtension)) < hzauxSIZE_STRING_DEFAULT) {
				strcat(InOutString,FileExtension);   
			} else errorFlag = 1;	
		} else {
			// add new extension
			// add new extension
			if ((strlen(InOutString) + strlen(FileExtension)+ 1) < hzauxSIZE_STRING_DEFAULT) {
				strcat(InOutString,".");
				strcat(InOutString,FileExtension);
			} else errorFlag = 1;
		}	
	}	
	
	// error evaluation
	if (errorFlag) retVal = 0;
	else retVal = strlen(InOutString);
	
	return(retVal);
} // end HzAuxImgFileNameS()

/*************************************************************************************************
* FCName: HzAuxStr_Cpy(plcstring* pDest, unsigned long SizeDestString, plcstring* pSource)                                        
* @brief  Copy a source string into destignation string buffer (safe)
*
* Copies at most (SizeDestString - 1) characters from pSource into pDest and always
* null-terminates the result, so the destination buffer is never overrun even if
* pSource is longer than the available space.
*
* @param pDest 				Destignation string buffer
* @param SizeDestString     	Size (in bytes) of the destignation buffer, including space for the terminating zero
* @param pSource            	Source string which is copied into dest string
* @return               	 	0 error (NULL pointer or zero size), otherwise lenght of final (possibly truncated) string
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
/* Copy string into string buffer (safe) */
unsigned long HzAuxStr_Cpy(plcstring* pDest, unsigned long SizeDestString, plcstring* pSource) {
	UDINT sourceLenght;
	UDINT copyLenght;

	if (pDest == NULL) return(0);
	if (pSource == NULL) return(0);
	if (SizeDestString == 0) return(0);

	sourceLenght = strlen(pSource);
	copyLenght = (sourceLenght < (SizeDestString - 1)) ? sourceLenght : (SizeDestString - 1); // clamp to available space

	strncpy(pDest, pSource, copyLenght);
	pDest[copyLenght] = 0;  // guarantee null-termination

	return(copyLenght);
} // end FC

/*************************************************************************************************
* FCName: HzAuxStr_Cat(plcstring* pDest, unsigned long SizeDestString, plcstring* pSource)                                        
* @brief  Append a source string at the end of destignation string (safe) 
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pSource            Source string which is copied at the end of dest string
* @return               	Lenght of final string	
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
/* Append string to string buffer (safe) */
unsigned long HzAuxStr_Cat(plcstring* pDest, unsigned long SizeDestString, plcstring* pSource) {
	UDINT sizeAvailable;
	if (pDest == NULL) return(0);
	if (pSource == NULL) return(0);
	if (strlen(pDest) >= SizeDestString) return(0);

	sizeAvailable = SizeDestString - 1 - strlen(pDest);   // calculation free space
	strncat(pDest,pSource,sizeAvailable);
	return(strlen(pDest));
} // end FC

/*************************************************************************************************
* FCName: HzAuxStr_Cat_Float(plcstring* pDest, unsigned long SizeDestString, float Value) {
* @brief  Append a converted float value at the end of destignation string (safe) 
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
***************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************/
/* Append string to string buffer (safe) */
unsigned long HzAuxStr_Cat_Float(plcstring* pDest, unsigned long SizeDestString, float Value) {
	plcstring s[hzauxSIZE_STRING_DEFAULT];
	
	s[0] = 0; 				// reset string
	brsftoa(Value,(UDINT)s); 		// conversion 	
	HzAuxStr_Cat(pDest,SizeDestString,s); // final safety copy
	return(strlen(pDest));
} // end FC

/*************************************************************************************************
* FCName: HzAuxStr_Cat_Int(plcstring* pDest, unsigned long SizeDestString, DINT Value) {
* @brief  Append a converted float value at the end of destignation string (safe) 
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
***************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
***************************************************************************************************/
/* Append string to string buffer (safe) */
unsigned long HzAuxStr_Cat_Int(plcstring* pDest, unsigned long SizeDestString, signed long Value) {
	plcstring s[hzauxSIZE_STRING_DEFAULT];
	
	s[0] = 0; 				// reset string
	brsitoa(Value,(UDINT)s); 		// conversion 	
	HzAuxStr_Cat(pDest,SizeDestString,s); // final safety copy
	return(strlen(pDest));
} // end FC

/***********************************************************************************************************************
* FCName: HzAuxStr_Gen_TxtFloat(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, float Value) {
* @brief  Generates TEXT + value in dest string, Ads text to the original string
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pText              Source TEXT copied into dest string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
************************************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
************************************************************************************************************************/
unsigned long HzAuxStr_Gen_AddTxtFloat(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, float Value) {
	HzAuxStr_Cat(pDest,SizeDestString,pText);
	return(HzAuxStr_Cat_Float(pDest,SizeDestString,Value));
} // end FC

/***********************************************************************************************************************
* FCName: HzAuxStr_Gen_TxtInt(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, signed long Value) {
* @brief  Generates TEXT + value in dest string,Ads text to the original string
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pText              Source TEXT copied into dest string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
************************************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
************************************************************************************************************************/
unsigned long HzAuxStr_Gen_AddTxtInt(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, signed long Value) {
	HzAuxStr_Cat(pDest,SizeDestString,pText);
	return(HzAuxStr_Cat_Int(pDest,SizeDestString,Value));
} // end FC

/***********************************************************************************************************************
* FCName: HzAuxStr_Gen_TxtFloatSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, float Value) {
* @brief  Generates TEXT + value in dest string, Ads text to the original string, in SVG format: text="value"
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pText              Source TEXT copied into dest string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
************************************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
************************************************************************************************************************/
// generates text in format   text="32.6" 
unsigned long HzAuxStr_Gen_AddTxtFloatSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, float Value) {
	UDINT tempLenght;
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,pText);  // text
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"=\"");  // ="
	tempLenght = HzAuxStr_Cat_Float(pDest,SizeDestString,Value); // value
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"\" ");  // " 
	return(tempLenght);
} // end HzAuxStr_Gen_AddTxtFloatSvg

/***********************************************************************************************************************
* FCName: HzAuxStr_Gen_TxtIntSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, signed long Value) {
* @brief  Generates TEXT + value in dest string,Ads text to the original string in SVG format: text="value"
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pText              Source TEXT copied into dest string
* @param Value              Source string which is copied at the end of dest string
* @return               	Lenght of final string	
************************************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
************************************************************************************************************************/
// generates text in format   text="32" 
unsigned long HzAuxStr_Gen_AddTxtIntSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, signed long Value) {
	UDINT tempLenght;	
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,pText);  //text
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"=\"");  // ="
	tempLenght = HzAuxStr_Cat_Int(pDest,SizeDestString,Value);
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"\" ");  // " 
	return(tempLenght);
} // end HzAuxStr_Gen_AddTxtIntSvg

/***********************************************************************************************************************
* FCName: HzAuxStr_Gen_AddTxtAsParSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText,plcstring* pTextPar ) {
* @brief  Generates TEXT + value in dest string,Ads text to the original string in SVG format: text="value"
*
* @param pDest 				Destignation string 
* @param SizeDestString     Size Destignation string
* @param pText              Source TEXT copied into dest string
* @param pTextPar           Source par, is copied in "" like svg parameter
* @return               	Lenght of final string	
************************************************************************************************************************
* Author: Ladislav.Robb@icloud.com                                                        
************************************************************************************************************************/
// generates text in format   text="textParam" 
unsigned long HzAuxStr_Gen_AddTxtAsParSvg(plcstring* pDest, unsigned long SizeDestString,plcstring* pText, plcstring* pTextPar) {
	UDINT tempLenght;	
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,pText);  //text
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"=\"");  // ="
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,pTextPar);  //text Param
	tempLenght = HzAuxStr_Cat(pDest,SizeDestString,"\" ");  // " 
	return(tempLenght);
} // end HzAuxStr_Gen_AddTxtAsParSvg
