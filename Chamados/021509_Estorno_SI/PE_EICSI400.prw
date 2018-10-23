#include 'protheus.ch'
#include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : EICSI400.prw | AUTOR : Cristiano Machado | DATA : 18/10/2018   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Foi disponibilizado o ponto de entrada no programa EICSI400    **
**          : com o parâmetro "EILinok" que possibilita a customização da    **
**          : validação da linha de itens da Solicitação de Importação.      **
**---------------------------------------------------------------------------**
** USO : Especifico para Desvincular a Solicitacao do Comprar da Solicitacao **
**     : de Importacao quando a SI eh estornada.                             **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function EICSI400() // PE Easy Importa Control na Rotina de Manutencao da SI EICSI400 
*******************************************************************************
	Local cParam := ""
	Local cNumSI := "" 
	Local cNumSC := "" 
	Local DelSI  := ""
	Local lRet	 := Nil
	
	If ValType(ParamIXB) == "C"      
		cParam := Alltrim(ParamIXB)
	EndIf


	If cParam == "ANTES_TELA_EXCLUI"
		
		cNumSI := SW0->W0__NUM
		cNumSC := SW0->W0_C1_NUM
		
		AjustaSC( cNumSI, cNumSC )
	
	ElseIf cParam == "GRV_EXCLUI" // Só executa na Exclusao/Estorno da SI
		
		cNumSI := SW0->W0__NUM
		cNumSC := SW0->W0_C1_NUM
	
		EstornaSC( cNumSI, cNumSC )
	
		lRet := .T.
		
	EndIf

	
Return lRet
*******************************************************************************
Static Function AjustaSC( cNumSI, cNumSC ) // Ajusta a Solicitacao de Compras para que possa ser estornada... 
*******************************************************************************
	Local cSql := ""
	
	cSql += "UPDATE SC1010 SET C1_COTACAO = 'IMPORT' "
	cSql += "WHERE R_E_C_N_O_ IN (	SELECT R_E_C_N_O_ FROM SC1010  "
	cSql += "						WHERE C1_FILIAL = '  ' "
	cSql += "						AND   C1_NUM 	= '"+cNumSC+"'  " // --> W0_C1_NUM
	cSql += "						AND   C1_NUM_SI = '"+cNumSI+"'  " // --> W0__NUM
	cSql += "						AND   C1_FILENT = '"+cFilAnt+"' " // --> W0__CC
	cSql += "						AND   C1_COTACAO<>'IMPORT' "
	cSql += "					) "
	
	U_ExecMySql( cSql , "" , "E", lMostra := .F., lChange := .F.)

Return Nil
*******************************************************************************
Static Function EstornaSC( cNumSI, cNumSC ) // Estorna a Solicitacao de Compras
*******************************************************************************
	Local cSql := ""
	
	cSql += "UPDATE SC1010 SET C1_NUM_SI = ' ' "
	cSql += "WHERE R_E_C_N_O_ IN (	SELECT R_E_C_N_O_ FROM SC1010  "
	cSql += "						WHERE C1_FILIAL = '  ' "
	cSql += "						AND   C1_NUM 	= '"+cNumSC+"'  " // --> W0_C1_NUM
	cSql += "						AND   C1_NUM_SI = '"+cNumSI+"'  " // --> W0__NUM
	cSql += "						AND   C1_FILENT = '"+cFilAnt+"' " // --> W0__CC
	//cSql += "					    AND   C1_COTACAO= 'IMPORT' "
	cSql += "					) "
	
	U_ExecMySql( cSql , "" , "E", lMostra := .F., lChange := .F.)

Return Nil