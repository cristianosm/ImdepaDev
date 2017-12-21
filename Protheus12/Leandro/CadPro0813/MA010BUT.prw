#Include "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA010BUT  ºAutor  ³Edivaldo Goncalves  º Data ³  17/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para adicionar um botao na Tela de Cadastroº±±
±±º          ³de Produtos , acessando a Extensão do Cadastro              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Produtos                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA010BUT()


	Local aButtons := {} // botões a adicionar

	AAdd(aButtons,{ 'PRODUTO',{| |  U_EXTENCB1() }, 'Extensão Cadastro Produtos','Ext.Prod' } )

	//If INCLUI // 02/08/2016 - Agostinho Lima - Busca proximos codigos disponiveis com 8 caracters ou 13 caracteres com letra no final
	//	AAdd(aButtons,{ 'PRODUTO',{| |  U_BUSP8C() }, 'Cadastrar Novo Codigo de 8 Caracteres','Novo Cod. 8 Carac.' } )
	//	AAdd(aButtons,{ 'PRODUTO',{| |  U_BUSP13C() }, 'Cadastrar Novo Codigo de 13 Caracteres','Novo Cod. 13 Carac.' } )
	//Endif

Return (aButtons)


*****************************************
User Function BUSCPROD() // 02/08/2016 - Agostinho Lima - busca proximo codigo disponivel com 8 caracteres
*****************************************
	
	Local aAreaAnt 	:= GetArea()
	Local cQuery 	:= ""
	Local cNewCod	:= ""      
	Local nTamCod   := Len( AllTrim( SB1->B1_COD ) ) 
	
	/*
	Alert( "ProcName (0) " + ProcName(0) )
	Alert( "ProcName (1) " + ProcName(1) )
	Alert( "ProcName (2) " + ProcName(2) )
	Alert( "ProcName (3) " + ProcName(3) )
	Alert( "ProcName (4) " + ProcName(4) )
	Alert( "ProcName (5) " + ProcName(5) )
	Alert( "ProcName (6) " + ProcName(6) )
	*/
	
	//Alert(SB1->B1_COD)
	
	If nTamCod == 8
		// 8 Caracteres
		cQuery := "SELECT TRIM(MAX(B1_COD)) CODIGO FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+XFILIAL("SB1")+"' AND  LENGTH (TRIM(B1_COD)) = '" + cValToChar(nTamCod) + "' AND SUBSTR(B1_COD,1,1) = '0' "
	ElseIf nTamCod == 13 // 13 Caracteres 
		cQuery := "SELECT TRIM(MAX(B1_COD)) CODIGO FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + XFILIAL("SB1") + "' AND  LENGTH (TRIM(B1_COD)) = '" + cValToChar(nTamCod) + "' AND SUBSTR(B1_COD,1,1) = '0' "
		cQuery += " AND SUBSTR(TRIM(B1_COD),'" + cValToChar(nTamCod) + "',1) NOT IN('0','1','2','3','4','5','6','7','8','9') AND SUBSTR(B1_COD,5,1) <> 'V' "
	EndIf
	
	U_ExecMySql(cQuery,"TP01","Q")

	cNewCod := StrZero( Val( TP01->CODIGO ) + 1 , nTamCod ) 
	
	TP01->( DbCloseArea() )

	RestArea(aAreaAnt)

Return ( cNewCod )
/*
*****************************************
User Function BUSP13C() // 02/08/2016 - Agostinho Lima - busca proximo codigo disponivel com 13 caracteres com letra no final
*****************************************

	Local aAreaAnt := GetArea()
	Local cQuery := ""
    Local nTamCod := TAMSX3("B1_COD")[1]
    Local cCodigo := ""

	cQuery := "SELECT MAX(B1_COD) CODIGO FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+XFILIAL("SB1")+"' AND  LENGTH (TRIM(B1_COD)) = 13 AND SUBSTR(B1_COD,1,1) = '0' "
    cQuery += " AND SUBSTR(TRIM(B1_COD),13,1) NOT IN('0','1','2','3','4','5','6','7','8','9') AND SUBSTR(B1_COD,5,1) <> 'V' "

	U_ExecMySql(cQuery,"TP01","Q")

	cCodigo := TP01->CODIGO

	M->B1_COD := STRZERO(VAL(SUBSTR(cCodigo,1,12))+1,12)+ SPACE(nTamCod - 12)
	M->B1_CODBAR := M->B1_COD

	TP01->(DBCloseArea())

	RestArea(aAreaAnt)

Return()
