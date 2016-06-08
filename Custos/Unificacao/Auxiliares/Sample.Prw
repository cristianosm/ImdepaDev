#include "FiveWin.ch"
#include "Scintilla.ch"
#include "report.ch"
#include "mail.ch"

#define COLOR_WINDOW 5

#ifdef __XHARBOUR__
   #define hb_CurDrive CurDrive
#endif

static nError, oReport

//----------------------------------------------------------------------------//

CLASS TScintilla FROM TControl

   DATA cFileName
   DATA cLastFind INIT ""
   DATA oRowItem, oColItem
   DATA aCopys
   DATA aKey			AS ARRAY INIT {}

   CLASSDATA lRegisterd AS LOGICAL
   CLASSDATA hLib
   CLASSDATA nInst AS NUMERIC INIT 0
   CLASSDATA aMrus AS ARRAY INIT {}
   CLASSDATA cLineBuffer

   // METHOD Link() INLINE Super:Link( .F. )

   METHOD SetColor( nClrText, nClrPane )

   METHOD New( nRow, nCol, oWnd, nWidth, nHeight ) CONSTRUCTOR
   METHOD End()
   METHOD AddText( cText )                    INLINE ::Send( SCI_ADDTEXT, Len( cText ), cText )
   METHOD AddKey( nKey, bAction )             INLINE AAdd( ::aKey, { nKey, bAction } )
   METHOD AddTextCRLF( cText )                INLINE ::Send( SCI_ADDTEXT, Len( cText )+2, cText+CRLF )
   METHOD Backtab()                           INLINE ::Send( SCI_BACKTAB )
   METHOD CanRedo()                           INLINE ::Send( SCI_CANREDO ) != 0
   METHOD CanUndo()                           INLINE ::Send( SCI_CANUNDO ) != 0
   METHOD Cancel ()                           INLINE ::Send( SCI_CANCEL )
   METHOD Charleft ()                         INLINE ::Send( SCI_CHARLEFT )
   METHOD Charleftextend ()                   INLINE ::Send( SCI_CHARLEFTEXTEND )
   METHOD Charleftrectextend ()               INLINE ::Send( SCI_CHARLEFTRECTEXTEND )
   METHOD Charright ()                        INLINE ::Send( SCI_CHARRIGHT )
   METHOD Charrightextend ()                  INLINE ::Send( SCI_CHARRIGHTEXTEND )
   METHOD Charrightrectextend ()              INLINE ::Send( SCI_CHARRIGHTRECTEXTEND )
   METHOD ClearAll()                          INLINE ::Send( SCI_CLEARALL )
   METHOD Close()
   METHOD Copy()                              INLINE ::Send( SCI_COPY )
   METHOD CopyLine()                          INLINE ::Send( SCI_LINECOPY )
   METHOD Cut()                               INLINE ::Send( SCI_CUT )
   METHOD Deleteback()                        INLINE ::Send( SCI_DELETEBACK )
   METHOD Deletebacknotline ()                INLINE ::Send( SCI_DELETEBACKNOTLINE )
   METHOD Dellineleft()                       INLINE ::Send( SCI_DELLINELEFT )
   METHOD Dellineright()                      INLINE ::Send( SCI_DELLINERIGHT )
   METHOD Delwordleft()                       INLINE ::Send( SCI_DELWORDLEFT )
   METHOD Delwordright()                      INLINE ::Send( SCI_DELWORDRIGHT )
   METHOD DlgFindText()
   METHOD DlgGoToLine()
   METHOD Documentend()                       INLINE ::Send( SCI_DOCUMENTEND )
   METHOD Documentendextend()                 INLINE ::Send( SCI_DOCUMENTENDEXTEND )
   METHOD Documentstart()                     INLINE ::Send( SCI_DOCUMENTSTART )
   METHOD Documentstartextend()               INLINE ::Send( SCI_DOCUMENTSTARTEXTEND )
   METHOD Edittoggleovertype()                INLINE ::Send( SCI_EDITTOGGLEOVERTYPE )
   METHOD EmptyUndoBuffer()                   INLINE ::Send( EM_EMPTYUNDOBUFFER )
   METHOD FindNext()                          INLINE ::FindText( If( ! Empty( ::GetSelText() ), ::GetSelText(), ::cLastFind ), .T. )
   METHOD FindPrev()                          INLINE ::FindText( If( ! Empty( ::GetSelText() ), ::GetSelText(), ::cLastFind ), .F. )
   METHOD FindText( cText, lForward )
   METHOD GetAnchor()                         INLINE ::Send( SCI_GETANCHOR )
   METHOD GetCurLine( nLength, cText )        INLINE ::Send( SCI_GETCURLINE, nLength, cText )
   METHOD GetCurrentPos()                     INLINE ::Send( SCI_GETCURRENTPOS )
   METHOD GetCurrentStyle()
   METHOD GetLine( nLine )                    INLINE SciGetLine( ::hWnd, nLine )
   METHOD GetLineCount()                      INLINE ::Send( SCI_GETLINECOUNT )
   METHOD GetModify()                         INLINE ::Send( SCI_GETMODIFY ) != 0
   METHOD GetReadOnly()                       INLINE ::Send( SCI_GETREADONLY ) != 0
   METHOD GetSelText()                        INLINE SciGetSelText(::hWnd, ::Send( SCI_GETSELECTIONEND) - ::Send( SCI_GETSELECTIONSTART) )
   METHOD GetSelectionStart()                 INLINE ::Send( SCI_GETSELECTIONSTART )
   METHOD GetText()                           INLINE SciGetText( ::hWnd )
   METHOD GetTextRange( nLin0, nCol0, nLin1, nCol1 )
   METHOD GoDown()                            INLINE ::Send( SCI_LINEDOWN )
   METHOD GoEol()                             INLINE ::Send( SCI_LINEEND )
   METHOD GoHome()                            INLINE ::Send( SCI_HOME )
   METHOD GoLeft()                            INLINE ::CharLeft()
   METHOD GoRight()                           INLINE ::CharRight()
   METHOD GoUp()                              INLINE ::Send( SCI_LINEUP )
   METHOD GotoLine( nLine )                   INLINE ::Send( SCI_GOTOLINE, nLine - 1, 0 )
   METHOD GotoPos( nPos )                     INLINE ::Send( SCI_GOTOPOS, nPos, 0 )
   METHOD Home ()                             INLINE ::Send( SCI_HOME )
   METHOD Homedisplay ()                      INLINE ::Send( SCI_HOMEDISPLAY )
   METHOD Homedisplayextend ()                INLINE ::Send( SCI_HOMEDISPLAYEXTEND )
   METHOD Homeextend ()                       INLINE ::Send( SCI_HOMEEXTEND )
   METHOD Homerectextend ()                   INLINE ::Send( SCI_HOMERECTEXTEND )
   METHOD Homewrap ()                         INLINE ::Send( SCI_HOMEWRAP )
   METHOD Homewrapextend ()                   INLINE ::Send( SCI_HOMEWRAPEXTEND )
   METHOD InsertText ( nPos, cText )          INLINE ::Send( SCI_INSERTTEXT, nPos, cText)
   METHOD IsReadOnly()                        INLINE SC_IsReadOnly( ::hWnd )
   METHOD KeyChar( nKey, nFlags )
   METHOD KeyDown( nKey, nFlags )
   METHOD LineFromPosition( nPos )            INLINE ::Send( SCI_LINEFROMPOSITION, nPos, 0 )
   METHOD LineLength( nLine )                 INLINE ::Send( SCI_LINELENGTH, nLine, 0 )
   METHOD Linecopy ()                         INLINE ::Send( SCI_LINECOPY )
   METHOD Linecut ()                          INLINE ::Send( SCI_LINECUT )
   METHOD Linedelete ()                       INLINE ::Send( SCI_LINEDELETE )
   METHOD Linedown ()                         INLINE ::Send( SCI_LINEDOWN )
   METHOD Linedownextend ()                   INLINE ::Send( SCI_LINEDOWNEXTEND )
   METHOD Linedownrectextend ()               INLINE ::Send( SCI_LINEDOWNRECTEXTEND )
   METHOD Lineduplicate ()                    INLINE ::Send( SCI_LINEDUPLICATE )
   METHOD Lineend ()                          INLINE ::Send( SCI_LINEEND )
   METHOD Lineenddisplay ()                   INLINE ::Send( SCI_LINEENDDISPLAY )
   METHOD Lineenddisplayextend ()             INLINE ::Send( SCI_LINEENDDISPLAYEXTEND )
   METHOD Lineendextend ()                    INLINE ::Send( SCI_LINEENDEXTEND )
   METHOD Lineendrectextend ()                INLINE ::Send( SCI_LINEENDRECTEXTEND )
   METHOD Lineendwrap ()                      INLINE ::Send( SCI_LINEENDWRAP )
   METHOD Lineendwrapextend ()                INLINE ::Send( SCI_LINEENDWRAPEXTEND )
   METHOD Linescrolldown ()                   INLINE ::Send( SCI_LINESCROLLDOWN )
   METHOD Linescrollup ()                     INLINE ::Send( SCI_LINESCROLLUP )
   METHOD Linetranspose ()                    INLINE ::Send( SCI_LINETRANSPOSE )
   METHOD LineUp()                            INLINE ::Send( SCI_LINEUP )
   METHOD LineUpExtend()                      INLINE ::Send( SCI_LINEUPEXTEND )
   METHOD Lineuprectextend ()                 INLINE ::Send( SCI_LINEUPRECTEXTEND )
   METHOD Lowercase ()                        INLINE ::Send( SCI_LOWERCASE )
   METHOD MarkerAdd( nLine,  nMarkerNumber)   INLINE ::Send( SCI_MARKERADD, nLine, nMarkerNumber)
   METHOD MouseMove( nRow, nCol, nKeyFlags )  INLINE CallWindowProc( ::nOldProc, ::hWnd, WM_MOUSEMOVE, nKeyFlags, nMakeLong( nCol, nRow ) )
   METHOD nCol()                              INLINE ::GetCurrentPos() - ::PositionFromLine( ::nLine() - 1 ) + 1
   METHOD NewLine()                           INLINE ::Send( SCI_NEWLINE )
   METHOD nLine()                             INLINE ::Send( SCI_LINEFROMPOSITION, ::GetCurrentPos(), 0 ) + 1
   METHOD Notify( nId, nPtrNMHDR )
   METHOD Open()
   METHOD OpenFile( cFileName )
   METHOD OptionSetFont()
   METHOD Pagedown ()                         INLINE ::Send( SCI_PAGEDOWN )
   METHOD Pagedownextend ()                   INLINE ::Send( SCI_PAGEDOWNEXTEND )
   METHOD Pagedownrectextend ()               INLINE ::Send( SCI_PAGEDOWNRECTEXTEND )
   METHOD Pageup ()                           INLINE ::Send( SCI_PAGEUP )
   METHOD Pageupextend ()                     INLINE ::Send( SCI_PAGEUPEXTEND )
   METHOD Pageuprectextend ()                 INLINE ::Send( SCI_PAGEUPRECTEXTEND )
   METHOD Paradown ()                         INLINE ::Send( SCI_PARADOWN )
   METHOD Paradownextend ()                   INLINE ::Send( SCI_PARADOWNEXTEND )
   METHOD Paraup ()                           INLINE ::Send( SCI_PARAUP )
   METHOD Paraupextend ()                     INLINE ::Send( SCI_PARAUPEXTEND )
   METHOD Paste()                             INLINE ::Send( SCI_PASTE )
   METHOD PositionFromLine( nLine )           INLINE ::Send( SCI_POSITIONFROMLINE, nLine, 0 )
   METHOD Print()
   METHOD Redo()                              INLINE ::Send( SCI_REDO )
   METHOD ReplaceSel( cText )                 INLINE ::Send( SCI_REPLACESEL, 0, cText )
   METHOD Save()
   METHOD SayMemo()
   METHOD SearchNext( nFlags, cText )         INLINE ::Send( SCI_SEARCHNEXT, nFlags, cText )
   METHOD SearchPrev( nFlags, cText )         INLINE ::Send( SCI_SEARCHPREV, nFlags, cText )
   METHOD SendAsEmail()
   METHOD Send( nMsg, nWParam, nLParam )
   METHOD SetFixedFont()
   METHOD SetReadOnly( lOn )                  INLINE ::Send( SCI_SETREADONLY, If( lOn, 1, 0 ), 0 )
   METHOD SetSavePoint()                      INLINE ::Send( SCI_SETSAVEPOINT )
   METHOD SetSel ( nStart, nEnd )             INLINE ::Send( SCI_SETSEL, nStart, nEnd )
   METHOD SetText( cText )                    INLINE ::Send( SCI_SETTEXT, 0, cText )
   METHOD SetUndoCollection()                 INLINE ::Send( SCI_SETUNDOCOLLECTION )
   METHOD Stutteredpagedown()                 INLINE ::Send( SCI_STUTTEREDPAGEDOWN )
   METHOD StutteredpagedownextenD()           INLINE ::Send( SCI_STUTTEREDPAGEDOWNEXTEND )
   METHOD Stutteredpageup()                   INLINE ::Send( SCI_STUTTEREDPAGEUP )
   METHOD Stutteredpageupextend ()            INLINE ::Send( SCI_STUTTEREDPAGEUPEXTEND )
   METHOD StyleSetBold( nStyle,  bold )
   METHOD StyleSetFont( nStyle, cFontName)
   METHOD StyleSetFore( nStyle, fore)
   METHOD StyleSetItalic( nStyle,  italic)
   METHOD StyleSetSize( nStyle,  nSizePoints)
   METHOD StyleSetUnderline( nStyle,  underline)
   METHOD Tab()                               INLINE ::Send( SCI_TAB )
   METHOD Undo()                              INLINE ::Send( SCI_UNDO )
   METHOD Uppercase()                         INLINE ::Send( SCI_UPPERCASE )
   METHOD Vchome()                            INLINE ::Send( SCI_VCHOME )
   METHOD Vchomeextend()                      INLINE ::Send( SCI_VCHOMEEXTEND )
   METHOD Vchomerectextend()                  INLINE ::Send( SCI_VCHOMERECTEXTEND )
   METHOD Vchomewrap()                        INLINE ::Send( SCI_VCHOMEWRAP )
   METHOD Vchomewrapextend ()                 INLINE ::Send( SCI_VCHOMEWRAPEXTEND )
   METHOD Wordleft ()                         INLINE ::Send( SCI_WORDLEFT )
   METHOD Wordleftend ()                      INLINE ::Send( SCI_WORDLEFTEND )
   METHOD Wordleftendextend ()                INLINE ::Send( SCI_WORDLEFTENDEXTEND )
   METHOD Wordleftextend ()                   INLINE ::Send( SCI_WORDLEFTEXTEND )
   METHOD Wordpartleft ()                     INLINE ::Send( SCI_WORDPARTLEFT )
   METHOD Wordpartleftextend ()               INLINE ::Send( SCI_WORDPARTLEFTEXTEND )
   METHOD Wordpartright ()                    INLINE ::Send( SCI_WORDPARTRIGHT )
   METHOD Wordpartrightextend ()              INLINE ::Send( SCI_WORDPARTRIGHTEXTEND )
   METHOD Wordright ()                        INLINE ::Send( SCI_WORDRIGHT )
   METHOD Wordrightend ()                     INLINE ::Send( SCI_WORDRIGHTEND )
   METHOD Wordrightendextend ()               INLINE ::Send( SCI_WORDRIGHTENDEXTEND )
   METHOD Wordrightextend ()                  INLINE ::Send( SCI_WORDRIGHTEXTEND )
   METHOD nPos( nNewVal )                     SETGET

   METHOD SetAStyle( style, fore, back, size, face )

   METHOD Setup()

   METHOD HandleEvent( nMsg, nWParam, nLParam )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD Send( nMsg, nWParam, nLParam ) CLASS TScintilla

   DEFAULT nWParam := 0, nLParam := 0

