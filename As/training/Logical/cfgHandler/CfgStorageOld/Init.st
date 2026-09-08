PROGRAM _INIT
	timerHMI_FB.PT := HMI_TIME;
	testConfigVariable := testConfigVariable;
	
	(* clear structures *)
	brsmemset(ADR(intfCfgStorage.cmd),0,SIZEOF(intfCfgStorage.cmd));
	brsmemset(ADR(intfCfgStorage.mon),0,SIZEOF(intfCfgStorage.mon));
	brsmemset(ADR(diag),0,SIZEOF(diag));
	
	intfCfgStorage.error := FALSE;
	intfCfgStorage.statusID := 0;
	intfCfgStorage.step := cfgStorageSTEP_BOOT_INIT;
	
	regParEnable := FALSE; 
	
	IF intfCfgStorage.cfg.mode = cfgStorage_NOT_DEFINED THEN
		intfCfgStorage.cfg.mode := prjcfgDEFAULT_MODE_LOAD_CFG;
	END_IF;
	
	(*****************************************************************************)
	(* list of cfg variables for storing                                         *)
	(*****************************************************************************)
	mpCfgRecipeRegPar_FB[1].PVName :=  ADR('CfgStorage:testConfigVariable');
	changeDetectionPointers[1].actStructureAdr := ADR(testConfigVariable);
	changeDetectionPointers[1].size := SIZEOF(testConfigVariable);
	
	// logger
	ArEventLogGetIdent_FB.Execute := TRUE;
	ArEventLogGetIdent_FB.Name := '$$arlogusr';
	ArEventLogGetIdent_FB();	

END_PROGRAM