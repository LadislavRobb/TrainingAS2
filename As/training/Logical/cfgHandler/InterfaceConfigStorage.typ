(*Interface config data storage*)
(************************************)

TYPE
	InterfaceCfgStorageType : {REDUND_UNREPLICABLE} 	STRUCT  (*Interface config data storage*)
		step : {REDUND_UNREPLICABLE} CfgStorageStepEnum; (*State machine*)
		cmd : {REDUND_UNREPLICABLE} CfgStorageCmdType; (*Commands*)
		mon : {REDUND_UNREPLICABLE} CfgStorageMonType; (*Monitor*)
		cfg : {REDUND_UNREPLICABLE} CfgStorageCfgType; (*Configuration*)
		header : {REDUND_UNREPLICABLE} MpRecipeHeaderType; (*file header*)
		error : {REDUND_UNREPLICABLE} BOOL; (*Active Error*)
		statusID : {REDUND_UNREPLICABLE} DINT; (*Status information*)
		mpLink : {REDUND_UNREPLICABLE} MpComIdentType; (*MpLink*)
	END_STRUCT;
END_TYPE

(* *)
(*Sub structures*)
(*******************)

TYPE
	CfgStorageCmdType : {REDUND_UNREPLICABLE} 	STRUCT  (*Commands*)
		saveData : {REDUND_UNREPLICABLE} BOOL; (*Save config data to files.. / event*)
		loadData : {REDUND_UNREPLICABLE} BOOL; (*Load config data / event*)
		errorReset : {REDUND_UNREPLICABLE} BOOL; (*Error reset*)
	END_STRUCT;
END_TYPE

(* *)

TYPE
	CfgStorageCfgType : {REDUND_UNREPLICABLE} 	STRUCT 
		mode : {REDUND_UNREPLICABLE} CfgStorageModeEnum;
	END_STRUCT;
END_TYPE

(* *)

TYPE
	CfgStorageMonType : {REDUND_UNREPLICABLE} 	STRUCT  (*Monitor *)
		dataInitializedOk : {REDUND_UNREPLICABLE} BOOL; (*Cfg data is OK inicialized, loaded *)
		lostMemory : {REDUND_UNREPLICABLE} BOOL; (*Retain memory is lost*)
		regParOk : {REDUND_UNREPLICABLE} BOOL; (*Reg par FBs are OK*)
		loadOk : {REDUND_UNREPLICABLE} BOOL; (*Loading cfg was OK*)
		saveOk : {REDUND_UNREPLICABLE} BOOL; (*Saving cfg was OK*)
		requestHMIconfirmation : {REDUND_UNREPLICABLE} BOOL; (*Request HMI for confirmation of loading cfg*)
		dataDetectIndex : {REDUND_UNREPLICABLE} UINT; (*Current index detecting cfg data*)
		numberCfgVariables : {REDUND_UNREPLICABLE} UINT; (*Number processed cfg variables*)
		unsavedDataDetected : {REDUND_UNREPLICABLE} BOOL; (*Unsaved config data detected*)
		stateHMI : {REDUND_UNREPLICABLE} CfgStorageHmiStateEnum; (*HMI state indicator*)
	END_STRUCT;
END_TYPE

(**)

TYPE
	CfgStorageStepEnum : 
		( (*Steps*)
		cfgStorageSTEP_BOOT_INIT := 0, (*init step *)
		cfgStorageSTEP_CHECK_MEMORY := 1, (*Checking retain memory / whether is corrupted*)
		cfgStorageSTEP_COMMAND_READY := 100, (*Command ready, basic state*)
		cfgStorageSTEP_SAVING_A_INI := 110, (*Saving file A ini step*)
		cfgStorageSTEP_SAVING_A := 111, (*Saving file A*)
		cfgStorageSTEP_SAVING_B_INI := 112, (*Saving file B ini step*)
		cfgStorageSTEP_SAVING_B := 113, (*Saving file B*)
		cfgStorageSTEP_LOADING_A_INI := 210, (*Loading file A ini step*)
		cfgStorageSTEP_LOADING_A := 211, (*Loading  file A*)
		cfgStorageSTEP_LOADING_B_INI := 212, (*Loading  file B ini step*)
		cfgStorageSTEP_LOADING_B := 213, (*Loading  file B*)
		cfgStorageSTEP_DETECT_DATA_RUN := 301, (*Preparing detection data *)
		cfgStorageSTEP_COMPARE_DATA_INI := 302, (*Ini data compare*)
		cfgStorageSTEP_COMPARE_DATA_RUN := 303, (*Comparing data*)
		cfgStorageSTEP_ERROR_RESET := 1000 (*Error Reset*)
		);
END_TYPE

(* *)

TYPE
	CfgStorageHmiStateEnum : 
		( (*HMI signalization *)
		cfgStorageHMI_NOT_READY := 0, (*Cfg file handling is not ready*)
		cfgStorageHMI_READY := 1, (*Cfg file handling is ready*)
		cfgStorageHMI_LOADING := 2, (*Cfg file handling is being loaded*)
		cfgStorageHMI_SAVING := 3, (*Cfg file handling is being saved*)
		cfgStorageHMI_OK := 4, (*Cfg file handling is saved/loaden OK*)
		cfgStorageHMI_ERROR := 5 (*Cfg file handling is in error state*)
		);
END_TYPE

(* *)

TYPE
	CfgStorageModeEnum : 
		(
		cfgStorage_NOT_DEFINED := 0,
		cfgStorage_MANUAL := 1, (*Everything work only manual, save or load only thought commands*)
		cfgStorage_AUTO_LOAD_MEMORY_LOST := 2, (*Auto load data after boot when retain memory is lost.*)
		cfgStorage_AUTO_LOAD_EVERY_BOOT := 3 (*Auto load data after every boot*)
		);
END_TYPE

(* *)