return SendMessage( ::hWnd, nMsg, nWParam, nLParam )

//----------------------------------------------------------------------------//

METHOD End() CLASS TScintilla

   if ::nInst == 0
      FreeLibrary( ::hLib )
   endif

return Super:End()

//----------------------------------------------------------------------------//

METHOD nPos( nNewVal ) CLASS TScintilla

   if pcount() > 0
      ::GotoPos( nNewVal )
   endif

return ::GetCurrentPos()

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeight, oWnd ) CLASS TScintilla

DEFAULT nRow := 0, nCol := 0, nWidth := 100, nHeight := 100

   ::nTop     = nRow
   ::nLeft    = nCol
   ::nBottom  = nRow + nHeight
   ::nRight   = nCol + nWidth
   ::oWnd     = oWnd
   ::nStyle   = nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, WS_VSCROLL, WS_HSCROLL  )
   ::nId       = ::GetNewId()
   ::cFileName = "Noname"

   if ::nInst == 0
      ::hLib := LoadLibrary( "SciLexer.DLL" )
      ::nInst ++
   endif

   if ! Empty( oWnd:hWnd )
      ::Create( "Scintilla" )
      ::Default()
      oWnd:AddControl( Self )
   else
      oWnd:DefControl( Self )
   endif

   ::aCopys := {}

