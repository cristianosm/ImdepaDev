#include 'protheus.ch'
#include 'parmtype.ch'

#Define _HORA 	"H"
#Define _DATA 	"D"
#Define _DTVZ   "  /  /  "
#Define _HRVZ   "  :  "

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : F3AC8CRM    | AUTOR : Cristiano Machado  | DATA : 15/12/2016   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Monta a Pesquisa F3 para o Campo AD8->AD8_CONTATO devido a     **
**          : necessidade de regras especificas e multi tabelas .            **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Imdepa Rolamentos                    **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function VALCPOAD8(cQuem)
*******************************************************************************

	Local lRetVal := .T.
	Local xValCpo := &(__ReadVar)

	Private nPCData := Ascan(aHeader,{|x| Alltrim(x[2]) == "AD8_DTREMI"})
	Private nPCHora := Ascan(aHeader,{|x| Alltrim(x[2]) == "AD8_HRREMI"})
	Private lshow 	:= .T. // Se deve apresentar a Mensagem
	
	If cQuem == _HORA

		lRetVal := ValHora(xValCpo)

	ElseIf cQuem == _DATA

		lRetVal := ValData(xValCpo)

	EndIf
	// AHEADER[11][2] = AD8_DTREMI
	// ACOLS[1][11] = 19/12/16

	Return(lRetVal)
*******************************************************************************
Static Function ValHora(xValCpo, dValDt)//| Valida Hora e dValDt=data a ser considerada....
*******************************************************************************
	Local lRetVal := .T.
 
	Default dValDt := aCols[N][nPCData]


	If xValCpo == _HRVZ // Caso esteja sendo limpado a hora... a data tambem deve ser limpa.
		
		If aCols[N][nPCData] == dValDt // Verifica se esta sendo usado o Acols... Neste caso deve limpar o acols tambem
			dValDt := aCols[N][nPCData] := CToD(_DTVZ)
		Else
		 	dValDt := CToD(_DTVZ)
		EndIf

	ElseIf dValDt >= dDataBase //|Data Valida

		If dValDt == dDataBase //|Data Atual

			If xValCpo < add30min()
				IF(lshow,Iw_MsgBox("Hora do lembrete deve ser no mínimo 30 minutos a frente da hora atual !!!","Atenção","ALERT"),'')
				lRetVal := .F.
			EndIf
		EndIf
	Else
		IF(lshow,Iw_MsgBox("Data do Lembrete é inválida! Por favor, ajuste a data do lembrete primeiro.","Atenção","ALERT"),'')
		lRetVal := .F.
	EndIf

	Return(lRetVal)
*******************************************************************************
Static Function ValData(xValCpo)//| Valida Data
*******************************************************************************
	Local lRetVal := .T.

	If xValCpo < dDataBase .And. DToC(xValCpo) <> _DTVZ // Valida se data esta correta

		IF(lshow,Iw_MsgBox("Data informada não pode ser anterior à atual!","","ALERT"),'')

		lRetVal := .F.

	ElseIf xValCpo == dDataBase  // Em caso de data atual, verificar se hora esta preenchida..

		If aCols[N][nPCHora] == _HRVZ// Caso a hora esteja vazia deve ser preenchida com valor padrao

			aCols[N][nPCHora] := add30min()

		Else
			lShow := .F.
			If !ValHora(aCols[N][nPCHora], xValCpo) // Caso a hora ja esteja preenchida deve validar o valor e ajustar caso necessario..
				aCols[N][nPCHora] := add30min()
			EndIf
			lShow := .T.
		EndIf

	ElseIf xValCpo > dDataBase  // Em caso de data futra, verificar se hora esta preenchida..
		
		If aCols[N][nPCHora] == _HRVZ// Caso a hora esteja vazia deve ser preenchida com valor padrao
			aCols[N][nPCHora] := Substr(Time(),1,5)
		EndIf

	ElseIf DToC(xValCpo) == _DTVZ // Em caso de data vazia

		aCols[N][nPCHora] := _HRVZ

	EndIf

	Return(lRetVal)
*******************************************************************************
Static Function add30min()
*******************************************************************************

	Local nSegundos := 0
	Local cHora		:= ""

	Static n30min   := 1800 // 30 minutos em segundos

	nSegundos 	:= U_FTimeTo("00:00:00",Time(),"SN")
	nSegundos 	+= n30min

	cHora		:= U_FTimeTo(1,nSegundos,"HC")
	cHora		:= Substr(cHora,1,5)

Return (cHora)