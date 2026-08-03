(******************************************************************************
 * Name:    CfgStorage                                                        *
 * Description:                                                               *
 *  Using mpRecipe saving, loading configuration data                         *
 *                                                                            *
 *                                                                            *
 ******************************************************************************
 * Cycle time: Cyclic x x ms                                                  *
 * Author: Ladislav Robb                                                      *
 ******************************************************************************
 *Changelog:                                                                  *
 *   V2.0.0 LR first released version                                         *  
 *   V2.0.1 23.02.2025  LR HMI status                                         *
 *   V2.0.2 04.05.2025  LR change detection                                   *
 *   V2.0.3 25.05.2025  LR adds cfgAtlasOPC                                   *
 ******************************************************************************)
PROGRAM _CYCLIC
	(********************)
	(* mpLink assigning *)
	(********************)
	intfCfgStorage.mpLink := gCfgRecipeXml;
	
	(***********************************************)
	(* Registered global data for config structure *)
	(***********************************************)
	regParErrFlag := FALSE;
	FOR i:=1 TO prjcfgNR_CFG_STORAGE_VAR  DO
		mpCfgRecipeRegPar_FB[i].MpLink := ADR(intfCfgStorage.mpLink);
		mpCfgRecipeRegPar_FB[i].Enable := regParEnable;
		mpCfgRecipeRegPar_FB[i].ErrorReset := errorResetRegPar;
		mpCfgRecipeRegPar_FB[i]();
		IF mpCfgRecipeRegPar_FB[i].Error THEN
			regParErrFlag := TRUE;
		END_IF;	
	END_FOR;
	intfCfgStorage.mon.regParOk := NOT regParErrFlag;
	IF EDGENEG(intfCfgStorage.mon.regParOk) THEN
		// to write to logbook
		HpLogWriteI_FB.Severity := arEVENTLOG_SEVERITY_ERROR;
		HpLogWriteI_FB.Facility := prjFACILITY_INFRASTRUCTURE;
		HpLogWriteI_FB.ErrorCode := infrastrERR_CFGSTORAGE_REGPAR;
		HpLogWriteI_FB.CompleteID := 0;
		HpLogWriteI_FB.AdditionalDataString := '';
		HpLogWriteI_FB.Parametr := 0;
		HpLogWriteI_FB();
	END_IF;	

	// buffer error write to logger
	IF flagBufferErrorWriteLogger THEN
		flagBufferErrorWriteLogger := FALSE;
		// to write to logbook
		HpLogWriteI_FB.Severity := arEVENTLOG_SEVERITY_ERROR;
		HpLogWriteI_FB.Facility := prjFACILITY_INFRASTRUCTURE;		
		HpLogWriteI_FB.ErrorCode := infrastrERR_CFGSTORAGE_BUFFER;
		HpLogWriteI_FB.CompleteID := 0;
		HpLogWriteI_FB.AdditionalDataString := 'Index nr:';
		HpLogWriteI_FB.Parametr := intfCfgStorage.mon.numberCfgVariables ;
		HpLogWriteI_FB();
	END_IF;	
	
	(*******************)
	(* FBs mapp calling*)
	(*******************)
	mpCfgRecipe_FB.MpLink := ADR(gCfgRecipeXml);
	mpCfgRecipe_FB.Header := ADR(intfCfgStorage.header);
	mpCfgRecipe_FB();


	(**********************)
	(* main state machine *)
	(**********************)
	
	//Global error handling registration FBs or buffering error
	IF NOT intfCfgStorage.mon.regParOk THEN
		// regPar FBs one of them is not OK 
		IF NOT intfCfgStorage.error THEN
			intfCfgStorage.error := TRUE;
			intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_REGPAR);	
			diag.cntError := diag.cntError + 1;
		END_IF;	
	ELSIF intfCfgStorage.mon.numberCfgVariables <> prjcfgNR_CFG_STORAGE_VAR THEN
		// error size of detection buffer
		IF NOT intfCfgStorage.error THEN
			intfCfgStorage.error := TRUE;
			intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_BUFFER);	
			diag.cntError := diag.cntError + 1;
		END_IF;	
	END_IF;	
	
	
	CASE intfCfgStorage.step OF 
		(**********************)
		(* INI                *)
		(**********************)
		cfgStorageSTEP_BOOT_INIT:
			// ini vars
			mpCfgRecipe_FB.Enable := FALSE;
			regParEnable := FALSE;
			errorResetRegPar := FALSE;
			mpCfgRecipe_FB.ErrorReset := FALSE;
			brsmemset(ADR(intfCfgStorage.cmd),0,SIZEOF(intfCfgStorage.cmd));
			
			// presetting logger data
			HpLogWriteI_FB.Ident := intfLogger.ident;				(* Ident of user logger from interface *)
			HpLogWriteI_FB.Facility := prjFACILITY_INFRASTRUCTURE;
			HpLogWriteI_FB.CreatorName := 'CfgStorage';
			
			intfCfgStorage.step := cfgStorageSTEP_CHECK_MEMORY;

			(**********************)
			(* check memory       *)
			(**********************)
		cfgStorageSTEP_CHECK_MEMORY:
			// mapp comp enable
			mpCfgRecipe_FB.Enable := TRUE;
			regParEnable :=TRUE;	
			
			// checking memory 
			IF mainConfig.memoryPattern = MEMORY_PATTERN THEN
				// retain memory OK
				intfCfgStorage.mon.lostMemory := FALSE;
				
				IF intfCfgStorage.cfg.mode = cfgStorage_AUTO_LOAD_EVERY_BOOT THEN
					// automatic loading
					diag.cntLoad := diag.cntLoad + 1;
					mpCfgRecipe_FB.Load := FALSE;
					intfCfgStorage.error :=FALSE;	
					intfCfgStorage.statusID := 0;
					intfCfgStorage.mon.loadOk := FALSE;
				
					intfCfgStorage.step := cfgStorageSTEP_LOADING_A_INI;					
				ELSE
					// no load data are OK
					intfCfgStorage.mon.dataInitializedOk := TRUE;
					intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;
				END_IF;	
			ELSE
				// retain memory reset
				mainConfig.memoryPattern := MEMORY_PATTERN;
				intfCfgStorage.mon.lostMemory :=TRUE;
				diag.cnt_memoryLost := diag.cnt_memoryLost + 1; 
				// to write to logbook
				HpLogWriteI_FB.Severity := arEVENTLOG_SEVERITY_WARNING;
				HpLogWriteI_FB.ErrorCode := infrastrWARN_CFGSTORAGE_MEM_LOST;
				HpLogWriteI_FB.CompleteID := 0;
				HpLogWriteI_FB.AdditionalDataString := '';
				HpLogWriteI_FB.Parametr := 0;
				HpLogWriteI_FB();
				
				IF intfCfgStorage.cfg.mode <> cfgStorage_MANUAL THEN
					// automatic loading
					diag.cntLoad := diag.cntLoad + 1;
					mpCfgRecipe_FB.Load := FALSE;
					intfCfgStorage.error :=FALSE;	
					intfCfgStorage.statusID := 0;
					intfCfgStorage.mon.loadOk := FALSE;
				
					intfCfgStorage.step := cfgStorageSTEP_LOADING_A_INI;					
				ELSE
					// manual loading send signal to visu for action
					intfCfgStorage.mon.requestHMIconfirmation := TRUE;
					intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;
				END_IF;	
			END_IF;	

					
			(**********************)
			(* Command ready      *)
			(**********************)
		cfgStorageSTEP_COMMAND_READY:
			IF intfCfgStorage.cmd.errorReset THEN
				intfCfgStorage.cmd.errorReset := FALSE;
				diag.cntErrorReset := diag.cntErrorReset + 1;
				errorResetRegPar := TRUE;
				mpCfgRecipe_FB.ErrorReset := TRUE;
				
				intfCfgStorage.step := cfgStorageSTEP_ERROR_RESET;
			ELSIF intfCfgStorage.cmd.saveData THEN
				IF intfCfgStorage.error THEN
					// active error first auto reset 
					intfCfgStorage.cmd.errorReset := TRUE;
				ELSE 
					// no error save is possible
					intfCfgStorage.cmd.saveData := FALSE;
					diag.cntSave := diag.cntSave + 1;
					mpCfgRecipe_FB.Save := FALSE;
					intfCfgStorage.error :=FALSE;	
					intfCfgStorage.statusID := 0;
					intfCfgStorage.mon.saveOk := FALSE;
				
					intfCfgStorage.step := cfgStorageSTEP_SAVING_A_INI;
				END_IF;	
			ELSIF intfCfgStorage.cmd.loadData THEN
				IF intfCfgStorage.error THEN
					// active error first auto reset 
					intfCfgStorage.cmd.errorReset := TRUE;
				ELSE 
					// no error load is possible
					intfCfgStorage.cmd.loadData := FALSE;
					diag.cntLoad := diag.cntLoad + 1;
					mpCfgRecipe_FB.Load := FALSE;
					intfCfgStorage.error :=FALSE;	
					intfCfgStorage.statusID := 0;
					intfCfgStorage.mon.loadOk := FALSE;
				
					intfCfgStorage.step := cfgStorageSTEP_LOADING_A_INI;
				END_IF;	
			ELSIF DetectionTimer_FB.Q THEN
				DetectionTimer_FB.IN := FALSE;
				intfCfgStorage.step := cfgStorageSTEP_COMPARE_DATA_INI;
			END_IF;	
		
			(**********************)
			(* Saving             *)
			(**********************)
			// A	
		cfgStorageSTEP_SAVING_A_INI:
			mainConfig.memoryPattern := MEMORY_PATTERN;
			mpCfgRecipe_FB.Save := TRUE;
			mpCfgRecipe_FB.DeviceName := ADR(prjcfgDEV_NAME_A_CONFIG);
			mpCfgRecipe_FB.FileName := ADR(prjcfgFILE_NAME_A_CONFIG);
			// presetting header
			intfCfgStorage.header.Name := HEADER_NAME;
			intfCfgStorage.header.Description := HEADER_DESCRIPTION;
			intfCfgStorage.header.Version := mainSW_VERSION;
			gettime_FB.enable := TRUE;
			gettime_FB();
			intfCfgStorage.header.DateTime := gettime_FB.DT1;
			
			intfCfgStorage.step := cfgStorageSTEP_SAVING_A;	
		cfgStorageSTEP_SAVING_A:
			IF NOT mpCfgRecipe_FB.CommandBusy THEN
				mpCfgRecipe_FB.Save := FALSE;
				intfCfgStorage.step := cfgStorageSTEP_SAVING_B_INI;								

				IF mpCfgRecipe_FB.Error THEN
					// saving error
					intfCfgStorage.error := TRUE;
					intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_SAVING_A);
					diag.cntError := diag.cntError + 1;
					// logger
					HpLogWriteI_FB.CompleteID := intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString := 'Saving error config file A statusID:';
					HpLogWriteI_FB.Parametr := mpCfgRecipe_FB.StatusID;
					HpLogWriteI_FB();
				ELSIF mpCfgRecipe_FB.CommandDone THEN
					// OK saved		
					intfCfgStorage.mon.saveOk := TRUE;
				END_IF;			
			END_IF;			
			// B
		cfgStorageSTEP_SAVING_B_INI:
			mpCfgRecipe_FB.Save := TRUE;
			mpCfgRecipe_FB.DeviceName := ADR(prjcfgDEV_NAME_B_CONFIG);
			mpCfgRecipe_FB.FileName := ADR(prjcfgFILE_NAME_B_CONFIG);
			intfCfgStorage.step := cfgStorageSTEP_SAVING_B;					
		cfgStorageSTEP_SAVING_B:
			IF NOT mpCfgRecipe_FB.CommandBusy THEN
				mpCfgRecipe_FB.Save := FALSE;
				intfCfgStorage.step := cfgStorageSTEP_DETECT_DATA_INI;								
				IF mpCfgRecipe_FB.Error THEN
					// saving error
					intfCfgStorage.error := TRUE;
					intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_SAVING_B);
					diag.cntError := diag.cntError + 1;
					// logger
					HpLogWriteI_FB.CompleteID := intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString := 'Saving error config file B statusID:';
					HpLogWriteI_FB.Parametr := mpCfgRecipe_FB.StatusID;
					HpLogWriteI_FB();					
				ELSIF mpCfgRecipe_FB.CommandDone THEN
					// OK saved		
					timerHMI_FB.IN := TRUE;
					intfChecker.cmd.start := TRUE;
				END_IF;			
			END_IF;					    

			(**********************)
			(* Loading            *)
			(**********************)
			// A	
		cfgStorageSTEP_LOADING_A_INI:
			intfCfgStorage.mon.loadOk := FALSE;
			mpCfgRecipe_FB.Load := TRUE;
			mpCfgRecipe_FB.DeviceName := ADR(prjcfgDEV_NAME_A_CONFIG);
			mpCfgRecipe_FB.FileName := ADR(prjcfgFILE_NAME_A_CONFIG);
			
			intfCfgStorage.step := cfgStorageSTEP_LOADING_A;	
		cfgStorageSTEP_LOADING_A:
			IF NOT mpCfgRecipe_FB.CommandBusy THEN
				mpCfgRecipe_FB.Load := FALSE;
	
				IF mpCfgRecipe_FB.Error THEN
					// loading error
					intfCfgStorage.error := TRUE;
					intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_LOADING_A);
					diag.cntError := diag.cntError + 1;
					// logger
					HpLogWriteI_FB.CompleteID := intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString := 'Loading error config file A statusID:';
					HpLogWriteI_FB.Parametr := mpCfgRecipe_FB.StatusID;
					HpLogWriteI_FB();
					
					intfCfgStorage.step := cfgStorageSTEP_LOADING_B_INI;
				ELSIF mpCfgRecipe_FB.CommandDone THEN
					// OK 		
					timerHMI_FB.IN := TRUE;
					intfCfgStorage.mon.loadOk := TRUE;
					intfCfgStorage.mon.dataInitializedOk := TRUE;
					intfCfgStorage.mon.requestHMIconfirmation := FALSE;
					intfChecker.cmd.start := TRUE;
					intfCfgStorage.step := cfgStorageSTEP_DETECT_DATA_INI;
				END_IF;			
			END_IF;			
			// B
		cfgStorageSTEP_LOADING_B_INI:
			mpCfgRecipe_FB.Load := TRUE;
			mpCfgRecipe_FB.DeviceName := ADR(prjcfgDEV_NAME_B_CONFIG);
			mpCfgRecipe_FB.FileName := ADR(prjcfgFILE_NAME_B_CONFIG);
			intfCfgStorage.step := cfgStorageSTEP_LOADING_B;					
		cfgStorageSTEP_LOADING_B:
			IF NOT mpCfgRecipe_FB.CommandBusy THEN
				mpCfgRecipe_FB.Load := FALSE;
				intfCfgStorage.step := cfgStorageSTEP_DETECT_DATA_INI;								
				IF mpCfgRecipe_FB.Error THEN
					// saving error
					intfCfgStorage.error := TRUE;
					intfCfgStorage.statusID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,prjFACILITY_INFRASTRUCTURE,infrastrERR_CFGSTORAGE_LOADING_B);
					diag.cntError := diag.cntError + 1;
					// logger
					HpLogWriteI_FB.CompleteID := intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString := 'Loading error config file B statusID:';
					HpLogWriteI_FB.Parametr := mpCfgRecipe_FB.StatusID;
					HpLogWriteI_FB();					
					intfCfgStorage.mon.loadOk := FALSE;
				ELSIF mpCfgRecipe_FB.CommandDone THEN
					// OK saved	
					intfCfgStorage.mon.loadOk := TRUE;
					intfCfgStorage.mon.requestHMIconfirmation := FALSE;
					intfCfgStorage.mon.dataInitializedOk := TRUE;
					intfChecker.cmd.start := TRUE;
					timerHMI_FB.IN := TRUE;
				END_IF;			
			END_IF;					    
	
			(******************************)
			(* Detection DATA preparation *)
			(******************************)			
		cfgStorageSTEP_DETECT_DATA_INI:
			intfCfgStorage.mon.unsavedDataDetected := FALSE;		
			intfCfgStorage.mon.dataDetectIndex := 0;		
			diag.cntDetectionIni := diag.cntDetectionIni + 1;
			intfCfgStorage.step := cfgStorageSTEP_DETECT_DATA_RUN;
		cfgStorageSTEP_DETECT_DATA_RUN:			
			intfCfgStorage.mon.dataDetectIndex := intfCfgStorage.mon.dataDetectIndex + 1;		
			IF intfCfgStorage.mon.dataDetectIndex <=  changeDetectionMaxIndex THEN
				IF (changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].savedStructureAdr <> 0) AND (changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].size > 0) THEN
					brsmemcpy(changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].savedStructureAdr , changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].actStructureAdr, changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].size);
				END_IF;		
			ELSE
				// finished
				intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;	
			END_IF;		

			(******************************)
			(* Detection DATA COMPARE     *)
			(******************************)			
		cfgStorageSTEP_COMPARE_DATA_INI:
			intfCfgStorage.mon.dataDetectIndex := 0;
			diag.cntDetection := diag.cntDetection + 1;
			intfCfgStorage.step := cfgStorageSTEP_COMPARE_DATA_RUN;
		cfgStorageSTEP_COMPARE_DATA_RUN:			
			intfCfgStorage.mon.dataDetectIndex := intfCfgStorage.mon.dataDetectIndex + 1;		
			IF intfCfgStorage.mon.dataDetectIndex <=  changeDetectionMaxIndex THEN
				IF brsmemcmp(changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].actStructureAdr,changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].savedStructureAdr,changeDetectionPointers[intfCfgStorage.mon.dataDetectIndex].size) <> 0 THEN
					// change detected
					intfCfgStorage.mon.unsavedDataDetected := TRUE;	
					intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;						
				END_IF;	
			ELSE
				// finished
				intfCfgStorage.mon.unsavedDataDetected := FALSE;					
				intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;	
			END_IF;					
			
			(**********************)
			(* Error reset        *)
			(**********************)		
		cfgStorageSTEP_ERROR_RESET:	
			errorResetRegPar := FALSE;
			mpCfgRecipe_FB.ErrorReset := FALSE;		
			intfCfgStorage.error :=FALSE;	
			intfCfgStorage.statusID := 0;
			
			intfCfgStorage.step := cfgStorageSTEP_COMMAND_READY;		

	END_CASE;		
	
	(***********************)
	(* HMI state indicator *)
	(***********************)		
	// HMI timer
	timerHMI_FB();
	timerHMI_FB.IN := FALSE;
	
	IF intfCfgStorage.error THEN
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_ERROR;
	ELSIF intfCfgStorage.step < cfgStorageSTEP_COMMAND_READY THEN
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_NOT_READY;
	ELSIF (intfCfgStorage.step >= cfgStorageSTEP_LOADING_A_INI) AND (intfCfgStorage.step <= cfgStorageSTEP_LOADING_B)  THEN	
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_LOADING;
	ELSIF (intfCfgStorage.step >= cfgStorageSTEP_SAVING_A_INI) AND (intfCfgStorage.step <= cfgStorageSTEP_SAVING_B)  THEN	
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_SAVING;
	ELSIF timerHMI_FB.Q THEN
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_OK;
	ELSE
		intfCfgStorage.mon.stateHMI := cfgStorageHMI_READY;
	END_IF;	
	
	// detection timer
	DetectionTimer_FB();
	DetectionTimer_FB.IN := TRUE;
END_PROGRAM