return Self

//----------------------------------------------------------------------------//

METHOD SetColor( nClrText, nClrPane ) CLASS TScintilla

   ::Send( SCI_STYLESETFORE, STYLE_DEFAULT, nClrText )
   ::Send( SCI_STYLESETBACK, STYLE_DEFAULT, nClrPane )

return nil

//----------------------------------------------------------------------------//

METHOD Open( oMru ) CLASS TScintilla

   local cFileName := cGetFile( "Program file (*.prg) |*.prg|" + ;
                                "Header file (*.ch) |*.ch|" + ;
                                "Resource file (*.rc) |*.rc|" + ;
                                "Open any file (*.*) |*.*|",;
                                "Select a file to open" )

   if ! File( cFileName )
      return .F.
   endif

   ::OpenFile( cFileName )

   ::oWnd:cTitle = cFileName

   if oMru != nil .and. ValType( oMru ) == "O"
      oMru:Save( cFileName )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD FindText( cText, lForward ) CLASS TScintilla

   DEFAULT lForward := .T.

   ::cLastFind = cText

   if lForward
      return SearchForward( ::hWnd, cText )
   else
      return SearchBackward( ::hWnd, cText )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Save() CLASS TScintilla

   local hMani, cFile

   if Empty( ::cFileName ) .or. ! File( ::cFileName )
      cFile = cGetFile( , "Save as", 0, hb_CurDrive() + ":\" + CurDir(), .T., .T. )
      ::cFileName := cFile
   endif

   hMani := Fcreate( ::cFileName )
   fwrite( hMani, ::GetText() )
   fclose( hMani )
   ::oWnd:cTitle = ::cFileName

return nil

//----------------------------------------------------------------------------//

METHOD OpenFile( cFileName ) CLASS TScintilla

   local cStr := MemoRead( cFileName )

   ::SetText( cStr )
   ::SetSavePoint() // unmodified state
   ::cFilename = cFileName

   if AScan( ::aMrus, cFileName ) == 0
      AAdd( ::aMrus, cFileName )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GetTextRange( nLin0, nCol0, nLin1, nCol1 ) CLASS TScintilla

   DEFAULT nLin0 := 1
   DEFAULT nCol0 := 1
   DEFAULT nLin1 := -1
   DEFAULT nCol1 := -1

return ::SC_GetTextRange( ::hWnd, nLin0, nCol0, nLin1, nCol1 )

//----------------------------------------------------------------------------//

#define CFACENAME 14
#define ALTURA    1
#define BOLD      5
#define ITALIC    6
#define UNDERLINE 7

//----------------------------------------------------------------------------//

METHOD OptionSetFont() CLASS TScintilla

   local oFont, aFont

   DEFINE FONT oFont FROM USER

   if Abs( oFont:nInpHeight ) < 5
      MsgStop( "Cancelled" )
      return nil
   endif

   ::StyleSetFont( ::GetCurrentStyle(), oFont:cFaceName )
   ::StyleSetSize( ::GetCurrentStyle(), Abs( oFont:nSize ) )
   ::StyleSetBold( ::GetCurrentStyle(), oFont:lBold  )
   ::StyleSetItalic( ::GetCurrentStyle(), oFont:lItalic )
   ::StyleSetUnderline( ::GetCurrentStyle(), oFont:lUnderline )

   oFont:End()

return nil

//----------------------------------------------------------------------------//

METHOD GetCurrentStyle() CLASS TScintilla

   local nPos := ::Send( SCI_GETCURRENTPOS, 0, 0 )

return ::Send( SCI_GETSTYLEAT, nPos, 0 )

//----------------------------------------------------------------------------//

METHOD StyleSetFont( nStyle, cFontName ) CLASS TScintilla

return ::Send( SCI_STYLESETFONT, nStyle, cFontName)

//----------------------------------------------------------------------------//

METHOD StyleSetFore( nStyle, fore ) CLASS TScintilla

return ::Send( SCI_STYLESETFORE, nStyle, fore )

//----------------------------------------------------------------------------//

METHOD StyleSetBold( nStyle, bold ) CLASS TScintilla

return ::Send( SCI_STYLESETBOLD, nStyle, bold )

//----------------------------------------------------------------------------//

METHOD StyleSetItalic( nStyle, italic ) CLASS TScintilla

return ::Send( SCI_STYLESETITALIC, nStyle, italic )

//----------------------------------------------------------------------------//

METHOD StyleSetSize( nStyle, nSizePoints ) CLASS TScintilla

return ::Send( SCI_STYLESETSIZE, nStyle, nSizePoints )

//----------------------------------------------------------------------------//

METHOD StyleSetUnderline( nStyle, underline ) CLASS TScintilla

return ::Send( SCI_STYLESETUNDERLINE, nStyle, underline )

//----------------------------------------------------------------------------//

METHOD SetFixedFont() CLASS TScintilla

   ::StyleSetFont( ::GetCurrentStyle(), "Courier New" )
   ::StyleSetSize( ::GetCurrentStyle(), 12 )
   ::StyleSetBold( ::GetCurrentStyle(), .F.  )
   ::StyleSetItalic( ::GetCurrentStyle(), .F. )
   ::StyleSetUnderline( ::GetCurrentStyle(), .F. )

return nil

//----------------------------------------------------------------------------//

METHOD Print() CLASS TScintilla

   LOCAL nRecno, oFont
   local o := self

   DEFINE FONT oFont NAME "Courier New" SIZE 0,-12
            // Font sizes for PRINTING are given in "points" not pixels.
            // (Pixels are used for font width and height for SCREENS only.)
            // By using a "0" for width and a "-" in front of the "height" #
            // we tell FiveWin that we're using points instead of pixels.

            // Thus -12 means "12 point," which is used for "10 pitch"
            // non-proportionally spaced Courier type that prints at
            // 6 lines/inch.

            // -10 means a 10 point font printing at 7 lines/inch.

            // Use -9 for a "12 pitch" equal-spaced Courier font printing
            // at 8 lines per inch.


            // Note that in creating the report object, we are leaving out
            // any mention of title or header specs. because those are
            // already included in our .TXT file.
   REPORT oReport ;
          FONT oFont ;
          PREVIEW ;
          CAPTION "Text File Printout"
          //;          TO PRINTER


   COLUMN DATA " " SIZE 76  // * Trick "Data" - we're fooling Mother
                              // Nature here. The memo will go into the " ". *

   END REPORT

             // All title lines, page numbers and headings already exist in
             // our text file, so the next two code statements make sure that
             // FiveWin won't add its own title lines.
   oReport:nTitleUpLine = RPT_NOLINE
   oReport:nTitleDnLine = RPT_NOLINE
   oReport:Margin( .15, RPT_LEFT, RPT_INCHES)
   oReport:Margin( .25, RPT_TOP, RPT_INCHES)
   oReport:Margin( .25, RPT_BOTTOM, RPT_INCHES)
     // I know the top/bottom margins shown here should mathematically cause
     // more than the desired 60 lines per page to print. However, in actual
     // practice with my Panasonic KXP 4450 laser printer emulating the
     // HP LaserJet Plus, this is what I had to use to get 60 lines.  Why?
     // Inscrutible printer driver!  Maybe your printer driver functions in
     // a more mathematically logical fashion.  If so, adjust accordingly.
     // The left margin is set so small here because a margin is already
     // built into the text file itself (in this particular case).

   ACTIVATE REPORT oReport ON INIT o:SayMemo()

   oFont:End()

return nil

//----------------------------------------------------------------------------//

METHOD SayMemo() CLASS TScintilla

   LOCAL cText, cLine
   LOCAL nFor, nLines, nPageln

   cText := ::GetText()
   nLines := ::GetLineCount()
   nPageln := 0
   // oReport:BackLine(1)     // Not needed here. If used, will cause printing
                              // of subsequent pages to get out of synch by
                              // pushing the start of printing down 1 line
                              // per page.

     FOR nFor := 1 TO nLines

          cLine := ::GetLine( nFor )
          cLine := substr( cLine, 1, len( cLine ) -2 )
          cLine := strtran( cLine, chr(9),"   " )
          cLine := strtran( Str(nFor,5)," ","0") + "  " + cLine

          oReport:StartLine()
          oReport:Say(1,cLine)
          oReport:EndLine()

             // The following section checks to see if we've reached the
             // bottom of the page (60 lines). If so, it then calls
             // GetTop() to eliminate empty spaces in the text file between
             // the bottom of the outgoing page and the top line of the
             // next page.  The intent of this code is to get rid of the
             // empty lines that most report generators insert between pages
             // when output is to a text file -- otherwise our page printing
             // would get out of synch with the formating of the original
             // report. This approach only works where printing (including the
             // page number and other page heading data) is supposed to appear
             // at the same place at the top of every page.
          nPageln := nPageln + 1
          IF nPageln = 60
             nFor := GetTop(cText,nFor,nLines)
             nPageln := 0
          ENDIF

     NEXT

   // oReport:Newline()  // Only activate this line if you need to have the
                         // program eject another page upon completing printing.
return nil

//----------------------------------------------------------------------------//

static function GetTop( cText, nFor, nLines )

   local Test := .T., cLine

   while Test = .T. .AND. nFor <= nLines
      nFor := nFor + 1
      cLine := MemoLine(cText, 76, nFor)
      TEST := Empty(cLine)
   end

   nFor = nFor - 1
   SysRefresh()   // Inserted to allow Windows to catch up with housekeeping
                  // that was held up during the "DO WHILE."
return nFor

//----------------------------------------------------------------------------//

METHOD Close() CLASS TScintilla

   if ::GetModify()
      if MsgYesNo( "Save the changes ?", "File has changed" )
         ::Save()
      endif
   endif

   ::SetText( "" )
   ::cFileName = ""
   ::SetSavePoint() // unmodified state

return nil

//----------------------------------------------------------------------------//

METHOD DlgFindText() CLASS TScintilla

   local oDlg, oGet
   local cText := ::GetSelText()

   if Empty( cText )
      cText = If( Empty( ::cLastFind ), "", ::cLastFind )
   endif

   if MLcount( cText ) > 1
      cText = Trim( MemoLine( cText,, 1 ) )
   endif

   oDlg = DlgFindText( cText, Self,;
                       { | cText, lForward | If( ! ::FindText( cText, lForward ), MsgBeep(),) } )

return nil

#define VK_CTRL_F 6
#define VK_CTRL_K 11
#define VK_CTRL_DOT 190

//----------------------------------------------------------------------------//

METHOD DlgGoToLine() CLASS TScintilla

   local oDlg, nLine := ::nLine()

   DEFINE DIALOG oDlg FROM 5, 5 TO 10.2, 29 TITLE "Go To"

   @ 0.5, 2 SAY "Line:" OF oDlg
   @ 0.5, 5 GET nLine OF oDlg PICTURE "99999" SIZE 25, 11

   @ 1.3, 1.4 BUTTON "&Ok"  OF oDlg SIZE 35, 11 ;
      ACTION ( ::GotoLine( nLine ), oDlg:End() )

   @ 1.3, 8.9 BUTTON "&Cancel" OF oDlg SIZE 35, 11 ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   ::SetFocus()

return nil

//----------------------------------------------------------------------------//

METHOD KeyChar( nKey, nFlags ) CLASS TScintilla

   // ::oWnd:cTitle := "keychar" +str(nKey)

   do case
      case nKey == VK_CTRL_F
          ::DlgFindText()
          return 1

   endcase

return super:KeyChar( nKey, nFlags )

//----------------------------------------------------------------------------//

METHOD KeyDown( nKey, nFlags ) CLASS TScintilla

   local lControl := GetKeyState( VK_CONTROL )
   local lShift := GetKeyState( VK_SHIFT )
   local n, nPosKey

   // ::oWnd:cTitle := "keydown" +str(nKey)

   do case
      case nKey >= 112 .and. nKey <= 123
   	       nPosKey = Ascan( ::aKey, { | aReg | aReg[ 1 ] == nKey } )

		       if nPosKey > 0
		          Eval( ::aKey[ nPosKey ][ 2 ], Self )
		       endif

      case nKey == VK_CTRL_DOT
           ::DlgFindText()
           return 1

      case nKey == VK_UP .and. lControl
           ::cLineBuffer := ::GetLine( ::nLine() )
           return 1

      case nKey == VK_DOWN .and. lControl
           if ! Empty( ::cLineBuffer )
              n = ::GetCurrentPos()
              ::Send( SCI_HOME )
              ::InsertText( ::GetCurrentPos(), ::cLineBuffer )
              ::SetSel( n, n )
              ::GoLeft()
              ::GoRight()
           endif
           return 1

      case nKey == VK_NEXT
           ::PageDown()
           return 1

      case nKey == VK_PRIOR
           ::PageUp()
           return 1

   endcase

return super:KeyDown( nKey, nFlags )

//----------------------------------------------------------------------------//

METHOD SendAsEmail( lAttach ) CLASS TScintilla

   local oMail

   DEFAULT lAttach := .F.

   if lAttach
      DEFINE MAIL oMail ;
         SUBJECT "Envio de fichero" ;
         TEXT ::cFileName ;
         FILES ::cFileName,::cFileName ;
         FROM USER ;
         RECEIPT
   else
      DEFINE MAIL oMail ;
         SUBJECT "Envio de fichero" ;
         TEXT ::GetText() ;
         FROM USER ;
         RECEIPT
   endif

   ACTIVATE MAIL oMail

return nil

//----------------------------------------------------------------------------//

METHOD SetAStyle( style, fore, back, size, face ) CLASS TScintilla

   DEFAULT size := 0
   DEFAULT face := ""
   DEFAULT back := CLR_WHITE

   ::Send( SCI_STYLESETFORE, style, fore )
	 ::Send( SCI_STYLESETBACK, style, back )

	  if size >= 1
		   ::Send( SCI_STYLESETSIZE, style, size )
	  endif
	  if ! Empty( face )
		   ::Send( SCI_STYLESETFONT, style, face )
	  endif

return nil

//----------------------------------------------------------------------------//

METHOD Setup() CLASS TScintilla

   ::Send( SCI_SETLEXER, SCLEX_FLAGSHIP )

   ::Send( SCI_SETKEYWORDS, 0,;
       "class from data classdata method inline virtual setget endclass " + ;
       "function return " + ;
       "define activate window title valid maximized " + ;
       "buttonbar filename button size of 2007 " + ;
       "msgbar prompt keyboard " + ;
       "menu menuitem action separator endmenu mru section " + ;
       "tooltip message keyboard maximized" )

   ::Send( SCI_SETKEYWORDS, 1,;
       "local public static private " + ;
       "if else endif " + ;
       "do while endwhile end " + ;
       "do case otherwise endcase " + ;
       "super " )

   ::Send( SCI_STYLESETFONT, STYLE_DEFAULT, "Courier New" )
   ::Send( SCI_STYLESETSIZE, STYLE_DEFAULT, 12 )

	 ::Send( SCI_STYLESETFORE, STYLE_DEFAULT, CLR_BLACK )
	 ::Send( SCI_STYLESETBACK, STYLE_DEFAULT, GetSysColor( COLOR_WINDOW ) )

   ::SendMsg( SCI_SETCARETLINEBACK, RGB( 0, 179, 179 ) )
   ::SendMsg( SCI_SETCARETLINEVISIBLE, 1 )

   ::Send( SCI_STYLECLEARALL, 0, 0 )

	 ::SetAStyle( SCE_FS_COMMENTLINE, CLR_GREEN )
	 ::SetAStyle( SCE_FS_OPERATOR, CLR_HBLUE )
	 ::SetAStyle( SCE_FS_STRING, CLR_YELLOW )
	 ::SetAStyle( SCE_FS_PREPROCESSOR, CLR_MAGENTA )
 	 ::SetAStyle( SCE_FS_NUMBER, CLR_HRED )
	 ::SetAStyle( SCE_FS_KEYWORD, CLR_HGREEN )
	 ::SetAStyle( SCE_FS_KEYWORD2, CLR_HCYAN )

   //	::Send( SCI_STYLESETBOLD, SCE_FS_KEYWORD, 1 )

	 ::Send( SCI_SETSELFORE, 1, CLR_WHITE )
	 ::Send( SCI_SETSELBACK, 1, CLR_BLUE )

	 ::Send( SCI_STYLESETBACK, SCE_FS_PREPROCESSOR, GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_STRING,       GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_COMMENTLINE,  GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_OPERATOR,     GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD,      GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD2,     GetSysColor( COLOR_WINDOW ) )
	 ::Send( SCI_STYLESETBACK, SCE_FS_NUMBER,       GetSysColor( COLOR_WINDOW ) )

   ::Send( SCI_SETMARGINWIDTHN, 0, 35 )

/*

	red       := RGB( 0xFF, 0, 0 )
	offWhite  := RGB( 0xFF, 0xFB, 0xF0 )
	darkGreen := RGB( 0, 0x80, 0 )
	darkBlue  := RGB( 0, 0, 0x80 )

	// Hypertext default is used for all the document's text
	//::SetAStyle( SCE_H_DEFAULT, CLR_BLACK, CLR_WHITE, 11, "Times New Roman")
/*
# Lexical states for SCLEX_FLAGSHIP (clipper)
lex FlagShip=SCLEX_FLAGSHIP SCE_B_
val SCE_FS_DEFAULT=0
val SCE_FS_COMMENT=1
val SCE_FS_COMMENTLINE=2
val SCE_FS_COMMENTDOC=3
val SCE_FS_COMMENTLINEDOC=4
val SCE_FS_COMMENTDOCKEYWORD=5
val SCE_FS_COMMENTDOCKEYWORDERROR=6
val SCE_FS_KEYWORD=7
val SCE_FS_KEYWORD2=8
val SCE_FS_KEYWORD3=9
val SCE_FS_KEYWORD4=10
val SCE_FS_NUMBER=11
val SCE_FS_STRING=12
val SCE_FS_PREPROCESSOR=13
val SCE_FS_OPERATOR=14
val SCE_FS_IDENTIFIER=15
val SCE_FS_DATE=16
val SCE_FS_STRINGEOL=17
val SCE_FS_CONSTANT=18
val SCE_FS_ASM=19
val SCE_FS_LABEL=20
val SCE_FS_ERROR=21
val SCE_FS_HEXNUMBER=22
val SCE_FS_BINNUMBER=23

::SetAStyle( SCE_FS_STRING, CLR_YELLOW, CLR_BLUE )


	// Unknown tags and attributes are highlighed in red.
	// If a tag is actually OK, it should be added in lower case to the htmlKeyWords string.
	::SetAStyle( SCE_H_TAG, darkBlue)
	::SetAStyle( SCE_H_TAGUNKNOWN, red)
	::SetAStyle( SCE_H_ATTRIBUTE, darkBlue)
	::SetAStyle( SCE_H_ATTRIBUTEUNKNOWN, red)
	::SetAStyle( SCE_H_NUMBER, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_H_DOUBLESTRING, RGB( 0, 0x80, 0 ))
	::SetAStyle( SCE_H_SINGLESTRING, RGB( 0, 0x80, 0 ))
	::SetAStyle( SCE_H_OTHER, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_H_COMMENT, RGB( 0x80, 0x80, 0 ))
	::SetAStyle( SCE_H_ENTITY, RGB( 0x80, 0, 0x80 ))

	::SetAStyle( SCE_H_TAGEND, darkBlue)
	::SetAStyle( SCE_H_XMLSTART, darkBlue)	// <
	::SetAStyle( SCE_H_XMLEND, darkBlue)		// ?>
	::SetAStyle( SCE_H_SCRIPT, darkBlue)		// <scrip
	::SetAStyle( SCE_H_ASP, RGB( 0x4F, 0x4F, 0 ), RGB( 0xFF, 0xFF, 0 ))	// <% ... %
	::SetAStyle( SCE_H_ASPAT, RGB( 0x4F, 0x4F, 0 ), RGB( 0xFF, 0xFF, 0 ))	// <%@ ... %>

	::SetAStyle( SCE_HB_DEFAULT, black)
	::SetAStyle( SCE_HB_COMMENTLINE, darkGreen)
	::SetAStyle( SCE_HB_NUMBER, RGB( 0, 0x80, 0x80 ))
	::SetAStyle( SCE_HB_WORD, darkBlue)
	::Send( SCI_STYLESETBOLD, SCE_HB_WORD, 1)
	::SetAStyle( SCE_HB_STRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HB_IDENTIFIER, black)

	// This light blue is found in the windows system palette so is safe to use even in 256 colour modes.
	lightBlue := RGB( 0xA6, 0xCA, 0xF0 )
	// Show the whole section of VBScript with light blue background
	for n = bstyle to  SCE_HB_STRINGEOL

		::Send( SCI_STYLESETFONT, n,"Georgia")
		::Send( SCI_STYLESETBACK, n, lightBlue)
		// This call extends the backround colour of the last style on the line to the edge of the window
		::Send( SCI_STYLESETEOLFILLED, n, 1)
	next

	::Send( SCI_STYLESETBACK, SCE_HB_STRINGEOL, RGB( 0x7F, 0x7F, 0xFF))
	::Send( SCI_STYLESETFONT, SCE_HB_COMMENTLINE,"Comic Sans MS")

	::SetAStyle( SCE_HBA_DEFAULT, black)
	::SetAStyle( SCE_HBA_COMMENTLINE, darkGreen)
	::SetAStyle( SCE_HBA_NUMBER, RGB( 0, 0x80, 0x80 ))
	::SetAStyle( SCE_HBA_WORD, darkBlue)
	::Send( SCI_STYLESETBOLD, SCE_HBA_WORD, 1)
	::SetAStyle( SCE_HBA_STRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HBA_IDENTIFIER, black)

	// Show the whole section of ASP VBScript with bright yellow background
	for n = bastyle to SCE_HBA_STRINGEOL
		::Send( SCI_STYLESETFONT, n,"Georgia")
		::Send( SCI_STYLESETBACK, n, RGB( 0xFF, 0xFF, 0 ))
		// This call extends the backround colour of the last style on the line to the edge of the window
		::Send( SCI_STYLESETEOLFILLED, n, 1)
	next
	::Send( SCI_STYLESETBACK, SCE_HBA_STRINGEOL, RGB( 0xCF, 0xCF, 0x7F))
	::Send( SCI_STYLESETFONT, SCE_HBA_COMMENTLINE,"Comic Sans MS")

	// If there is no need to support embedded Javascript, the following code can be dropped.
	// Javascript will still be correctly processed but will be displayed in just the default style.

	::SetAStyle( SCE_HJ_START, RGB( 0x80, 0x80, 0 ))
	::SetAStyle( SCE_HJ_DEFAULT, black)
	::SetAStyle( SCE_HJ_COMMENT, darkGreen)
	::SetAStyle( SCE_HJ_COMMENTLINE, darkGreen)
	::SetAStyle( SCE_HJ_COMMENTDOC, darkGreen)
	::SetAStyle( SCE_HJ_NUMBER, RGB( 0, 0x80, 0x80 ))
	::SetAStyle( SCE_HJ_WORD, black)
	::SetAStyle( SCE_HJ_KEYWORD, darkBlue)
	::SetAStyle( SCE_HJ_DOUBLESTRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HJ_SINGLESTRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HJ_SYMBOLS, black)

	::SetAStyle( SCE_HJA_START, RGB( 0x80, 0x80, 0 ))
	::SetAStyle( SCE_HJA_DEFAULT, black)
	::SetAStyle( SCE_HJA_COMMENT, darkGreen)
	::SetAStyle( SCE_HJA_COMMENTLINE, darkGreen)
	::SetAStyle( SCE_HJA_COMMENTDOC, darkGreen)
	::SetAStyle( SCE_HJA_NUMBER, RGB( 0, 0x80, 0x80 ))
	::SetAStyle( SCE_HJA_WORD, black)
	::SetAStyle( SCE_HJA_KEYWORD, darkBlue)
	::SetAStyle( SCE_HJA_DOUBLESTRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HJA_SINGLESTRING, RGB( 0x80, 0, 0x80 ))
	::SetAStyle( SCE_HJA_SYMBOLS, black)

	// Show the whole section of Javascript with off white background
	for n := jstyle to SCE_HJ_SYMBOLS

		::Send( SCI_STYLESETFONT, jstyle,"Lucida Sans Unicode")
		::Send( SCI_STYLESETBACK, jstyle, offWhite)
		::Send( SCI_STYLESETEOLFILLED, jstyle, 1)
	next
	::Send( SCI_STYLESETBACK, SCE_HJ_STRINGEOL, RGB( 0xDF, 0xDF, 0x7F))
	::Send( SCI_STYLESETEOLFILLED, SCE_HJ_STRINGEOL, 1)

	// Show the whole section of Javascript with brown background
	for n := jastyle  to SCE_HJA_SYMBOLS
		::Send( SCI_STYLESETFONT, jastyle,"Lucida Sans Unicode")
		::Send( SCI_STYLESETBACK, jastyle, RGB( 0xDF, 0xDF, 0x7F))
		::Send( SCI_STYLESETEOLFILLED, jastyle, 1)
	next
	::Send( SCI_STYLESETBACK, SCE_HJA_STRINGEOL, RGB( 0x0, 0xAF, 0x5F))
	::Send( SCI_STYLESETEOLFILLED, SCE_HJA_STRINGEOL, 1)
*/
return nil

//----------------------------------------------------------------------------//

#define WM_NOTIFY             78    // 0x4E

//----------------------------------------------------------------------------//

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TScintilla

   do case
      case nMsg == WM_NOTIFY ; ::Notify( nWParam, nLParam )

	    otherwise
			   super:HandleEvent( nMsg, nWParam, nLParam )
   endcase

return nil

//----------------------------------------------------------------------------//

METHOD Notify( nIdCtrl, nPtrNMHDR ) CLASS TScintilla

   local nCode := GetNMHDRCode( nPtrNMHDR )
   local nLine, nPos

   do case
  	  case nCode == SCN_PAINTED
	    case nCode == SCN_CHARADDED	// When we add some character...
	    case nCode == SCN_MODIFIED

      case nCode == SCN_UPDATEUI
           if ::oRowItem != nil
              ::oRowItem:SetText( "Row: " + AllTrim( Str( ::nLine() ) ) )
           endif
           if ::oColItem != nil
              ::oColItem:SetText( "Col: " + AllTrim( Str( ::nCol() ) ) )
           endif
           if ::bChange != nil
              Eval( ::bChange, Self )
           endif

      case nCode == SCN_MARGINCLICK
           nPos = GetPosHdr( nPtrNMHDR )
           nLine = ::Send( SCI_LINEFROMPOSITION, nPos, 0 )
           ::MarkerAdd( nLine, 1 )
   endcase

return nil

//----------------------------------------------------------------------------//

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>
#include <commctrl.h>
#include ".\..\include\scintila.h"

static int GetHdr( LPARAM lParam )
{
   struct SCNotification * pMsg = ( struct SCNotification * )lParam;

   return ( pMsg->position );
}

HB_FUNC( GETPOSHDR )
{
   hb_retni( GetHdr( hb_parnl( 1 ) ));
}

BOOL SearchForward( HWND hWnd, LPSTR szText, int nSearchFlags ) //@parm text to search
{
   long lPos = SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 );
   TEXTTOFIND tf;

   tf.lpstrText  = szText;
   tf.chrg.cpMin = lPos + 1;
   tf.chrg.cpMax = SendMessage( hWnd, SCI_GETLENGTH, 0, 0 );

   lPos = SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );

   if( lPos > 0 )
   {
      SetFocus( hWnd );
      SendMessage( hWnd, SCI_GOTOPOS, lPos, 0 );
      SendMessage( hWnd, SCI_SETSEL, tf.chrgText.cpMin, tf.chrgText.cpMax );
      return TRUE;
   }

   return FALSE;
}

