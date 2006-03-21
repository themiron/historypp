{-----------------------------------------------------------------------------
 m_historypp (historypp project)

 Version:   1.5
 Created:   06.08.2004
 Author:    Oxygen

 [ Description ]

 Header with History++ services declaration

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2004
-----------------------------------------------------------------------------}

{$IFNDEF M_HISTORYPP}
{$DEFINE M_HISTORYPP}

const

    //** VALUES FOR TItemRenderDetails.dwHistoryWindow
    //** Used in ME_HPP_RICHEDIT_ITEMPROCESS event
    //** This is one of the following params,
    //** saying what kind of history window displays
    //** processed item.

    // IRDHW_CONTACTHISTORY. The window is ordinary
    // contact history.
    IRDHW_CONTACTHISTORY = 1;
    // IRDHW_GLOBALHISTORY. The window is global
    // history (system history). Invokes by
    // Menu -> System History
    IRDHW_GLOBALHISTORY  = 2;
    // IRDHW_GLOBALSEARCH. The window is search
    // window and the processed item is the
    // result of the global search.
    IRDHW_GLOBALSEARCH   = 3;

    //** VALUES FOR TItemRenderDetails.dwFlags
    //** Used in ME_HPP_RICHEDIT_ITEMPROCESS event
    //** These flags inform you about what you are
    //** processing. Like saying that the item is
    //** selected or it's inline or such stuff

    // IRDF_SELECTED. The processed item is selected.
    // The background color will always be clHighlight
    // even if you change it (i will change it back).
    // Though, I will not touch font or font color.
    IRDF_SELECTED = 1;
    // IRDF_INLINE. The RichEdit provided is not one
    // that is used for drawing a cell, but the one
    // used for "inline editing".
    IRDF_INLINE   = 2;

type
  TItemRenderDetails = packed record
    hContact: THandle; // handle to the contact for which the event is processed
    hDBEvent: THandle; // handle to the event which is processed
    dwEventTime: DWord; // timestamp of the event
    wEventType: Word; // Event's flags (see m_database, EVENTTYPE_*; m_icq, ICQEVENTTYPE_*)
    IsEventSent: ByteBool; // Outgoing event. True if DBEF_SENT event flag is present (see m_database)
    dwFlags: DWord; // Any reasonable combination of IRDF_* flags.
    bHistoryWindow: Byte; // What kind of window history. See IRDHW_* values
    pProto: PChar; // Proto of the event, if available
    pModule: PChar; // Module of the event, if available
    dwReserved: DWord; // Reserved for future use, for now it's zero
    end;

  PItemRenderDetails = ^TItemRenderDetails;

const
  // ME_HPP_RICHEDIT_ITEMPROCESS
  // (supported from 1.5.0)
  // Called when next RichEdit history item
  // is rendered. Third-party plugins can alter it
  // like adding smileys, changing color and so on.
  // wParam - RichEdit control handle
  // lParam - pointer to TItemRenderDetails structure, information
  //          about processed item, see TItemRenderDetails for details
  //
  // Note: Changing richedit background color will change the background
  //       color of the whole cell! Additionally, the background color
  //       of the *selected* cell and richedit is ALWAYS clHighlight,
  //       no matter what you do. But font is untouched, so if your
  //       plugin changes font color, you may need to handle selected
  //       cells differently (use IF_SELECTED flag).
  //
  // Warn: Remeber about changing fonts. You CAN NOT have *different* fonts
  //       for the *same* item, depening on your wish. For example, the
  //       first time event is fired you set font for Item1 'Arial 10',
  //       and the next time you set font for the same Item1 'Arial 12'.
  //       Because height is calculated only once, and you may have
  //       problems with text painting (when you change font text can
  //       become too large and be cut or override another cell)
  //
  // See:  hpp_itemprocess_samples.pas for some sample event handlers
  //       like SmileyAdd and TextFormat support and special handler
  //       kinda of conversation separation
  ME_HPP_RICHEDIT_ITEMPROCESS = 'History++/RichEdit/ItemProcessEvent';

  // MS_HPP_SHOWGLOBALSEARCH
  // (supported from 1.5.0)
  // Show Global history search window
  // If already opened, bring it to front
  // wParam - zero
  // lParam - zero
  MS_HPP_SHOWGLOBALSEARCH = 'History++/ShowGlobalSearch';

  // MS_HPP_OPENHISTORYEVENT
  // (supported from 1.5.0)
  // Opens contact's history and selects
  // provided event
  // wParam - DBEvent handle
  // lParam - Contact handle
  //
  // Note: if you just want to show contact's history,
  //       use system service MS_HISTORY_SHOWCONTACTHISTORY
  //
  //       [BETA] if the history is protected, password will not
  //       be asked and the history will open. may change in the
  //       future
  MS_HPP_OPENHISTORYEVENT = 'History++/OpenHistoryEvent';

  // MS_HPP_GETVERSION
  // (supported from 1.5.0)
  // Get current History++ version
  // Third-party plugins can use it to know if installed
  // version of History++ supports particular feature
  // wParam - zero
  // lParam - zero
  // Return - current version, via PLUGIN_MAKE_VERSION macro
  MS_HPP_GETVERSION = 'History++/GetVersion';

{$ENDIF}
