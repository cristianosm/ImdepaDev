#Include "Totvs.ch"
#Include "Fileio.ch"

// -----------------------------------------------------------------------------------------
// Projeto:
// Modulo :
// Fonte  : HTOcupacao
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/02/14 | Cristiano Machado | Rotina que apresenta tela para avaliar Tabela Auxiliar de Ocupacao..
// ---------+-------------------+-----------------------------------------------------------
*******************************************************************************
User Function HTOcupacao()
*******************************************************************************
Private cNomeFile 	:= ""

//| Valida Grupo de Perguntas...
ValidaPerg()

//| Apresenta Paramentros..
Pergunte("HTOCUP", .T. )

//| Executa Analise Ocupacao...
U_WfOcupacao(.T.)

//| Consulta Tabela Auxiliar de Ocupacao...
Consulta() 

//| Gera Arquivo CSV...
GeraCsv()

//| Envia email com arquivo CSV...
EnviaEmail()

If IW_MsgBox("Deseja Visualizar a Tabela % de Ocupacao por Endereço ?  ", "Atenção", "YESNO" )
	U_ZZ0TABAUX()
EndIf

Return()
*******************************************************************************
Static Function EnviaEmail()
*******************************************************************************
Local cFrom 		:= "protheus@imdepa.com.br"
Local cTo			:= Alltrim(mv_par04)
Local cBcc		:= ""
Local cSubject	:= "Arquivo CSV Ocupacao Endereços..."
Local cAttach		:= "\SYSTEM\" + cNomeFile+".csv"

Local cbody		:= "Avaliar arquivo anexo..." + cAttach

Local cRet		:= ""

cRet := U_EnvMyMail( cFrom, cTo, cBcc, cSubject, cBody, cAttach ) //| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )

If !Empty(cRet)
	IW_MsgBox("Erro no Envio !!! " + cRet, "Atenção", "ALERT" )
Else
		IW_MsgBox("Email Enviado com Sucesso !!! ", "Atenção", "INFO" )
EndIf

Return()
*******************************************************************************
Static Function Consulta()
*******************************************************************************

U_ExecMySql("Select * From ZZ0010", "TAUX", "Q", .F.) //| Enderecos a Atualizar....

Return()
*******************************************************************************
Static Function GeraCsv()
*******************************************************************************
Local nHandle		:= ""
Local cLinha		:= ""
Local cEnter		:=  CHR(13) + CHR(10)
local cExt		:= ".csv"

cNomeFile 	:= CriaTrab( Nil,.F.)
nHandle	:= FCreate ( cNomeFile + cExt, FC_NORMAL , Nil , .T. )

//cCab := "Filial;Local;Endereco;Estrutura;Particoes;(%) de Ocupacao;"+cEnter
cCab := "Filial;Endereco;Particoes;(%) Ocupacao;"+cEnter
FWrite ( nHandle, cCab, Len(cCab) )


DbSelectArea("TAUX")
DbGoTop()

While !Eof()

	cLinha := ""
	cLinha += "'" + ZZ0_FILIAL		+ ";"
//	cLinha += "'" + ZZ0_LOCAL		+ ";"
	cLinha += "'" + ZZ0_LOCALI		+ ";"
//	cLinha += "'" + ZZ0_ESTRUT		+ ";"
	cLinha += XV(ZZ0_PARTIC)	+ ";"
	cLinha += XV(ZZ0_PEROCU)	+ " % ;"

	cLinha += cEnter

	FWrite ( nHandle, cLinha, Len(cLinha) )

	DbSelectArea("TAUX")
	DbSkip()

EndDo

FClose( nHandle )

DbSelectArea("TAUX")
DbCloSeArea()

Return()
*******************************************************************************
Static Function ValidaPerg()
*******************************************************************************
Local aHelpPor01	:= {'Informar o Codifo da filial que deve ser' , 'avaliada.                               ' , ' ' 			}
Local aHelpPor02	:= {'Informar Codigo do Estoque que deve ser ' , 'avaliado. Para todos preencher com "ZZ".' , ' ' 			}
Local aHelpPor03	:= {'Informar o Codigo do Enreço que deve ser ', 'avaliado. Para todos preencher com      ' , '"ZZZZZZZZZZZZZZZ".'	}
Local aHelpPor04	:= {'Informar Email que ira receber relatório' , 'Exemplo: "fulano@dominio.com.br".       ' , ' '				}


PutSx1('HTOCUP', '01', 'Filial             ', ' ', ' ', 'mv_cha', 'C', 02, 0, 0, 'G','','','','', 'mv_par01','','','','','','','','','','','','','','','','', aHelpPor01, '' , '' )
PutSx1('HTOCUP', '02', 'Local              ', ' ', ' ', 'mv_chb', 'C', 02, 0, 0, 'G','','','','', 'mv_par02','','','','','','','','','','','','','','','','', aHelpPor02, '' , '' )
PutSx1('HTOCUP', '03', 'Endereco           ', ' ', ' ', 'mv_chc', 'C', 15, 0, 1, 'G','','','','', 'mv_par03','','','','','','','','','','','','','','','','', aHelpPor03, '' , '' )
PutSx1('HTOCUP', '04', 'Email              ', ' ', ' ', 'mv_chd', 'C', 50, 0, 2, 'G','','','','', 'mv_par04','','','','','','','','','','','','','','','','', aHelpPor04, '' , '' )

Return()
*******************************************************************************
Static Function XV(X)
*******************************************************************************
X := cValToChar(X)
X := StrTran(X, '.', ',' , Nil, Nil)
Return(X)
