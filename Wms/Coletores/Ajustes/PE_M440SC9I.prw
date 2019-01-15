#include 'rwmake.ch'

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: M440SC9I     || Autor: Luciano Corrêa        || Data: 07/06/04  ||
||-------------------------------------------------------------------------||
|| Descrição: PE apos a inclusao dos itens do pedido liberado              ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M440SC9I()

Local lRetWMS
Local nUltRec
// está posicionado do registro incluido e o mesmo permanece travado...
// preenche a data/hora da inclusão...
// Habilita o apanhe do produto pelo WMS - Edivaldo Gonçalves Cordeiro 21/10/2006

//Inserido por Edivaldo Goncalves Cordeiro em 12/01/2009 - Ajuste para gravar o historico das liberacoes

/* 
SC9->C9_DTLCOM  := Date()
SC9->C9_HRLCOM  := Time()
SC9->C9_USRLCOM := SubStr( cUsuario, 7, 15 )


If Empty(C9_BLCRED)
	SC9->C9_DTLCRE  := Date()
	SC9->C9_HRLCRE  := Time()
	
	If FUNNAME() == 'A450LibAut'
		SC9->C9_TPLCRE  := 'A'
	Else
		SC9->C9_TPLCRE  := 'M'
	Endif
	
	SC9->C9_USRLCRE := SubStr( cUsuario, 7, 15 )
Endif

If Empty(C9_BLEST)
	SC9->C9_DTLEST  := Date()
	SC9->C9_HRLEST  := Time()
	SC9->C9_TPLEST  := 'A'
	SC9->C9_USRLEST := SubStr( cUsuario, 7, 15 )
Endif


If FUNNAME() == 'IMDF260'
	LoadHistorico() // Atualiza o Historico das liberacoes
Endif
     Comentado por Edivaldo Goncalves Cordeiro
*/


lCheck	:=	GetMv('IM_LOGSC9')
If lCheck
	If ExistBlock('ChkLogSC9')
		ExecBlock('ChkLogSC9', .F., .F., {'M440SC9I',SC9->C9_PRCVEN*SC9->C9_QTDLIB, 0})
	EndIf
EndIf

*---------------------------------------------------------------------------*
//Inserido por Edivaldo Gonçalves Cordeiro em 21/10/06                               //
//Verifica se o Produto é Gerenciado pelo WMS para geracao da OS.                    //
*---------------------------------------------------------------------------*

//Alterado por Agostinho em 08/07/08 / Correção de bloqueios em função do tipo de pedido
If ! SC5->C5_TIPO $"C/I/P" .AND. SF4->F4_ESTOQUE='S' //.AND.  FUNNAME()='MATA410' //Se movimentar Estoque verifico se trata Controle de Localização
	
	MsAguarde({||lRetWMS:=SF4->(U_checkWMS(SC9->C9_PRODUTO))},"WMS","Verificando se o item é Gerenciado pelo WMS...")
	If lRetWMS
		//SC9->C9_ENDPAD:=SBE->(Posicione("SBE",1,xFilial("SBE") +SC9->C9_LOCAL+'DOCA',"BE_LOCALIZ"))		
		//SC9->C9_SERVIC:=DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
		SC9->C9_BLWMS :='01' //Inserido em 16/12/06 o status de Bloqueio WMS, por Edivaldo Gonçalves Cordeiro
		If DC8->(dbSeek(xFilial('DC8')+'5'+SC9->C9_LOCAL, .F.))
			cTpEstFis      := DC8->DC8_CODEST
			cEPadDC8       := Alltrim(DC8->DC8_DESEST)
			If SBE->(dbSeek(xFilial('SBE')+SC9->C9_LOCAL + cEPadDC8, .F.)) // Verificar se endereco EXISTE
				SC9->C9_ENDPAD := cEPadDC8
				SC9->C9_SERVIC := SuperGetMv("IMD_SVCONF" , .F. , "001" , xFilial("SC6")) //DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
			EndIf
		EndIf
	Endif
Endif

