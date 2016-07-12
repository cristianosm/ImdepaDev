#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄż±±
±±łFun‡ao    |TK271RN     |Autor  | Rafael                |Data  |09.03.2015 ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łDescri‡ao |ARRAY CONTEM REGRAS DE NEGOCIO QUE O CLIENTE SE ENCAIXA		 ł±±
±±|          |aImdCodR UTILIZADO NO PE QUE FAZ A AVALICAO DAS RN (FT100RNI)  ł±±
±±|          |                                                               ł±±
±±|          |BUSCA CABE DAS RN QUE O CLIENTE PODE SE ENCAIXAR               ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łOBS.:     |CHAMADO NO PE. TK271BOK (PE NA CONFIRMACAO DO ATENDIMENTO)     ł±±
±±ĂÄÄÄÄÄÄÄÄÄÄĹÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±łUso       |IMDEPA                                                         ł±±
±±ŔÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
************************************************************************
User Function TK271RN()
************************************************************************
//IMDRegNg(cCliente,cLoja,cTabPreco,cCondPg,cFormPg,aProdDesc,lHelp,cCodVen,lVerBlqReg,lBlAlagoas)

Local cCliente 	:= M->UA_CLIENTE
Local cLoja		:= M->UA_LOJA
Local cTabPreco	:= M->UA_TABELA
Local cCondPg	:= M->UA_CONDPG
Local cFormPg	:= M->UA_FORMPG
Local cClasVE	:= ""
Local cGrpVen	:= ""
Local cVinculo	:= ""
Local cquery	:= ""

Local cHoraAtual := Left( Time(), 5 )
Local cDtHrAtual := DToS( dDataBase ) + cHoraAtual
Local cDataAtual := DToS( dDataBase )
Local cDataVazia := Space( Len( DToS( ACS->ACS_DATATE ) ) )


Local dDataVazia := CToD( "" )

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