/*******************************************************************************
 * Name:    CfgStorage                                                         *
 * Description:                                                                *
 *  Using mpRecipe saving, loading configuration data                          *
 *                                                                             *
 * Cycle time: Cyclic x x ms                                                  *
 * Author: Ladislav Robb                                                      *
 *                                                                             *
 * Changelog:                                                                  *
 *   V2.0.0 LR first released version                                         *
 *   V2.0.1 23.02.2025  LR HMI status                                         *
 *   V2.0.2 04.05.2025  LR change detection                                   *
 *   V2.0.3 25.05.2025  LR adds cfgAtlasOPC                                   *
 *******************************************************************************/

#include <bur/plctypes.h>

#ifdef _DEFAULT_INCLUDES
	#include <AsDefault.h>
#endif

/*
 * Initialization function for CfgStorage task
 */
void _INIT ProgramInit(void)
{
	/* Initialize HMI timer period */
	timerHMI_FB.PT = HMI_TIME;
	testConfigVariable = testConfigVariable;
	
	/* Clear structures */
	brsmemset(ADR(intfCfgStorage.cmd), 0, SIZEOF(intfCfgStorage.cmd));
	brsmemset(ADR(intfCfgStorage.mon), 0, SIZEOF(intfCfgStorage.mon));
	brsmemset(ADR(diag), 0, SIZEOF(diag));
	
	intfCfgStorage.error = FALSE;
	intfCfgStorage.statusID = 0;
	intfCfgStorage.step = cfgStorageSTEP_BOOT_INIT;
	
	regParEnable = FALSE; 
	
	/* If the configuration mode is not defined, set default mode */
	if (intfCfgStorage.cfg.mode == cfgStorage_NOT_DEFINED) {
		intfCfgStorage.cfg.mode = prjcfgDEFAULT_MODE_LOAD_CFG;
	}
	
	/*
	 * List of configuration variables for storing.
	 * Register the variables that need to be stored/loaded.
	 */
	mpCfgRecipeRegPar_FB[1].PVName = ADR("CfgStorage:testConfigVariable");
	changeDetectionPointers[1].actStructureAdr = ADR(testConfigVariable);
	changeDetectionPointers[1].size = SIZEOF(testConfigVariable);
	
	/* Initialize logger with event log user identifier */
	ArEventLogGetIdent_FB.Execute = TRUE;
	ArEventLogGetIdent_FB.Name = ADR("$$arlogusr");
	ArEventLogGetIdent_FB();	
}

