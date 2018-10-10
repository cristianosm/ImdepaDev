#include 'protheus.ch'
#include 'parmtype.ch'


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : F200IMP.prw | AUTOR : Cristiano Machado | DATA : 09/10/2018    **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: PE F200IMP Permite a Gravação de dados adicionais no momento do**
**          : recebimento do arquivo em comunicacao bancaria/retorno cobrança**
**---------------------------------------------------------------------------**
** MOTIVO : Erro no Retorno CNAB. Movimento totalizador jah vem marcado como **
**        : contabilizado no SE5 e FK5. Aqui vamos remover esta marca.       **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
******************************************************************************
User function F200IMP()
******************************************************************************	
	
	Local cBanco  	:= Alltrim(mv_par06)
	Local cAgencia	:= Alltrim(mv_par07)
	Local cConta  	:= Alltrim(mv_par08)

	If nTotAGer > 0 // nTotAGer -> Total Geral Processado no Retorno CNAB ...
	
		// Em caso de Processamento... Localiza o Totalizador CNAB para Limpar o ERRO Totvs de 
		cSql := "SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_IDORIG, R_E_C_N_O_ FROM SE5010 
		cSql += "WHERE E5_LOTE = '"+SEE->EE_LOTE+"' 
		cSql += "AND E5_HISTOR LIKE '%Lote "+SEE->EE_LOTE+"%' 
		cSql += "AND E5_BANCO = '"+cBanco+"' 
		cSql += "AND E5_AGENCIA = '"+cAgencia+"' 
		cSql += "AND E5_CONTA = '"+cConta+"'
		cSql += "AND D_E_L_E_T_ = ' ' "
	
		U_ExecMySql( cSql , cCursor := "CNAB", cModo := "Q", lMostra := .F., lChange := .F.)
		//MsgAlert(cMsg)
	
		DbSelectArea("CNAB");DbGotop()
		If !EOF()
			
			aAreaSE5 := SE5->( GetArea() )
				
			DbSelectArea("SE5")
			DbGoto(CNAB->R_E_C_N_O_)
			
			If RecLock("SE5",.F.)
				SE5->E5_LA = Space(2)
				MsUnlock()

				cSql := "Update FK5010 Set FK5_LA = ' ' WHERE FK5_IDMOV = '"+CNAB->E5_IDORIG+"' "
				U_ExecMySql( cSql , cCursor := "", cModo := "E", lMostra := .F., lChange := .F.)
			
				ConOut("!! Ajustou Totalizador CNAB!!")
				
			EndIf
			
			RestArea(aAreaSE5)
		
		EndIf
		
		DbSelectArea("CNAB");DbCloseArea()
		
	EndIf
	
	
Return Nil

