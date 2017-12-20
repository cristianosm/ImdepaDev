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

	If INCLUI // 02/08/2016 - Agostinho Lima - Busca proximos codigos disponiveis com 8 caracters ou 13 caracteres com letra no final

		AAdd(aButtons,{ 'PRODUTO',{| |  U_BUSP8C() }, 'Busca um codigo de produto novo no formato de 8 caracteres','Codigo Novo Seq. 8 Car.' } )
		AAdd(aButtons,{ 'PRODUTO',{| |  U_BUSP13C() }, 'Busca um codigo de produto novo no formato de 13 caracteres','Codigo Novo Seq. 13 Car.' } )

	Endif



Return (aButtons)


*****************************************
User Function BUSP8C() // 02/08/2016 - Agostinho Lima - busca proximo codigo disponivel com 8 caracteres
*****************************************

	Local aAreaAnt := GetArea()
	Local cQuery := ""

	cQuery := "SELECT MAX(B1_COD) CODIGO FROM "+RetSqlName("SB1")+" WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+XFILIAL("SB1")+"' AND  LENGTH (TRIM(B1_COD)) = 8 AND SUBSTR(B1_COD,1,1) = '0' "

	U_ExecMySql(cQuery,"TP01","Q")

	M->B1_COD := STRZERO(VAL(TP01->CODIGO)+1,8)
	M->B1_CODBAR := M->B1_COD

	TP01->(DBCloseArea())

	RestArea(aAreaAnt)

Return()

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
