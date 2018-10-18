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
User Function EICSI400() // PE Easy Importa Control na Rotina de Manutencao da SI
*******************************************************************************
	Local cParam := ""
	Local cNumSI := "" 
	Local cNumSC := "" 
	
	If ValType(ParamIXB) == "C"      
		cParam := Alltrim(ParamIXB)
	EndIf

	If cParam == "DEPOIS_ESTORNO"
			
			cNumSI := SW0->W0__NUM
			cNumSC := SW0->W0_C1_NUM
			
		If Iw_MsgBox("Deseja desvincular a SC ["+cNumSC+"] da SI ["+cNumSI+"] ?","Estorno","YESNO")
		
			EstornaSC( cNumSI, cNumSC )
		
		EndIf
		
	EndIf

	
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
	cSql += "					) "
	
	U_ExecMySql( cSql , "" , "E", lMostra := .F., lChange := .F.)

Return Nil