/////////////////////////////////////
// @mfunc Search backward for a given string and select it if found. You may use regular expressions on the text.
// @rvalue BOOL | TRUE if text is ffound else FALSE
//
BOOL SearchBackward( HWND hWnd, LPSTR szText, int nSearchFlags ) //@parm text to search
{
   int lPos;
   int lMinSel;
   TEXTTOFIND tf;

   if ( szText == NULL)
      return FALSE;

   lPos = SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 );
   lMinSel = SendMessage( hWnd, SCI_GETSELECTIONSTART, 0, 0 );
   tf.lpstrText = szText;

   if( lMinSel >= 0 )
      tf.chrg.cpMin = lMinSel-1;
   else
      tf.chrg.cpMin = lPos-1;

   tf.chrg.cpMax = 0;
   lPos = SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );

   if( lPos >= 0 )
   {
      SetFocus(hWnd);
      SendMessage( hWnd, SCI_GOTOPOS, lPos, 0 );
      SendMessage( hWnd, SCI_SETSEL, tf.chrgText.cpMin, tf.chrgText.cpMax );
      SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );
      return TRUE;
   }
   return FALSE;
}

HB_FUNC( SC_ADDTEXT )
{
   hb_retnl( SendMessage( ( HWND ) hb_parnl( 1 ), SCI_ADDTEXT, hb_parclen( 2 ), ( LPARAM ) hb_parc( 2 ) ) );
}

