#Include "TOPCONN.CH"
#include "rwmake.ch"        
#INCLUDE "PROTHEUS.CH"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FIXAPICK บAutor ณEdivaldo Gon็alves   บ Data ณ  09/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Fixar o produto a um determinado enderereco    บฑฑ
ฑฑบ          ณ de PICKING                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ WMS - ENDERECO DE ITENS TIPO PICKING                       บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ                           
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FIXAPICK()  

cMens := OemToAnsi('ROTINA PARA FIXAR O PRODUTO A UM ENDEREวO DE PICKING')+chr(13)+chr(13)
cMens := cMens+ OemToAnsi('ศ recomendado o processamento em modo Exclusivo !!!')+chr(13)+chr(13)
cMens := cMens+OemToAnsi('---------------[Estruturas Considerada]---------------')+chr(13)

	   
 cQuery :=" SELECT DISTINCT BF_ESTFIS,DC8_DESEST " 
 cQuery +=" FROM " 
 cQuery +=RetSqlName( "SBF" ) + " SBF, "+RetSqlName( "DC8" )+ " DC8 "
 cQuery +=" WHERE " 
 cQuery +=" BF_FILIAL = '" + xFilial("SBF") + "'"
 cQuery +=" AND DC8_FILIAL = '" + xFilial("DC8") + "'"
 cQuery +=" AND DC8_CODEST=BF_ESTFIS "
 cQuery +=" AND DC8_TPESTR='2' "
 cQuery +=" AND SBF.BF_QUANT<>0 "
 cQuery +=" AND SBF.BF_LOCAL <> '10' "
 cQuery +=" AND SBF.D_E_L_E_T_<>'*' "
 cQuery +=" AND DC8.D_E_L_E_T_<>'*' "
 
 dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_SBFDC8",.F.,.T.)  
  
 DBSELECTAREA("QRY_SBFDC8")
 DBGOTOP() 
 
  If QRY_SBFDC8->(EOF())
	IW_MsgBox("O Sistema nใo localizou nenhum endereco de produtos com estrutura tipo Picking !!!","FIXA PICKING","INFO")
	QRY_SBFDC8->(DBCloseArea())
	Return
Else

 While QRY_SBFDC8->( !Eof() )
 
 cMens :=cMens+ OemToAnsi( QRY_SBFDC8->BF_ESTFIS+' - '+QRY_SBFDC8->DC8_DESEST)+chr(13)
 
 DbSkip()
 
 End 
 cMens := cMens+chr(13)
 cMens := cMens+OemToAnsi('VOCE CONFIRMA O PROCESSAMENTO ?')
 
QRY_SBFDC8->(DBCloseArea())

If  MsgYesNo(cMens,'FIXA PICKING') 

   //Solicitado pelo S้rgio para Manter os Picking jแ fixo
  //	Processa( {|| DesfixaPicking() }, 'Fixa Picking', 'Processo 1 : Desfixando todos os pickings...' ) 
   If cFilAnt = "05"
    	Processa( {|| DesfixaPicking() }, 'Fixa Picking', 'Processo 1 : Desfixando todos os pickings...' ) 
   Endif
   
	Processa( {|| FixaPicking()    }, 'Fixa Picking', 'Processo 1 : Fixando picking...' ) 
	
     		
	EndIf
    
	   

Endif
Return

Static Function FixaPicking()

 cQuery :=" SELECT BF_FILIAL,BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,BF_ESTFIS " 
 cQuery +=" FROM " 
 cQuery +=RetSqlName( "SBF" ) + " SBF, "+RetSqlName( "DC8" )+ " DC8 "
 cQuery +=" WHERE " 
 cQuery +=" BF_FILIAL = '" + xFilial("SBF") + "'"
 cQuery +=" AND DC8_FILIAL= '" + xFilial("DC8") + "'"
 cQuery +=" AND DC8_CODEST=BF_ESTFIS "
 cQuery +=" AND DC8_TPESTR='2' "  
 cQuery +=" AND SBF.BF_LOCAL <> '10' "
 cQuery +=" AND SBF.D_E_L_E_T_<>'*' "
 cQuery +=" AND DC8.D_E_L_E_T_<>'*' "
 cQuery +=" ORDER BY BF_LOCALIZ,BF_PRODUTO "
 
 dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_SBFDC8",.F.,.T.) 
 
 ProcRegua( QRY_SBFDC8->( LastRec() ) ) 
 
 While QRY_SBFDC8->( !Eof() )
 
  cSql := " UPDATE "+RetSqlName('SBE') 
  cSql += " SET BE_CODPRO ='"+QRY_SBFDC8->BF_PRODUTO+"',"
  cSql += " BE_STATUS='2'"
  cSql += " WHERE BE_FILIAL= '" + xFilial( 'SBE' ) + "'"
  cSql += " AND BE_LOCALIZ = '"+QRY_SBFDC8->BF_LOCALIZ +"'"
  //cSql += " AND BE_LOCAL   = '"+QRY_SBFDC8->BF_LOCAL +"'"
  cSql += " AND D_E_L_E_T_<>'*'"
  TCSQLExec( cSql )
  TCSQLExec('COMMIT')
 
   Dbskip() 
  IncProc( 'Fixando Picking ' + Alltrim(QRY_SBFDC8->BF_LOCALIZ)+'...')
 
 End

QRY_SBFDC8->(DBCloseArea())  
 
 IW_MsgBox("Processo finalizado com sucesso !","Fixa Picking","INFO")

Return


Static Function DesfixaPicking()

cSql := " UPDATE "+RetSqlName('SBE') 
cSql += " SET BE_CODPRO = ' ',BE_STATUS='1' WHERE BE_FILIAL= '" + xFilial( 'SBE' ) + "'"
cSql += " AND BE_STATUS <> '3'"   
cSql += " AND D_E_L_E_T_<> '*'"
TCSQLExec( cSql )
TCSQLExec('COMMIT')

Return