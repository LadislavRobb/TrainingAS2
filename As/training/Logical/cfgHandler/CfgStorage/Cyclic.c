/*******************************************************************************
 * Name:    CfgStorage                                                         *
 * Description:                                                                *
 *  Using mpRecipe saving, loading configuration data                          *
 *                                                                             *
 *                                                                             *
 *******************************************************************************/
 * Cycle time: Cyclic x x ms                                                  *
 * Author: Ladislav Robb                                                      *
 *******************************************************************************/
 *Changelog:                                                                   *
 *   V2.0.0 LR first released version                                         *
 *   V2.0.1 23.02.2025  LR HMI status                                         *
 *   V2.0.2 04.05.2025  LR change detection                                   *
 *   V2.0.3 25.05.2025  LR adds cfgAtlasOPC                                   *
 ******************************************************************************/

#include <bur/plctypes.h>

#ifdef _DEFAULT_INCLUDES
	#include <AsDefault.h>
#endif

/*
 * Cyclic function for CfgStorage task
 */
void _CYCLIC ProgramCyclic(void)
{
	/*
	 * Assign MpLink for configuration recipe
	 */
	intfCfgStorage.mpLink = gCfgRecipeXml;
	
	/*
	 * Register global data for configuration structure.
	 * Initialize and execute all registered parameter FBs.
	 */
	regParErrFlag = FALSE;
	for (i = 1; i <= prjcfgNR_CFG_STORAGE_VAR; i++) {
		mpCfgRecipeRegPar_FB[i].MpLink = ADR(intfCfgStorage.mpLink);
		mpCfgRecipeRegPar_FB[i].Enable = regParEnable;
		mpCfgRecipeRegPar_FB[i].ErrorReset = errorResetRegPar;
		mpCfgRecipeRegPar_FB[i]();
		if (mpCfgRecipeRegPar_FB[i].Error) {
			regParErrFlag = TRUE;
		}	
	}
	intfCfgStorage.mon.regParOk = !regParErrFlag;
	if (EDGENEG(intfCfgStorage.mon.regParOk)) {
		/* Write to logbook if registration failed */
		HpLogWriteI_FB.Severity = arEVENTLOG_SEVERITY_ERROR;
		HpLogWriteI_FB.Facility = prjFACILITY_INFRASTRUCTURE;
		HpLogWriteI_FB.ErrorCode = infrastrERR_CFGSTORAGE_REGPAR;
		HpLogWriteI_FB.CompleteID = 0;
		HpLogWriteI_FB.AdditionalDataString = "";
		HpLogWriteI_FB();
	}	

	/*
	 * Function block mapping call
	 */
	mpCfgRecipe_FB.MpLink = ADR(gCfgRecipeXml);
	mpCfgRecipe_FB.Header = ADR(intfCfgStorage.header);
	mpCfgRecipe_FB();

	/*
	 * Main state machine
	 */
	
	/* Global error handling for registration FBs or buffering errors */
	if (!intfCfgStorage.mon.regParOk) {
		/* If registration parameter FBs are not OK */
		if (!intfCfgStorage.error) {
			intfCfgStorage.error = TRUE;
			intfCfgStorage.statusID = ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR, prjFACILITY_INFRASTRUCTURE, infrastrERR_CFGSTORAGE_REGPAR);	
			diag.cntError = diag.cntError + 1;
		}	
	}	
	
	/* State machine implementation */
	switch (intfCfgStorage.step) {
		/*
		 * Boot initialization state
		 */
		case cfgStorageSTEP_BOOT_INIT:
			/* Initialize variables */
			mpCfgRecipe_FB.Enable = FALSE;
			regParEnable = FALSE;
			errorResetRegPar = FALSE;
			mpCfgRecipe_FB.ErrorReset = FALSE;
			brsmemset(ADR(intfCfgStorage.cmd), 0, SIZEOF(intfCfgStorage.cmd));
			
			/* Preset logger data */
			HpLogWriteI_FB.Ident = ArEventLogGetIdent_FB.Ident;	/* Ident of user logger from interface */
			HpLogWriteI_FB.Facility = prjFACILITY_INFRASTRUCTURE;
			HpLogWriteI_FB.CreatorName = ADR("CfgStorage");
			
			intfCfgStorage.step = cfgStorageSTEP_CHECK_MEMORY;
			break;

		/*
		 * Check memory state - verify if retain memory is valid
		 */
		case cfgStorageSTEP_CHECK_MEMORY:
			/* Enable MApp components */
			mpCfgRecipe_FB.Enable = TRUE;
			regParEnable = TRUE;	
			
			/* Check if retain memory pattern is valid */
			if (memoryPattern == MEMORY_PATTERN) {
				/* Retain memory is OK */
				intfCfgStorage.mon.lostMemory = FALSE;
				
				/* Check loading mode setting */
				if (intfCfgStorage.cfg.mode == cfgStorage_AUTO_LOAD_EVERY_BOOT) {
					/* Automatic loading after every boot */
					diag.cntLoad = diag.cntLoad + 1;
					mpCfgRecipe_FB.Load = FALSE;
					intfCfgStorage.error = FALSE;	
					intfCfgStorage.statusID = 0;
					intfCfgStorage.mon.loadOk = FALSE;
				
					intfCfgStorage.step = cfgStorageSTEP_LOADING_A_INI;					
				} else {
					/* Manual mode or no loading - data is OK */
					intfCfgStorage.mon.dataInitializedOk = TRUE;
					intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;
				}	
			} else {
				/* Retain memory is reset (lost or corrupted) */
				memoryPattern = MEMORY_PATTERN;
				intfCfgStorage.mon.lostMemory = TRUE;
				diag.cnt_memoryLost = diag.cnt_memoryLost + 1; 
				/* Write warning to logbook */
				HpLogWriteI_FB.Severity = arEVENTLOG_SEVERITY_WARNING;
				HpLogWriteI_FB.ErrorCode = infrastrWARN_CFGSTORAGE_MEM_LOST;
				HpLogWriteI_FB.CompleteID = 0;
				HpLogWriteI_FB.AdditionalDataString = "";
				HpLogWriteI_FB();
				
				/* Check if automatic loading is needed */
				if (intfCfgStorage.cfg.mode != cfgStorage_MANUAL) {
					/* Automatic loading */
					diag.cntLoad = diag.cntLoad + 1;
					mpCfgRecipe_FB.Load = FALSE;
					intfCfgStorage.error = FALSE;	
					intfCfgStorage.statusID = 0;
					intfCfgStorage.mon.loadOk = FALSE;
				
					intfCfgStorage.step = cfgStorageSTEP_LOADING_A_INI;					
				} else {
					/* Manual mode - send signal to HMI for action */
					intfCfgStorage.mon.requestHMIconfirmation = TRUE;
					intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;
				}	
			}	
			break;

		/*
		 * Command ready state - process commands
		 */
		case cfgStorageSTEP_COMMAND_READY:
			if (intfCfgStorage.cmd.errorReset) {
				intfCfgStorage.cmd.errorReset = FALSE;
				diag.cntErrorReset = diag.cntErrorReset + 1;
				errorResetRegPar = TRUE;
				mpCfgRecipe_FB.ErrorReset = TRUE;
				
				intfCfgStorage.step = cfgStorageSTEP_ERROR_RESET;
			} else if (intfCfgStorage.cmd.saveData) {
				/* Save data command */
				if (intfCfgStorage.error) {
					/* Active error - first auto reset */
					intfCfgStorage.cmd.errorReset = TRUE;
					intfCfgStorage.cmd.saveData = FALSE;
				} else {
					/* No error - save is possible */
					intfCfgStorage.cmd.saveData = FALSE;
					diag.cntSave = diag.cntSave + 1;
					mpCfgRecipe_FB.Save = FALSE;
					intfCfgStorage.error = FALSE;	
					intfCfgStorage.statusID = 0;
					intfCfgStorage.mon.saveOk = FALSE;
				
					intfCfgStorage.step = cfgStorageSTEP_SAVING_A_INI;
				}	
			} else if (intfCfgStorage.cmd.loadData) {
				/* Load data command */
				if (intfCfgStorage.error) {
					/* Active error - first auto reset */
					intfCfgStorage.cmd.errorReset = TRUE;
					intfCfgStorage.cmd.saveData = FALSE;
				} else {
					/* No error - load is possible */
					intfCfgStorage.cmd.loadData = FALSE;
					diag.cntLoad = diag.cntLoad + 1;
					mpCfgRecipe_FB.Load = FALSE;
					intfCfgStorage.error = FALSE;	
					intfCfgStorage.statusID = 0;
					intfCfgStorage.mon.loadOk = FALSE;
				
					intfCfgStorage.step = cfgStorageSTEP_LOADING_A_INI;
				}	
			}	
			break;

		/*
		 * Saving data to config file A initialization state
		 */
		case cfgStorageSTEP_SAVING_A_INI:
			memoryPattern = MEMORY_PATTERN;
			mpCfgRecipe_FB.Save = TRUE;
			mpCfgRecipe_FB.DeviceName = ADR(prjcfgDEV_NAME_A_CONFIG);
			mpCfgRecipe_FB.FileName = ADR(prjcfgFILE_NAME_A_CONFIG);
			/* Preset file header */
			intfCfgStorage.header.Name = HEADER_NAME;
			intfCfgStorage.header.Description = HEADER_DESCRIPTION;
			/* Get current date and time */
			gettime_FB.enable = TRUE;
			gettime_FB();
			intfCfgStorage.header.DateTime = gettime_FB.DT1;
			
			intfCfgStorage.step = cfgStorageSTEP_SAVING_A;	
			break;

		/*
		 * Saving data to config file A state
		 */
		case cfgStorageSTEP_SAVING_A:
			if (!mpCfgRecipe_FB.CommandBusy) {
				mpCfgRecipe_FB.Save = FALSE;
				intfCfgStorage.step = cfgStorageSTEP_SAVING_B_INI;								

				if (mpCfgRecipe_FB.Error) {
					/* Saving error in file A */
					intfCfgStorage.error = TRUE;
					intfCfgStorage.statusID = ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR, prjFACILITY_INFRASTRUCTURE, infrastrERR_CFGSTORAGE_SAVING_A);
					diag.cntError = diag.cntError + 1;
					/* Log the error */
					HpLogWriteI_FB.CompleteID = intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString = ADR("Saving error config file A statusID:");
					HpLogWriteI_FB();
				} else if (mpCfgRecipe_FB.CommandDone) {
					/* Successfully saved file A */
					intfCfgStorage.mon.saveOk = TRUE;
				}			
			}			
			break;

		/*
		 * Saving data to config file B initialization state
		 */
		case cfgStorageSTEP_SAVING_B_INI:
			mpCfgRecipe_FB.Save = TRUE;
			mpCfgRecipe_FB.DeviceName = ADR(prjcfgDEV_NAME_B_CONFIG);
			mpCfgRecipe_FB.FileName = ADR(prjcfgFILE_NAME_B_CONFIG);
			intfCfgStorage.step = cfgStorageSTEP_SAVING_B;					
			break;

		/*
		 * Saving data to config file B state
		 */
		case cfgStorageSTEP_SAVING_B:
			if (!mpCfgRecipe_FB.CommandBusy) {
				mpCfgRecipe_FB.Save = FALSE;
				intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;								
				if (mpCfgRecipe_FB.Error) {
					/* Saving error in file B */
					intfCfgStorage.error = TRUE;
					intfCfgStorage.statusID = ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR, prjFACILITY_INFRASTRUCTURE, infrastrERR_CFGSTORAGE_SAVING_B);
					diag.cntError = diag.cntError + 1;
					/* Log the error */
					HpLogWriteI_FB.CompleteID = intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString = ADR("Saving error config file B statusID:");
					HpLogWriteI_FB();					
				} else if (mpCfgRecipe_FB.CommandDone) {
					/* Successfully saved file B */
					timerHMI_FB.IN = TRUE;
				}			
			}					    
			break;

		/*
		 * Loading data from config file A initialization state
		 */
		case cfgStorageSTEP_LOADING_A_INI:
			intfCfgStorage.mon.loadOk = FALSE;
			mpCfgRecipe_FB.Load = TRUE;
			mpCfgRecipe_FB.DeviceName = ADR(prjcfgDEV_NAME_A_CONFIG);
			mpCfgRecipe_FB.FileName = ADR(prjcfgFILE_NAME_A_CONFIG);
			
			intfCfgStorage.step = cfgStorageSTEP_LOADING_A;	
			break;

		/*
		 * Loading data from config file A state
		 */
		case cfgStorageSTEP_LOADING_A:
			if (!mpCfgRecipe_FB.CommandBusy) {
				mpCfgRecipe_FB.Load = FALSE;
	
				if (mpCfgRecipe_FB.Error) {
					/* Loading error in file A */
					intfCfgStorage.error = TRUE;
					intfCfgStorage.statusID = ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR, prjFACILITY_INFRASTRUCTURE, infrastrERR_CFGSTORAGE_LOADING_A);
					diag.cntError = diag.cntError + 1;
					/* Log the error */
					HpLogWriteI_FB.CompleteID = intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString = ADR("Loading error config file A statusID:");
					HpLogWriteI_FB();
					
					intfCfgStorage.step = cfgStorageSTEP_LOADING_B_INI;
				} else if (mpCfgRecipe_FB.CommandDone) {
					/* Successfully loaded file A */
					timerHMI_FB.IN = TRUE;
					intfCfgStorage.mon.loadOk = TRUE;
					intfCfgStorage.mon.dataInitializedOk = TRUE;
					intfCfgStorage.mon.requestHMIconfirmation = FALSE;
					intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;
				}			
			}			
			break;

		/*
		 * Loading data from config file B initialization state
		 */
		case cfgStorageSTEP_LOADING_B_INI:
			mpCfgRecipe_FB.Load = TRUE;
			mpCfgRecipe_FB.DeviceName = ADR(prjcfgDEV_NAME_B_CONFIG);
			mpCfgRecipe_FB.FileName = ADR(prjcfgFILE_NAME_B_CONFIG);
			intfCfgStorage.step = cfgStorageSTEP_LOADING_B;					
			break;

		/*
		 * Loading data from config file B state
		 */
		case cfgStorageSTEP_LOADING_B:
			if (!mpCfgRecipe_FB.CommandBusy) {
				mpCfgRecipe_FB.Load = FALSE;
				intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;								
				if (mpCfgRecipe_FB.Error) {
					/* Loading error in file B */
					intfCfgStorage.error = TRUE;
					intfCfgStorage.statusID = ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR, prjFACILITY_INFRASTRUCTURE, infrastrERR_CFGSTORAGE_LOADING_B);
					diag.cntError = diag.cntError + 1;
					/* Log the error */
					HpLogWriteI_FB.CompleteID = intfCfgStorage.statusID;
					HpLogWriteI_FB.AdditionalDataString = ADR("Loading error config file B statusID:");
					HpLogWriteI_FB();					
					intfCfgStorage.mon.loadOk = FALSE;
				} else if (mpCfgRecipe_FB.CommandDone) {
					/* Successfully loaded file B */
					intfCfgStorage.mon.loadOk = TRUE;
					intfCfgStorage.mon.requestHMIconfirmation = FALSE;
					intfCfgStorage.mon.dataInitializedOk = TRUE;
					timerHMI_FB.IN = TRUE;
				}			
			}					    
			break;

		/*
		 * Error reset state
		 */
		case cfgStorageSTEP_ERROR_RESET:	
			errorResetRegPar = FALSE;
			mpCfgRecipe_FB.ErrorReset = FALSE;		
			intfCfgStorage.error = FALSE;	
			intfCfgStorage.statusID = 0;
			
			intfCfgStorage.step = cfgStorageSTEP_COMMAND_READY;		
			break;

		default:
			/* Unknown state - should not happen */
			break;
	}	
	
	/*
	 * HMI state indicator processing
	 */
	/* Process HMI timer */
	timerHMI_FB();
	timerHMI_FB.IN = FALSE;
	
	/* Determine HMI state based on current state and error conditions */
	if (intfCfgStorage.error) {
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_ERROR;
	} else if (intfCfgStorage.step < cfgStorageSTEP_COMMAND_READY) {
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_NOT_READY;
	} else if ((intfCfgStorage.step >= cfgStorageSTEP_LOADING_A_INI) && (intfCfgStorage.step <= cfgStorageSTEP_LOADING_B)) {	
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_LOADING;
	} else if ((intfCfgStorage.step >= cfgStorageSTEP_SAVING_A_INI) && (intfCfgStorage.step <= cfgStorageSTEP_SAVING_B)) {	
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_SAVING;
	} else if (timerHMI_FB.Q) {
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_OK;
	} else {
		intfCfgStorage.mon.stateHMI = cfgStorageHMI_READY;
	}	
}

