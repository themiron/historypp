{$IFNDEF M_ICOLIB}
{$DEFINE M_ICOLIB}

type

    PSKINICONDESC = ^TSKINICONDESC;
    TSKINICONDESC = record
        cbSize: int;
        pszSection: PChar;		//section name used to group icons
        pszDescription: PChar;		//description for options dialog
        pszName: PChar;			//name to refer to icon when playing and in db
        pszDefaultFile: PChar;		//default icon file to use
        iDefaultIndex: int;
    end;

const

//
//  Add a icon into options UI
//  NB! pszName should be unique, e.g.: clistmw_apply, tabsrmm_history
//
//  wParam = (WPARAM)0
//  lParam = (LPARAM)(SKINICONDESC*)sid;
//
    MS_SKIN2_ADDICON = 'Skin2/Icons/AddIcon';
//
//  Retrieve HICON with name specified in lParam
//  Returned HICON SHOULDN'T be destroyed, it managed by IcoLib
//
    MS_SKIN2_GETICON = 'Skin2/Icons/GetIcon';
//
//  Icons change notification
//
    ME_SKIN2_ICONSCHANGED = 'Skin2/IconsChanged';

{$ENDIF}
