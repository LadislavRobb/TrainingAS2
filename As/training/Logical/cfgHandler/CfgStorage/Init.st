PROGRAM _INIT
	timerHMI_FB.PT := HMI_TIME;
	
	(* clear structures *)
	brsmemset(ADR(intfCfgStorage.cmd),0,SIZEOF(intfCfgStorage.cmd));
	brsmemset(ADR(intfCfgStorage.mon),0,SIZEOF(intfCfgStorage.mon));
	brsmemset(ADR(diag),0,SIZEOF(diag));
	brsmemset(ADR(changeDetectionData),0,SIZEOF(changeDetectionData));
	
	DetectionTimer_FB.PT := DETECTION_PERIOD;
	DetectionTimer_FB.IN := FALSE;
	
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
	mpCfgRecipeRegPar_FB[1].PVName :=  ADR('mainConfig');
	changeDetectionPointers[1].actStructureAdr := ADR(mainConfig);
	changeDetectionPointers[1].size := SIZEOF(mainConfig);
	
	mpCfgRecipeRegPar_FB[2].PVName :=  ADR('intfGlbManager.cfg'); 
	changeDetectionPointers[2].actStructureAdr := ADR(intfGlbManager.cfg);
	changeDetectionPointers[2].size := SIZEOF(intfGlbManager.cfg);
	
	mpCfgRecipeRegPar_FB[3].PVName :=  ADR('intfWizard.cfg');
	changeDetectionPointers[3].actStructureAdr := ADR(intfWizard.cfg);
	changeDetectionPointers[3].size := SIZEOF(intfWizard.cfg);
	
	mpCfgRecipeRegPar_FB[4].PVName :=  ADR('cfgRoomStdObj');
	changeDetectionPointers[4].actStructureAdr := ADR(cfgRoomStdObj);
	changeDetectionPointers[4].size := SIZEOF(cfgRoomStdObj);
	
	mpCfgRecipeRegPar_FB[5].PVName :=  ADR('cfgSensorOxygen');
	changeDetectionPointers[5].actStructureAdr := ADR(cfgSensorOxygen);
	changeDetectionPointers[5].size := SIZEOF(cfgSensorOxygen);
	
	mpCfgRecipeRegPar_FB[6].PVName :=  ADR('cfgHwMap');
	changeDetectionPointers[6].actStructureAdr := ADR(cfgHwMap);
	changeDetectionPointers[6].size := SIZEOF(cfgHwMap);
	
	mpCfgRecipeRegPar_FB[7].PVName :=  ADR('intfAlarm.cfg'); 
	changeDetectionPointers[7].actStructureAdr := ADR(intfAlarm.cfg);
	changeDetectionPointers[7].size := SIZEOF(intfAlarm.cfg);
	
	mpCfgRecipeRegPar_FB[8].PVName :=  ADR('intfCfgStorage.cfg');
	changeDetectionPointers[8].actStructureAdr := ADR(intfCfgStorage.cfg);
	changeDetectionPointers[8].size := SIZEOF(intfCfgStorage.cfg);
	
	mpCfgRecipeRegPar_FB[9].PVName :=  ADR('cfgRack');
	changeDetectionPointers[9].actStructureAdr := ADR(cfgRack);
	changeDetectionPointers[9].size := SIZEOF(cfgRack);
	
	mpCfgRecipeRegPar_FB[10].PVName :=  ADR('cfgValve');
	changeDetectionPointers[10].actStructureAdr := ADR(cfgValve);
	changeDetectionPointers[10].size := SIZEOF(cfgValve);
	
	mpCfgRecipeRegPar_FB[11].PVName :=  ADR('cfgBeacon');
	changeDetectionPointers[11].actStructureAdr := ADR(cfgBeacon);
	changeDetectionPointers[11].size := SIZEOF(cfgBeacon);
	
	mpCfgRecipeRegPar_FB[12].PVName :=  ADR('cfgDryer');
	changeDetectionPointers[12].actStructureAdr := ADR(cfgDryer);
	changeDetectionPointers[12].size := SIZEOF(cfgDryer);
	
	mpCfgRecipeRegPar_FB[13].PVName :=  ADR('cfgPsa');
	changeDetectionPointers[13].actStructureAdr := ADR(cfgPsa);
	changeDetectionPointers[13].size := SIZEOF(cfgPsa);
	
	mpCfgRecipeRegPar_FB[14].PVName :=  ADR('cfgComp');
	changeDetectionPointers[14].actStructureAdr := ADR(cfgComp);
	changeDetectionPointers[14].size := SIZEOF(cfgComp);
	
	mpCfgRecipeRegPar_FB[15].PVName :=  ADR('cfgEPS');
	changeDetectionPointers[15].actStructureAdr := ADR(cfgEPS);
	changeDetectionPointers[15].size := SIZEOF(cfgEPS);
	
	mpCfgRecipeRegPar_FB[16].PVName :=  ADR('cfgDg');
	changeDetectionPointers[16].actStructureAdr := ADR(cfgDg);
	changeDetectionPointers[16].size := SIZEOF(cfgDg);
	
	mpCfgRecipeRegPar_FB[17].PVName :=  ADR('cfgExhFan');
	changeDetectionPointers[17].actStructureAdr := ADR(cfgExhFan);
	changeDetectionPointers[17].size := SIZEOF(cfgExhFan);
	
	mpCfgRecipeRegPar_FB[18].PVName :=  ADR('cfgTechAlarmObj');
	changeDetectionPointers[18].actStructureAdr := ADR(cfgTechAlarmObj);
	changeDetectionPointers[18].size := SIZEOF(cfgTechAlarmObj);
	
	mpCfgRecipeRegPar_FB[19].PVName :=  ADR('cfgSensorAnalog');
	changeDetectionPointers[19].actStructureAdr := ADR(cfgSensorAnalog);
	changeDetectionPointers[19].size := SIZEOF(cfgSensorAnalog);
	
	mpCfgRecipeRegPar_FB[20].PVName :=  ADR('cfgTechStringObj');
	changeDetectionPointers[20].actStructureAdr := ADR(cfgTechStringObj);
	changeDetectionPointers[20].size := SIZEOF(cfgTechStringObj);
	
	mpCfgRecipeRegPar_FB[21].PVName :=  ADR('cfgMeasureObj');
	changeDetectionPointers[21].actStructureAdr := ADR(cfgMeasureObj);
	changeDetectionPointers[21].size := SIZEOF(cfgMeasureObj);
	
	mpCfgRecipeRegPar_FB[22].PVName :=  ADR('cfgCntrlRoomObj');
	changeDetectionPointers[22].actStructureAdr := ADR(cfgCntrlRoomObj);
	changeDetectionPointers[22].size := SIZEOF(cfgCntrlRoomObj);
	
	mpCfgRecipeRegPar_FB[23].PVName :=  ADR('intfStringManager.cfg');
	changeDetectionPointers[23].actStructureAdr := ADR(intfStringManager.cfg);
	changeDetectionPointers[23].size := SIZEOF(intfStringManager.cfg);
	
	mpCfgRecipeRegPar_FB[24].PVName :=  ADR('cfgTab');
	changeDetectionPointers[24].actStructureAdr := ADR(cfgTab);
	changeDetectionPointers[24].size := SIZEOF(cfgTab);
	
	mpCfgRecipeRegPar_FB[25].PVName :=  ADR('intfDataRecorder.cfg');
	changeDetectionPointers[25].actStructureAdr := ADR(intfDataRecorder.cfg);
	changeDetectionPointers[25].size := SIZEOF(intfDataRecorder.cfg);
	
	mpCfgRecipeRegPar_FB[26].PVName :=  ADR('intfAudit.cfg');
	changeDetectionPointers[26].actStructureAdr := ADR(intfAudit.cfg);
	changeDetectionPointers[26].size := SIZEOF(intfAudit.cfg);
	
	mpCfgRecipeRegPar_FB[27].PVName :=  ADR('cfgUps');
	changeDetectionPointers[27].actStructureAdr := ADR(cfgUps);
	changeDetectionPointers[27].size := SIZEOF(cfgUps);
	
	mpCfgRecipeRegPar_FB[28].PVName :=  ADR('cfgEnMet');
	changeDetectionPointers[28].actStructureAdr := ADR(cfgEnMet);
	changeDetectionPointers[28].size := SIZEOF(cfgEnMet);
	
	mpCfgRecipeRegPar_FB[29].PVName :=  ADR('cfgAtlasGtw');
	changeDetectionPointers[29].actStructureAdr := ADR(cfgAtlasGtw);
	changeDetectionPointers[29].size := SIZEOF(cfgAtlasGtw);

	// mpCfgRecipeRegPar_FB[0].PVName :=  ADR('');
	
	
	// Change detection generating target adress of detection data
	tempDataOffset := 0;
	FOR i := 1 TO prjcfgNR_CFG_STORAGE_VAR DO
		IF changeDetectionPointers[i].size <> 0 THEN
			IF (tempDataOffset + changeDetectionPointers[i].size) < SIZE_DETECTION_BUFFER THEN
				changeDetectionPointers[i].savedStructureAdr := ADR(changeDetectionData[tempDataOffset]);
				tempDataOffset := tempDataOffset + changeDetectionPointers[i].size;
			ELSE
				EXIT;
			END_IF;
		END_IF;
	END_FOR;	
	
	changeDetectionMaxIndex := i - 1;
	intfCfgStorage.mon.numberCfgVariables := changeDetectionMaxIndex;
	flagBufferErrorWriteLogger := (intfCfgStorage.mon.numberCfgVariables <> prjcfgNR_CFG_STORAGE_VAR );
END_PROGRAM