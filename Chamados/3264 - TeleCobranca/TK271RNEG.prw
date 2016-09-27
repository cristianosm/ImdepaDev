#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

#Define TELECOBRANCA '3'




/*
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHLHH
HHHFunHao    |TK271RN     |Autor  | Rafael                |Data  |09.03.2015 HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHJHH
HHHDescriHao |ARRAY CONTEM REGRAS DE NEGOCIO QUE O CLIENTE SE ENCAIXA		 HHH
HH|          |aImdCodR UTILIZADO NO PE QUE FAZ A AVALICAO DAS RN (FT100RNI)  HHH
HH|          |                                                               HHH
HH|          |BUSCA CABE DAS RN QUE O CLIENTE PODE SE ENCAIXAR               HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHJHH
HHHOBS.:     |CHAMADO NO PE. TK271BOK (PE NA CONFIRMACAO DO ATENDIMENTO)     HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHJHH
HHHUso       |IMDEPA                                                         HHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHIH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
************************************************************************
User Function TK271RN()
************************************************************************
//IMDRegNg(cCliente,cLoja,cTabPreco,cCondPg,cFormPg,aProdDesc,lHelp,cCodVen,lVerBlqReg,lBlAlagoas)

Local cCliente 	:= ""
Local cLoja		:= ""
Local cTabPreco	:= ""
Local cCondPg	:= ""
Local cFormPg	:= ""
Local cClasVE	:= ""
Local cGrpVen	:= ""
Local cVinculo	:= ""
Local cquery	:= ""

Local cHoraAtual := Left( Time(), 5 )
Local cDtHrAtual := DToS( dDataBase ) + cHoraAtual
Local cDataAtual := DToS( dDataBase )
Local cDataVazia := ""


Local dDataVazia := CToD( "" )

If TkGetTipoAte() == TELECOBRANCA //| CHAMADO: 3264 - Testes telecobranca 
	Return()
EndIF

cCliente 	:= M->UA_CLIENTE
cLoja		:= M->UA_LOJA
cTabPreco	:= M->UA_TABELA
cCondPg		:= M->UA_CONDPG
cFormPg		:= M->UA_FORMPG
cDataVazia  := Space( Len( DToS( ACS->ACS_DATATE ) ) )
//| FIM - CHAMADO: 3264

//Array que guarda as regras que o cliente se encaixa
// Public aImdCodR := {}
 aImdCodR := {}



DBSelectArea("SA1");DBSetOrder(1);DbGoTop()
If DBSeek(xFilial("SA1")+cCliente+cLoja)
	cClasVE  := SA1->A1_CLASVEN
	cGrpVen  := SA1->A1_GRPVEN
	cVinculo := SA1->A1_VINCULO
EndIf

//AGORA FAZ A BUSCA DA REGRA PRA GUARDAR NA VARIAVEL PUBLICA aImdCodR
cQuery := " SELECT 	ACS_CODREG 			"+ENTER
cQuery += " FROM 	"+RetSqlName("ACS")+" 	"+ENTER
cQuery += " WHERE 	ACS_FILIAL 	= '"+xFilial('ACS')+"'					"+ENTER
cQuery += " AND  	(ACS_CODCLI = '' OR ACS_CODCLI 	= '"+cCliente+"') 	"+ENTER
cQuery += " AND		(ACS_LOJA 	= '' OR ACS_LOJA 	= '"+cLoja+"') 		"+ENTER	
cQuery += " AND		( ( ACS_TPHORA ='1' AND ('" + cDataAtual + "'>ACS_DATDE OR ('" + cDataAtual + "'=ACS_DATDE AND '" + cHoraAtual + "'>=ACS_HORDE ) ) AND "
cQuery += " ( ACS_DATATE='" + cDataVazia +"' OR ('" + cDataAtual + "'<ACS_DATATE OR ('" + cDataAtual + "'=ACS_DATATE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) ) ) OR "
cQuery += "( ACS_TPHORA='2' AND '" + DToS( dDatabase ) + "'>=ACS_DATDE AND ( ACS_DATATE='" + cDataVazia +"' OR "
cQuery += "'" + DToS( dDataBase ) + "'<=ACS_DATATE ) AND '" + cHoraAtual + "'>=ACS_HORDE AND '" + cHoraAtual + "'<=ACS_HORATE ) ) AND "
cQuery += "D_E_L_E_T_ != '*'"

//MemoWrit(GetTempPath()+'TK271RNEG.TXT', cQuery )
cQuery := ChangeQuery( cQuery )
dbUseArea (.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

Do While !TMP->(Eof())
	If Ascan(aImdCodR, TMP->ACS_CODREG) == 0
		Aadd(aImdCodR, TMP->ACS_CODREG)
	EndIf
	DbSkip()
EndDo
                    

TMP->(DBCloseArea())
Return()