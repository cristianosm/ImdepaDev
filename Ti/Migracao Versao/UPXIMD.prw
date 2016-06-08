#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

#DEFINE MSGUP1    "A rotina de update não pode ser executada em modo MDI."+ENTER+"Favor executar o sistema em modo SDI para efetuar a atualização."+ENTER+"Exemplo: Executar 'SIGACOM' a partir do SmartClient."
#DEFINE MSGUP2    "Favor atualizar o ambiente."
#DEFINE MSGUP3    "Update de Dicionarios de Importação. Esta rotina deve ser utilizada em modo exclusivo.Faça um backup dos dicionários e da Base de Dados antes da atualização."
#DEFINE MSGUP5    "Não foi possível a abertura da tabela de empresas de Forma exclusiva."
#DEFINE MSGUP6    "Ocorreu um erro desconhecido durante a atualizacao da tabela : "
#DEFINE MSGUP7    ". Ver'ifique a integridade do dicionario e da tabela."
#DEFINE MSGUP8    "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "

//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa Rolamentos
//|Funcao....: U_UPXIMD
//|Autor.....: Armando M. Urzum - armando@urzum.com.br
//|Data......: 27 de Outubro de 2009, 22:50
//|Uso.......: SIGAEIC
//|Versao....: Protheus - 8        `
//|Descricao.: Faz o update dos campos de importação
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
User Function UPXIMD(lxAmb)
*-----------------------------------------*

Private aArqUpd	 := {}
Private aEmpres  := {}
Private oTela    := Nil
Private cMsg
Private lGera
Private cLogTxt  := ""
Private lMenu    := .F.

Private lPassou := .F.

Default lxAmb    := .F.

Begin Sequence

If SetMdiChild()
	MsgStop(MSGUP1, "Atenção")
	Final(MSGUP2)
	Break
EndIf

lGera := MsgYesNo(MSGUP3,"Atenção")

If !lxAmb
	Set Dele On
	cArqEmp := "SigaMat.Emp"
	__cInterNet := Nil
	
	Define Window oTela From 0,0 to 600,800 Title "Atualização do Dicionário 'Importação'"
	
	Activate Window oTela  On Init Iif(lGera,( Processa({|lEnd| UZXProc(@lEnd)} ),Final("Atualização efetuada.")),oTela:End())
Else
	If lGera
		Processa({|lEnd| UZXProc(@lEnd)}, "Processando", "Aguarde , Processando Preparação dos Arquivos", .F.)
	EndIf
EndIf

End Sequence

Return lGera

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZXProc()
//|Descricao.: Processo de Update
//|Uso.......: U_UZXDIRARQ
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZXProc
*-----------------------------------------*

//Begin Sequence
If UZXSM0Exc()
	For hj := 1 To Len(aEmpres)
		SM0->(dbGoto(aEmpres[hj,1]))
		
		RpcSetType(2)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
		
		lMsFinalAuto := .F.
		
		//dbSelectArea("SX2")
		SX2->(dbGoTop())
		SX2->(dbSetOrder(1))
		While SX2->(!EOF()) 
			If SX2->X2_CHAVE >= "EF0" .AND. SX2->X2_CHAVE <= "EFZ"
				aAdd(aArqUpd,SX2->X2_CHAVE)
			EndIf
			SX2->(dbSkip())
		EndDo

		SX2->(dbGoTop())
		SX2->(dbSetOrder(1))
		While SX2->(!EOF()) 
			If SX2->X2_CHAVE >= "SW0" .AND. SX2->X2_CHAVE <= "SYZ"
				If SX2->X2_CHAVE <> "SY7"
					aAdd(aArqUpd,SX2->X2_CHAVE)
				EndIf
			EndIf
			SX2->(dbSkip())
		EndDo

		//aAdd(aArqUpd,"SC7")				

		__SetX31Mode(.F.)
		For kl := 1 To Len(aArqUpd)
			IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[kl]+"]")
			chkFile(aArqUpd[kl])
			If Select(aArqUpd[kl])>0
				DbSelectArea(aArqUpd[kl])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[kl])
			If __GetX31Error()
				Alert(__GetX31Trace())
				MsgInfo("Atencao: "+MSGUP6+aArqUpd[kl]+MSGUP7,"Erro")
			EndIf
		Next kl

		MsgInfo("Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+"Atualizada com sucesso!")
				
		RpcClearEnv()
			
	Next hj
	
EndIf

//End Sequence

Return .T.

//+-----------------------------------------------------------------------------------//
//|Funcao....: UZXSM0Exc
//|Descricao.: Abre Sigamat.emp exclusivo
//|Uso.......: U_UZXDIRARQ
//|Observação:
//+-----------------------------------------------------------------------------------//
*-----------------------------------------*
Static Function UZXSM0Exc()
*-----------------------------------------*

Local nInc
Local lAbre := .F.
Local nLoop := 0

Begin Sequence

If Select("SM0") > 0
	For nInc := 1 To 255
		DbSelectArea(nInc)
		If !Used()
			Exit
		EndIf
		DbCloseArea()
	Next
EndIf

For nLoop := 1 To 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )
	If !Empty(Select("SM0"))
		lAbre := .T.
		DbSetIndex("SIGAMAT.IND")
		Exit
	EndIf
	Sleep(500)
Next nLoop

If !lAbre
	Aviso("Atencao",MSGUP5, { "Ok" }, 2 )
Else
	dbSelectArea("SM0")
	SM0->(dbGoTop())
	While SM0->(!EOF())
		If Ascan(aEmpres,{ |x| x[2] == SM0->M0_CODIGO}) == 0
			If SM0->M0_CODIGO == "01"
				aAdd(aEmpres,{SM0->(Recno()),SM0->M0_CODIGO})
			EndIf
		EndIf
		SM0->(dbSkip())
	EndDo
EndIf

End Sequence

Return(lAbre)