/*// Jean Rehermann - Solutio IT - 01/09/2015 - Log para identificar origem de SC9 com Sequencia maior que 01
	If !Empty( SC9->C9_SEQUEN ) .And. SC9->C9_SEQUEN != "01"
		
		ajAreaAtu := GetArea()
		cjMsg := "LOGC9: Pedido["+ SC9->C9_PEDIDO +"] Item["+ SC9->C9_ITEM +"] Sequencia["+ SC9->C9_SEQUEN +"] Programa["+ Procname(0)+" L:"+ ProcLine(0) +"] - Programa["+ Procname(1)+" L:"+ ProcLine(1) +"] - Programa["+ Procname(2)+" L:"+ ProcLine(2) +"] - Programa["+ Procname(3)+" L:"+ ProcLine(3) +"]"
		
		dbSelectArea("CV8")
		RecLock("CV8",.T.)
		
			CV8->CV8_FILIAL:= xFilial("CV8")
			CV8->CV8_DATA 	:= MsDate()
			CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
			CV8->CV8_PROC	:= FunName()
			CV8->CV8_USER	:= cUserName	
			CV8->CV8_INFO   := "J"
			CV8->CV8_MSG 	:= "Log do SC9 - Jean"
			CV8->CV8_DET	:= cjMsg
	
		MsUnLock()
		
		RestArea( ajAreaAtu )
		ConOut( cjMsg )
	
	EndIf
// Fim Jean /*/


Return


//+-----------------------------------------------------------------------------------//
//|Empresa...: Imdepa
//|Funcao....: LoadHistorico()
//|Autor.....: Edivaldo Goncalves Cordeiro
//|Data......: 07 de Agosto de 2010
//|Uso.......: SIGAFIN
//|Versao....: Protheus - 10
//|Descricao.: Atualiza o historico das liberacoes
//|Observação:
//+-----------------------------------------------------------------------------------//

*-----------------------------------------*
Static Function LoadHistorico()
*-----------------------------------------*    
/*
//Verifica o ultimo registro liberado do SC9 para pegar o historico de Liberacoes
cQuery :=" SELECT MAX(R_E_C_N_O_)AS N_REC"
cQuery +=" FROM "
cQuery += RetSqlName( "SC9" )+ " SC9 "
cQuery +=" WHERE "
cQuery +=" C9_FILIAL = '"+xFilial("SC9")+"'"
cQuery +=" AND C9_PEDIDO='"+SC9->C9_PEDIDO+"'"

IF SELECT( "QRY_C9B" ) <> 0
	dbSelectArea("QRY_C9B")
	QRY_C9B->(DbCLoseArea())
Endif

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_C9B",.F.,.T.)

DBSELECTAREA("QRY_C9B")

//Considera o registro anterior , pois o registro atual e o novo a ser incluido pela rotina
nUltRec:=QRY_C9B->N_REC -1
QRY_C9B->(DbCLoseArea())

//Pego as informacoes da Libercao Comercial,Credito e Estoque
cQuery :="SELECT C9_DTLCOM,C9_HRLCOM,C9_USRLCOM,C9_DTLCRE,C9_HRLCRE,C9_TPLCRE,C9_USRLCRE,C9_TPLCRE,C9_BLCRED,C9_BLEST,C9_DTLEST,C9_HRLEST,C9_TPLEST,C9_USRLEST FROM "
cQuery += RetSqlName( "SC9" )+ " SC9 "
cQuery +=" WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
cQuery +=" AND R_E_C_N_O_ ="+Str(nUltRec)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_C9C",.F.,.T.)
TCSetField("QRY_C9C","C9_DTLCOM" ,"D",8, 0)
TCSetField("QRY_C9C","C9_DTLCRE" ,"D",8, 0)
TCSetField("QRY_C9C","C9_DTLEST" ,"D",8, 0)


DBSELECTAREA("QRY_C9C")

If !Empty(QRY_C9C->C9_DTLCOM)
	SC9->C9_DTLCOM  := Date() //EDI QRY_C9C->C9_DTLCOM
	SC9->C9_HRLCOM  := Time()//QRY_C9C->C9_HRLCOM
	SC9->C9_USRLCOM := QRY_C9C->C9_USRLCOM
Endif

If !Empty(QRY_C9C->C9_USRLEST)
	SC9->C9_DTLEST  := Date()//QRY_C9C->C9_DTLEST
	SC9->C9_HRLEST  := Time()//QRY_C9C->C9_HRLEST
	SC9->C9_TPLEST  := Time()//QRY_C9C->C9_TPLEST
	SC9->C9_USRLEST := QRY_C9C->C9_USRLEST
	
Else
	SC9->C9_DTLEST  := Date()
	SC9->C9_HRLEST  := Time()
	SC9->C9_TPLEST  := 'A'
	SC9->C9_USRLEST := SubStr( cUsuario, 7, 15 )
	
EndIf

//Insere o historico da liberacao de creido atual(Lib.Manual)
SC9->C9_DTLCRE  := Date()
SC9->C9_HRLCRE  := Time()

If FUNNAME() == 'A450LibAut'
	SC9->C9_TPLCRE  := 'A'
Else
	SC9->C9_TPLCRE  := 'M'
Endif

SC9->C9_USRLCRE := SubStr( cUsuario, 7, 15 )

QRY_C9C->(DbCLoseArea())
 */
 
Return()