HB_FUNC( SCI_OPENFILE )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   char * fileName = ( char * ) hb_parc( 2 );
   char data[ 131072 ];
   FILE * fp;
   int lenFile;

   // SendMessage( hWnd, SCI_CLEARALL, 0, 0 );
   SendMessage( hWnd, EM_EMPTYUNDOBUFFER, 0, 0 );
   SendMessage( hWnd, SCI_SETSAVEPOINT, 0, 0 );
   SendMessage( hWnd, SCI_CANCEL, 0, 0 );
   SendMessage( hWnd, SCI_SETUNDOCOLLECTION, 0, 0 );

   fp = fopen(fileName, "rb");
   if( fp )
   {
      lenFile = fread(data, 1, sizeof(data), fp);

      while( lenFile > 0 )
      {
         SendMessage( hWnd, SCI_ADDTEXT, lenFile, (LPARAM) data );
         lenFile = fread(data, 1, sizeof(data), fp);
      }

      fclose(fp);
   }
   else
   {
      MessageBox( 0, "Can't open the file", "Attention", MB_OK );
   }

   SendMessage( hWnd, SCI_SETUNDOCOLLECTION, 1, 0 );
   SetFocus( hWnd );
   SendMessage( hWnd, EM_EMPTYUNDOBUFFER, 0, 0 );
   SendMessage( hWnd, SCI_SETSAVEPOINT, 0, 0 );
   SendMessage( hWnd, SCI_GOTOPOS, 0, 0 );

   hb_ret();
}

HB_FUNC( SCIGETTEXT )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   int wLen = SendMessage( hWnd, SCI_GETLENGTH, 0, 0 );
   char * buffer = ( char * ) hb_xgrab( wLen + 1 );

   SendMessage( hWnd, SCI_GETTEXT, wLen + 1, ( LPARAM ) buffer );

   hb_retclen( ( char * ) buffer, wLen );
   hb_xfree( buffer );
}

HB_FUNC( SCIGETLINE )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   int nLine = hb_parni( 2 )-1;
   int wLen;
   BYTE * pbyBuffer;
   wLen = SendMessage( hWnd, SCI_LINELENGTH, nLine, 0 );
   if( wLen )
   {
      pbyBuffer = ( char * ) hb_xgrab( wLen+1 );
      SendMessage( hWnd, SCI_GETLINE, nLine, (LPARAM) pbyBuffer );
      hb_retclen( ( char * ) pbyBuffer, wLen );
      hb_xfree( pbyBuffer );
   }
   else
      hb_retc("");
}

HB_FUNC( SC_ISREADONLY )
{
   hb_retl( SendMessage( (HWND) hb_parnl( 1 ), SCI_GETREADONLY, 0, 0 ) );
}

HB_FUNC( SEARCHFORWARD )
{
   hb_retl( SearchForward( ( HWND ) hb_parnl( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( SEARCHBACKWARD )
{
    hb_retl( SearchBackward( ( HWND ) hb_parnl( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( SCIGETSELTEXT )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   int wSize = hb_parnl( 2 );
   char * cBuff = ( char * ) hb_xgrab( wSize + 1 );

   SendMessage( hWnd, SCI_GETSELTEXT, ( WPARAM ) 0, ( LPARAM ) cBuff );

   hb_retclen( cBuff, wSize );
   hb_xfree( cBuff );
}

#pragma ENDDUMP