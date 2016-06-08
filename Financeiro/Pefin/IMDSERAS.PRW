#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "MSGRAPHI.CH"

#DEFINE  FBLOCK    600 //| Tamanho Linha Aquivo
#DEFINE  FENTER		CHR(13)+CHR(10)//| ENTER

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SERASA    º Autor ³CRISTIANO MACHADO   º Data ³  28/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³GERENCIADOR DE CLIENTES QUE PODEM SER ENVIADOS AO SERASA.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CHAMADO: AAZU4Q - SERASA PEFIN   SOLICITANTE: Juliano SF    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

*********************************************************************
User Function ImdSeras()
*********************************************************************
	Private cAlias 		:= "Z01"
	Private aCores 		:= {}
	Private cCadastro 	:= "Controle Serasa"
	Private aRotina 	:= {}
	Private lCaptura 	:= .F.
	Private cFiltro		:= ""

	AADD(aRotina,{"Pesquisar" 	,"AxPesqui"			,0,1	})
	AADD(aRotina,{"Visualizar" 	,"AxVisual"			,0,2	})
	AADD(aRotina,{"Alterar"		,"AxAltera"			,0,4	})
	AADD(aRotina,{"Inclusões"	,"U_ImdSerSe('I')"	,0,0	})
	AADD(aRotina,{"Exclusões" 	,"U_ImdSerSe('E')"	,0,0	})
	AADD(aRotina,{"Retorno" 		,"U_ImdImpAr"		,0,6	})
	AADD(aRotina,{"Gráfico" 		,"U_ImdGrafS"		,0,6	})
	AADD(aRotina,{"Legenda" 		,"U_ImdSerLe"		,0,6	})
	AADD(aRotina,{"Sequencia" 	,"U_ImdSerCo"		,0,6	})


	AADD(aCores,{"Z01_LEGEND == 'D'" ,"BR_VERDE"	}) //| Disponivel
	AADD(aCores,{"Z01_LEGEND == 'I'" ,"BR_AMARELO"	}) //| Incluido
	AADD(aCores,{"Z01_LEGEND == 'R'" ,"BR_VERMELHO"	}) //| Retirar
	AADD(aCores,{"Z01_LEGEND == 'E'" ,"BR_AZUL"		}) //| Excluido
	AADD(aCores,{"Z01_LEGEND == 'A'" ,"BR_LARANJA"	}) //| Aguardando Retorno

	DbSelectArea(cAlias);DbSetOrder(1)

	MBrowse(6,1,22,75,cAlias,,,,,,aCores)

Return()

*********************************************************************
User Function ImdGrafS()//| Monta Grafico Conforme Legendas
*********************************************************************
	Local aNumPLeg 		:= {0,0,0,0,0}
	Local aNumDesc		:= {"A Incluir","Incluido","A Excluir","Excluido","Aguardando"}
	Local aNumCors		:= {CLR_HGREEN,CLR_YELLOW,CLR_HRED,CLR_HBLUE,6591981}
	Local lShowValues	:= .T.
	Local oFont			:= TFont():New( "Arial",,14,,.F.)

	cSql := "SELECT Z01_LEGEND SITUACAO, COUNT(1) QTD FROM Z01010 GROUP BY Z01_LEGEND"

	U_ExecMySql(cSql,"TAUX","Q")

	DbSelectArea("TAUX")
	While !EOF()

		Do Case
		Case TAUX->SITUACAO == "D"
			aNumPLeg[1]	:= TAUX->QTD
		Case TAUX->SITUACAO == "I"
			aNumPLeg[2]	:= TAUX->QTD
		Case TAUX->SITUACAO == "R"
			aNumPLeg[3]	:= TAUX->QTD
		Case TAUX->SITUACAO == "E"
			aNumPLeg[4]	:= TAUX->QTD
		Case TAUX->SITUACAO == "A"
			aNumPLeg[5]	:= TAUX->QTD
		EndCase

		DbSelectArea("TAUX")
		DbSkip()

	EndDo

	Define Dialog oDlg Title "Gráfico SERASA" From 180,180 To 550,700 Pixel

	oGraphic := 	TMSGraphic():New( 01	,01		,oDlg ,oFont ,RGB(0,0,0)	,RGB(255,255,255)	,260	,184		)

	oGraphic:SetTitle('Títulos por Status. '+Space(30)+ "Data:" + DToc(Date()),, RGB(0,0,0), A_CENTER , .F. )

	oGraphic:SetMargins(2,6,6,6)

	oGraphic:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)

	nSerie := oGraphic:CreateSerie( GRP_PIE , , , lShowValues) // GRP_PIE = 10

	For nI := 1 To 5

		oGraphic:Add(nSerie, aNumPLeg[nI], aNumDesc[nI]	, aNumCors[nI]	)

	Next nI

	Activate Dialog oDlg Centered

Return()
*********************************************************************
User Function ImdSerLe()//| Gera Arquivo de Inclussao no Serasa
*********************************************************************
	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERDE" 		,"A incluir no SERASA"			})	//| Pode Ser Incluido no SERASA
	AADD(aLegenda,{"BR_AMARELO"  	,"Incluido no SERASA"  			})	//| Ja Foi Retirado do SERASA
	AADD(aLegenda,{"BR_VERMELHO" 	,"A Excluir do SERASA" 			})	//| Pode Ser Excluido do SERASA
	AADD(aLegenda,{"BR_AZUL" 		,"Excluido do SERASA"			})	//| Ja Foi PAGO o TITULO e Não esta mais DISPONIVEL
	AADD(aLegenda,{"BR_LARANJA" 	,"Aguardando Retorno SERASA" 	})	//| Aguardando Arquivo de Retorno Serasa

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return()
*********************************************************************
User Function ImdImpAr()//| Importa Arquivo de Retorno SERASA
*********************************************************************
	Private cMascara		:= "*.*"							//| Caracter	Indica o nome do arquivo ou máscara.
	Private cTitulo		:= "Selecione o Arquivo Retorno SERASA"	//| Caracter	Indica o título da janela. Caso o parâmetro não seja especificado, o título padrão será apresentado.
	Private nMascpadrao	:=  1									//| Numérico	Indica o numero da mascara.
	Private cDirinicial	:= TstLocFile()							//| Caracter	Indica o diretório inicial.
	Private lSalvar		:= .T.									//| Logico		Indica se é um "save dialog" ou um "open dialog".
	Private nOpcoes		:=  0									//| Numerico	Indica a opção de funcionamento. Para mais informações das funcionalidades disponíveis, consulte a área Observações.
	Private lArvore		:= .T.									//| Logico		Indica se, verdadeiro (.T.), apresenta o árvore do servidor; caso contrário, falso (.F.).
	Private lKeepCase 	:= .T.									//| Logico		Indica se, verdadeiro (.T.), mantém o case original; caso contrário, falso (.F.).
	Private cArquivo 		:= ""                                  	//|
	Private cDrive			:= "" 									//| Driver Arquivo
	Private cDir			:= "" 									//| Diretorio Arquivo
	Private cNome			:= "" 									//| Nome Arquivo
	Private cExt			:= ""  									//| Extensao Arquivo
	Private cSeqMov 		:= ""  									//| Codigo de Movimento do Arquivo Retorno

	cArquivo := cGetFile( cMascara , cTitulo, nMascpadrao, cDirinicial, lSalvar, ,lArvore, lKeepCase ) //| Monta tela de localizacao de Arquivos...

	If Empty(cArquivo)
		Return()
	EndIf

	SplitPath(cArquivo, @cDrive, @cDir, @cNome ,@cExt)

	cDir := StrTran(cDir,"/","\")

	LeArqRet()//| Le o Arquivo de Retorno SERASA.

Return()
*********************************************************************
Static Function LeArqRet()  //| Le o Arquivo de Retorno SERASA.
*********************************************************************
	Local cLinha 		:= ""
	Local nLinha 		:= 0
	Local cLogTxt 		:= FENTER+"..:: Analise do Arquivo de Retorno SERASA  ::.. "+Space(62)+"Data: "+DtoC(Ddatabase)+" - "+Time() +FENTER+FENTER+FENTER
	Local cLogErr		:= ""
	Local cOpe			:= ""
	Local nErros		:= 0
	Local nTotal		:= 0
	Local cDescErro		:= ""

	FT_FUSE( cArquivo )

	FT_FGOTOP()

	cLinha 	:= FT_FREADLN()

	cSeqMov	:= Substr(cLinha,120,06) //| Numero do Movimento

	If !ValArqRet(cLinha) //| Valida arquivo de Retorno. Eh arquivo do SERASA ?
		Return()
	Endif


	While !FT_FEOF()

		cLinha 		:= FT_FREADLN()

		If Substr(cLinha,1,1) == "9" //| Trailler Sair do While
			Exit
		EndIf

		cOpe 		:= If(Alltrim(Substr(cLinha,002,01))=="I","Inclusão","Exclusão") //| Operacao. I=Inclusao, E=Exclusao
		cTitulo 	:= Alltrim(Substr(cLinha,439,16)) //| Prefixo + Numero + Parcela
		cErro		:= Alltrim(Substr(cLinha,534,60)) //| Codigo de Erro...
		nTotal 		+= 1

		If !Empty(cErro)
			cLogErr	+= "   *** "+cTitulo + " - "
			nErros 	+= 1

			For N := 1 To Len (cErro)

				cDescErro	:= 	Posicione("SX5",1,xFilial("SX5")+"2Z"+Substr(cErro,N,3),"X5_DESCRI" )

				If N == 1
					cLogErr	+= Substr(cErro,N,3) +" - "+ cDescErro + FENTER
				Else
					cLogErr	+= Space(28) + Substr(cErro,N,3) +" - "+ cDescErro + FENTER
				EndIf

				N += 2

			Next

		Else
			MarkTit(cTitulo)//| Acrescenta no Historido dos Titulo a Receber a Marca SERASA-PEFIN
		EndIf

		cLogErr	+= 	+ FENTER

		MudaLegTit(cOpe,cErro,cTitulo)



		FT_FSKIP()

	EndDo

	FT_FUSE(cArquivo ) //| Fecha o Arquivo

	cLogTxt		+= " -->> Retorno de Arquivo "+cOpe+".............: "	+ cSeqMov 					+FENTER+FENTER

	cLogTxt		+= " -->> Total de Títulos Processados..............: "	+ Alltrim(Str(nTotal,0)) 	+FENTER+FENTER

	cLogTxt		+= " -->> Títulos que processaram com Erro(s)...: "		+ Alltrim(Str(nErros,0)) 	+FENTER+FENTER

	cLogTxt		+= cLogErr												+FENTER+FENTER+FENTER

	cLogTxt		+= "..::  Fim do Relatório de Retorno SERASA   ::.. " 	+FENTER

	GeraLog(cLogTxt)

Return()
*********************************************************************
Static Function GeraLog( cLogTxt )
*********************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "LOG de Processamento de Arquivo Retorno SERASA-PEFIN" From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel

	oMemo:bRClicked := {||AllwaysTrue()}

	oMemo:oFont:=oFont

//Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
*********************************************************************
Static Function MudaLegTit(cOpe,cErro,cTitulo)
*********************************************************************
	Local cNewLeg := Substr(cOpe,1,1) ///| Nova Legenda

	If !Empty(cErro) //| Contiver Erros
		Do Case
		Case cNewLeg == "I"
			cNewLeg := "D" //| Disponivel
		Case cNewLeg == "E"
			cNewLeg := "R"
		EndCase
	EndIf

	DbSelectArea("Z01");DbGotop()
	If DbSeek(xFilial("Z01")+cTitulo,.F.)

		RecLock("Z01",.F.)
		Z01->Z01_LEGEND	:= cNewLeg
		Z01->Z01_DATALT	:= dDatabase
		Z01->Z01_HORALT	:= Substr(Time(),1,5)
		Msunlock()

	EndIf

Return()
*********************************************************************
Static Function ValArqRet(cLinha)
*********************************************************************
	Local cDestino 	:= TstLocFile()
	Local cNomeFile 	:= fMontaNome("R")
	//Alert("Destino: "+cDestino)
	//Alert("Origem: "+cArquivo)
	If Substr(cLinha,002,9) == "088613922" .And. Substr(cLinha,126,1) == "R" //| Cnpj Imdepa + R-Retorno

			FT_FUSE( cArquivo ) //| Fecha
			FClose( cArquivo )
			FT_FUSE( cDestino +  cNomeFile ) //| Fecha
			FClose( cDestino +  cNomeFile )

		If FRename( cArquivo , cDestino +  cNomeFile ) == 0 //| Move o Arquivo para o Local Padrao Definido pelo Financeiro

			cArquivo	:= cDestino +  cNomeFile

			FT_FUSE( cArquivo ) //| Abri no Novo Local
			FT_FGOTOP()
			FT_FSKIP() //| Pula Linha Header

		Else
			cErro := ""
			cErro := FERROR()
			Iw_MsgBox("Não foi possível mover o arquivo "+FENTER+cArquivo+FENTER+" para o Local:"+FENTER+cDestino+FENTER+" Erro: "+cErro, "Atenção", "ALERT" )

			Return(.F.)
		EndIf

	Return(.T.)
	EndIf

	Iw_MsgBox("Arquivo de Retorno SERASA Inválido !!!", "Atenção", "ALERT" )

Return(.F.)
*********************************************************************
User Function ImdSerSe(cPar)  //| Gera Arquivo de Exclusao do Serasa. cPar = [I - Incluir || E - Excluir ]
*********************************************************************
	Private nOpca 			:= 0
	Private cDescAct 		:= iif(cPar=="I","INCLUIDOS no ","EXCLUIDOS do ")
	Private nX				:= 0
	Private cOpc			:= cPar //| I - Inclusao | E - Exclusao
	Private nOpca			:= 0
	Private aCampos			:= {}
	Private aCols			:= {}
	Private aFieldFill 		:= {}
	Private aFields 		:= {"Z01_OK","Z01_PREFIX","Z01_NUMERO","Z01_PARCEL","Z01_VENCTO","Z01_VALOR","Z01_CLIENT","Z01_LOJA","Z01_NOME"}
	Private aAlterFields 	:= {}
	Private aRecSe1			:= {} //| Armazena Recnos SE1
	Private lInv 			:= .F.
	Private cMar   			:= GetMark()
	Private nRecno			:= 0
	Static oMark
	Static oTela

//| Filtra Registros
	If cOpc == "I"
		cFiltro := " Z01->Z01_LEGEND == 'D' " //| Disponiveis
	Else
		cFiltro := " Z01->Z01_LEGEND == 'R' " //| Retirar
	EndIf

	DbSelectArea(cAlias)
	nRecno := Recno()
	Set Filter to &cFiltro
	If fLock()
		Replace Z01->Z01_OK With cMar All For &cFiltro
		MsUnlock()
	EndIf
	DbGotop()
//| Fim Filtro

//| Valida Registros
	If EOF()
		IW_MsgBox("Nenhum Titulo Encontrado !!!","Atenção","INFO")
		DbSelectArea(cAlias)
		Set Filter to
		DbGotop();DbGoto(nRecno)
	Return()
	EndIf

	MontaACampos()//| Monta Estrutura de Acampos

	DEFINE MSDIALOG oTela TITLE "Selecione os Titulos que irão ser "+cDescAct+"SERASA" FROM 000, 000  TO 600, 1066 COLORS 0, 16777215 PIXEL

	oMark := MsSelect():New( cAlias, "Z01_OK" , , aCampos, @lInv, @cMar, {010, 015, 250, 523 },,, oTela,,)

	oMark:bMark := {| | Marcas(.F.)}		//| Efetua as Marcacoes no Browse

	ACTIVATE MSDIALOG oTela CENTERED ON INIT( EnchoiceBar( oTela , {|| nOpca := 1 , oTela:End() } , {|| nOpca := 2 , oTela:End() } ))

	If nOpca == 1 //| OK - Gerar Arquivo
		MsAguarde({|| GerarArquivo()},"Aguarde... Gerando Arquivo.")   //"Aguarde... Apurando Dados"
	EndIf

//| Limpa Filtro e Retorna no Registro
	DbSelectArea(cAlias)
	Set Filter to
	DbGotop();DbGoto(nRecno)

Return()
*********************************************************************
Static Function GerarArquivo()//| Gera Arquivo de Envio ao SERASA - PEFIN //|Carta comunicado - FAC Simples. 600 Bytes
*********************************************************************
	Private cNomeArq	:= ""
	Private cPathRaiz	:= ""
	Private cBuffer 	:= FBLOCK
	Private nArqSaida 	:= 0
	Private nLin		:= 1
	Private cSeqMov		:= StrZero(GetMv("IM_NSERASA"),6) //| Sequencia de Numeracao de envios Serasa - Numerico

	cNomeArq	:= fmontaNome("E")//|Monta Estrutura do Nome do Arquivo Texto.

	cPathRaiz := TstLocFile()//| Testa Local padrao e alternativo para Criacao do arquivo

	If Empty(cPathRaiz) //|Valida Criação do Arquivo
		IW_MSgBox("Não foi possivel Criar o Arquivo !!! "+FENTER+"Nao achou Unidade [U:] ou nao foi possivel criar [C:\Serasa\] ","Erro Arquivo","ALERT")
	EndIf

	nArqSaida 	:= FCREATE(cPathRaiz + cNomeArq, FC_NORMAL)

	DbSelectarea("SA1");DbSetorder(1)

	FT_FUSE( cPathRaiz + cNomeArq )

	CriaCabArq()//| Registro tipo "0" (Registro Header do arquivo )
	CriaDetArq()//| Registro tipo "1" (Registro detalhe do arquivo com os dados do devedor e da anotacao a ser incluida no banco de dados do PEFIN)
	CriaTraArq()//| Registro tipo "9" (Registro trailler do arquivo )

	FCLOSE(nArqSaida)

	If File(cPathRaiz + cNomeArq)

		If TudoCerto()//| Confirma que nao houve erro na rotina.
			IW_MSgBox("Arquivo PEFIN Gerado com Sucesso!!! "+FENTER+"[ "+cPathRaiz + cNomeArq + " ]","Movimento: "+cSeqMov,"INFO")
		Else
			IW_MSgBox("Arquivo PEFIN Com Erro na Geracao!! "+FENTER+"[ "+cPathRaiz + cNomeArq + " ]","Movimento: "+cSeqMov,"ALERT")
		Endif

	EndIf

Return()
*********************************************************************
Static Function CriaCabArq()//| Registro tipo "0" (Registro Header do arquivo );
*********************************************************************
		Local cLinha := ""

	cLinha +=  "0"				   				//|01:[001 - 001] (N) - Codigo do registro = ‘0’ (zero) (1)
	cLinha +=  "088613922"						//|02:[002 - 009] (N) - Numero do CNPJ da instituicao informante ajustado a direita e preenchido com zeros a esquerda (1)
	cLinha +=  DTOS(dDatabase)					//|03:[011 - 008] (N) - Data do movimento (AAAAMMDD) – data de geracao do arquivo (1)
	cLinha +=  "0051"							//|04:[019 - 004] (N) - Numero de DDD do telefone de contato da instituicao informante (1)
	cLinha +=  "21219917"						//|05:[023 - 008] (N) - Numero do telefone de contato da instituicao informante (1)
	cLinha +=  "9917"							//|06:[031 - 004] (N) - Numero de ramal do telefone de contato da instituicao informante (1)
	cLinha +=  PADL("JULIANO FONSECA",70, " ")	//|07:[035 - 070] (A) - Nome do contato da instituicao informante (1)
	cLinha +=  "SERASA-CONVEM04"				//|08:[105 - 015] (X) - Identificacao do arquivo fixo "SERASA-CONVEM04" (1)
	cLinha +=  cSeqMov							//|09:[120 - 006] (N) - Numero da remessa do arquivo seqüencial do 000001, incrementando de 1 a cada novo movimento (1)
	cLinha +=  "E"								//|10:[126 - 001] (A) - Codigo de envio de arquivo: (1) "E" - Entrada "R" - Retorno
	cLinha +=  SPACE(04)						//|11:[127 - 004] (X) - Diferencial de remessa, caso a instituicao informante tenha necessidade de enviar mais de uma remessa independentes por deptos.,no mesmo dia, de 0000 a 9999. Caso contrário, em branco.
	cLinha +=  SPACE(03)						//|12:[131 - 003] (X) - Deixar em branco
	cLinha +=  "13754322"						//|13:[134 - 008] (X) - Informar o LOGON a ser utilizado na contabilizacao das cartas comunicado e anotacões.
	cLinha +=  SPACE(392)						//|14:[142 - 392] (X) - Deixar em branco
	cLinha +=  SPACE(060)						//|15:[534 - 060] (X) - Codigo de erros – 3 posicões ocorrendo 20 vezes. Ausência de codigos indica que foi aceito no movimento de retorno. Na entrada, preencher com brancos.
	cLinha +=  StrZero(nLin,7)					//|16:[594 - 007] (N) - Seqüência do registro no arquivo igual a 0000001 para o header. (1)
	cLinha +=  FENTER

	nLin+= 1

	FWRITE(nArqSaida, cLinha)//| Grava Header

Return()
*********************************************************************
Static Function CriaDetArq()//| Registro tipo "1" (Registro detalhe do arquivo com os dados do devedor e da anotacao a ser incluida no banco de dados do PEFIN);
*********************************************************************
		Local cLinha := ""
	Local cMotBaixa := iif(cOpc=="I",Space(02),"01")

	DbSelectarea(cAlias);DbGotop()
	While !EOF()

		If Z01->Z01_OK == cMar

			cLinha := ""

			DbSelectArea("SA1");DbSeek(xFilial("SA1")+Z01->Z01_CLIENT + Z01->Z01_LOJA,.F.)

		//| Registro tipo "1" (Registro Dados da Anotacao );
			clinha += "1"															//|01:[001 - 001] (N) - Codigo do registro = "1" – detalhes (1)(2)
			clinha += cOpc															//|02:[002 - 001] (A) - Codigo da Operacao I – inclusao E – exclusao (1)(2)
			clinha += "001278"														//|03:[003 - 006] (N) - Filial e digito do CNPJ da contratante (1)
			clinha += DTOS(Z01->Z01_VENCTO)											//|04:[009 - 008] (N) - Data da ocorrencia ( AAAAMMDD) – data do vencimento da divida,nao superior a 4 anos e 11 meses , e inferior a 4 dias da data do movimento (1)
			clinha += DTOS(Z01->Z01_VENCTO)											//|05:[017 - 008] (N) - Data do término do contrato – formato "AAAAMMDD" . Caso nao possua , repetir a data da ocorrencia (vide observacao 1 para natureza "DC") (1)
			clinha += "NF "															//|06:[025 - 003] (X) - Codigo de natureza da operacao (1)
			clinha += Space(04)//|???												//|07:[028 - 004] (A) - Codigo da praca Embratel (que originou a divida )
			clinha += SA1->A1_PESSOA												//|08:[032 - 001] (A) - Tipo de pessoa do principal: F – Fisica ou J – Juridica (3)(4)(5)
			clinha += Iif(SA1->A1_PESSOA=="J","1","2")	   							//|09:[033 - 001] (X) - Tipo do primeiro docto. do principal: 1 – CNPJ ou 2 – CPF (3)(4)(5)
			clinha += StrTran(" "+SA1->A1_CGC," ","0",15)							//|10:[034 - 015] (N) - Primeiro documento do principal: CPF completo a base + digito ou CNPJ completo a base + filial + digito Ajustado a direita e preenchido com zeros a esquerda (2)(3)(4)(5)
			clinha += cMotBaixa		   												//|11:[049 - 002] (X) - Motivo da baixa (2)(5)
			clinha += Space(01)														//|12:[051 - 001] (X) - Tipo do segundo documento do principal: 3 – RG, se houver. Se nao, espacos (so para pessoa fisica).
			clinha += Space(15)														//|13:[052 - 015] (X) - Segundo documento do principal, se houver, se nao, espacos.
			clinha += Space(02)														//|14:[067 - 002] (A) - UF quando documento for RG, se nao, espacos.  Para os campos abaixo, de Seq. 15 a 21, referentes ao coobrigado, se o registro for do principal, deixar em branco.
			clinha += Space(01)														//|15:[069 - 001] (A) - Tipo de pessoa do coobrigado: F – Fisica J – Juridica (4)(6)
			clinha += Space(01)														//|16:[070 - 001] (X) - Tipo do primeiro documento do coobrigado: 1 – CNPJ 2 – CPF (4)(6)
			clinha += Space(15)														//|17:[071 - 015] (X) - Primeiro documento do coobrigado: CPF completo - base + digito ou CNPJ completo - base + filial + digito Ajustado a direita e preenchido com zeros a esquerda. (4)(6)
			clinha += Space(02)														//|18:[086 - 002] (X) - Espacos
			clinha += Space(01)														//|19:[088 - 001] (X) - Tipo do segundo documento do coobrigado: 3 – RG, se houver, se nao, espacos ( so para pessoa fisica )
			clinha += Space(15)														//|20:[089 - 015] (X) - Segundo documento do coobrigado, se houver, se nao, espacos.
			clinha += Space(02)														//|21:[104 - 002] (A) - Unidade da Federacao, quando documento for RG, se nao, espacos.
			clinha += SA1->A1_NOME + Space(70 - Len(SA1->A1_NOME))				//|22:[106 - 070] (X) - Nome do devedor (1)(4)(6)
			clinha += Replicate("0",8)												//|23:[176 - 008] (N) - A data do nascimento (AAAAMMDD) deve ser superior a 18 anos ( so para pessoa fisica ). Se nao, colocar 00000000.
			clinha += Space(70)														//|24:[184 - 070] (X) - Nome do pai. Caso nao possua, brancos.
			clinha += Space(70)														//|25:[254 - 070] (X) - Nome da mae. Caso nao possua, brancos.
			clinha += PadR(RTrim(SA1->A1_TLOGCOB)+RTrim(SA1->A1_ENDCOB),45," ")	//|26:[324 - 045] (X) - Endereco completo (rua, Av., nº etc.) (1)
			clinha += Substr(SA1->A1_BAIRROC,1,20)									//|27:[369 - 020] (X) - Bairro correspondente (1)
			clinha += Substr(SA1->A1_MUNC,1,25)									//|28:[389 - 025] (X) - Municipio correspondente (1)
			clinha += SA1->A1_ESTC			   										//|29:[414 - 002] (A) - Sigla Unidade Federativa (1)
			clinha += SA1->A1_CEPC													//|30:[416 - 008] (N) - Codigo de enderecamento postal completo (1)
			clinha += StrTran(StrZero(Z01->Z01_VALOR,16,2),".","",15)				//|31:[424 - 015] (N) - Valor com 2 decimais, alinhar a direita com zeros a esquerda (1)
			clinha += PADR(Z01->Z01_PREFIX+Z01->Z01_NUMERO+Z01->Z01_PARCEL,16," ")	//|32:[439 - 016] (X) - O numero do contrato deve ser unico para o principal e seus coobrigados (Vide observacao 2 para natureza "DC" e observacao 4 ) (1)(2)
			clinha += Z01->Z01_NUMBC													//|33:[455 - 009] (N) - Nosso numero (Vide observacao 3 para natureza "DC")
			clinha += SA1->A1_COMPLCO + Space(25 - Len(SA1->A1_COMPLCO))		//|34:[464 - 025] (X) - Complemento do endereco do devedor – usar somente quando o campo de seq. Nr. 26 (endereco completo) nao for suficiente.
			clinha += SA1->A1_DDD + Space(4 - Len(SA1->A1_DDD))					//|35:[489 - 004] (N) - DDD do telefone do devedor.
			clinha += Substr(SA1->A1_TEL,1,9)										//|36:[493 - 009] (N) - Numero do telefone do devedor.
			clinha += DTOS(Z01->Z01_VENCTO)											//|37:[502 - 008] (N) - Data do compromisso assumido pelo devedor - formato AAAAMMDD.
			clinha += StrZero(Z01->Z01_VALOR,15,2)									//|38:[510 - 015] (N) - Valor total do compromisso assumido pelo devedor, com 2 decimais, sem ponto e virgula.
			clinha += Space(06)														//|39:[525 - 006] (X) - Deixar em branco
			clinha += Space(01)														//|40:[531 - 001] (X) - Indicativo do Tipo de Comunicado ao Devedor: Branco - FAC "B" - Comunicado com Boleto Bancario (Obs: 5) "C" - Comunicado com Pgto de Contas Publicas (Obs: 6)
			clinha += Space(02)														//|41:[532 - 002] (X) - Deixar em branco
			clinha += Space(60)														//|42:[534 - 060] (X) - Codigos de erros – 3 posicões ocorrendo 20 vezes. Ausencia de codigos indica que o registro foi aceito no movto de retorno. Na entrada, preencher com brancos.
			clinha += StrZero(nLin,7)												//|43:[594 - 007] (N) - Sequencia do registro no arquivo (1) (2)
			cLinha += FENTER

			nLin+= 1

			FWRITE(nArqSaida, cLinha)//| Grava Detalhe
		//| E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			DbSelectArea("SE1");DbSeek(xFilial("SE1")+Z01->Z01_PREFIX + Z01->Z01_NUMERO + Z01->Z01_PARCEL,.F.)

			AADD(aRecSe1, Recno() ) // ) //| Obtem Recno Titulos a Receber para Posterior Marcacao.

		EndIf

		DbSelectarea(cAlias)
		DbSkip()

	EndDo

Return()
*********************************************************************
Static Function CriaTraArq()//| Registro tipo "9" (Registro trailler do arquivo )
*********************************************************************
	Local cLinha := ""

	cLinha += "9"				//|01:[001 - 001] (N) - Codigo do registro = "9" (nove) (1)
	cLinha += Space(592)		//|02:[002 - 592] (X) - Deixar em branco
	cLinha += StrZero(nLin,7)	//|03:[594 - 007] (N) - Sequencia do registro no arquivo. (1)
	cLinha += FENTER

	FWRITE(nArqSaida, cLinha)//| Grava Trailer

Return()
*********************************************************************
Static Function Marcas(lAll)//| Efetua as Marcacoes no Browse
*********************************************************************

	If IsMark("E1_OK",cMar,lInv)
		Reclock(cAlias)
		Z01->Z01_OK := "  "
		MsUnlock()
	Endif

	oMark:oBrowse:Refresh()

Return()
*********************************************************************
Static Function TudoCerto()//| Altera Status dos Titulos Que foram Marcados para Gerar Arquivo.
*********************************************************************
	Local cAuxFiltro 	:= cFiltro + " .AND. Z01->Z01_OK == '"+cMar+"'" //| Altera a Legenda dos Titulos Marcados Conforme Operacao
	Local cOpAnt		:= Iif(cOpc=="I","D","R") //| Salva Opcao Anterior para Rollback em caso de Erro.

	DbSelectArea(cAlias);DbGotop()

	If 	FLock()
		Replace Z01->Z01_LEGEND With 'A', Z01->Z01_DATALT 	With dDataBase, Z01->Z01_HORALT With Substr(Time(),1,5), Z01->Z01_SITUAC With "Arquivo: "+cSeqMov All For &cAuxFiltro
		MsUnlock()
	Else
	Return(.F.)
	EndIf

	DbSelectArea("SX6")
	If DbSeek(xFilial("SX6")+"IM_NSERASA",.F.)
		RecLock("SX6",.F.)
		X6_CONTEUD := StrZero( Val(cSeqMov)+1 ,6)
		MsUnlock()
	Else
		If FLock()
			Replace Z01->Z01_LEGEND With cOpAnt All For &cFiltro
			MsUnlock()
		EndIf
	Return(.F.)
	EndIf

Return(.T.)
*********************************************************************
Static Function MontaACampos()//| Monta Estrutura de Acampos
*********************************************************************
//| aCampos | Define Propriedade dos Campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aCampos, {SX3->X3_CAMPO, SX3->X3_PICTURE, AllTrim(X3Titulo()) })
		Endif
	Next nX

Return()
*********************************************************************
Static Function TstLocFile()//| Testa Local padrao e alternativo para Criacao do arquivo
*********************************************************************
	Local cPathPri	:= "u:\gerencia fin Corporativo\contas a receber\crédito\Arquivos pefin serasa\"//| Salva na Rede financeiro
	Local cPathSec	:= "c:\serasa\" //| Salva Local
	Local nTeste	:= 0
	Local cArquivo	:= "teste.txt"


//	Alert("Teste 1 ..." +  cPathPri + cArquivo)
	nTeste := FCREATE(cPathPri + cArquivo, FC_NORMAL)

	If nTeste > 0

		FClose(nTeste)
		FErase(cPathPri + cArquivo)
//		Alert("Teste 2 ..." +  cPathPri + cArquivo)
		Return(cPathPri)

	Else

		If ExistDir(cPathSec)
//			Alert("Teste 3 ..." +  cPathSec + cArquivo)
			nTeste := FCREATE(cPathSec + cArquivo, FC_NORMAL)

		Else
//			Alert("Teste 4 ..." +  cPathSec + cArquivo)
			MakeDir(cPathSec)
			nTeste := FCREATE(cPathSec + cArquivo, FC_NORMAL)

		EndIf

		If nTeste > 0
//			Alert("Teste 5 ..." +  cPathPri + cArquivo)
			FClose(nTeste)
			FErase(cPathPri + cArquivo)

			Return(cPathSec)

		EndIf
	EndIf

Return("")
*********************************************************************
Static Function MarkTit(cTitulo)//| Acrescenta no Historido dos Titulo a Receber a Marca SERASA-PEFIN
*********************************************************************

//For R := 1 To Len (aRecSe1)

	DbSelectArea("SE1")

  //DbGoto(aRecSe1[R])
	If DbSeek(xFilial("SE1")+cTitulo,.F.)

		If AT("Serasa-Pefin",SE1->E1_HIST) <= 0
			RecLock("SE1",.F.)
			SE1->E1_HIST := "Serasa-Pefin " + Alltrim(SE1->E1_HIST)
			MsUnlock()
		EndIf

	EndIf

//Next

//aRecSe1 := {}

Return()
*********************************************************************
Static Function fMontaNome(cTipo)//|Monta Estrutura do Nome do Arquivo Texto.
*********************************************************************
	Local cNome := "Serasa-"
	Local dtAux := DtoS(dDataBase)
	Local tmAux := StrTran(Substr(Time(),1,5),":",".")

	If cTipo == "E" //| Arquivo de Envio
		cNome += Iif( cOpc=="I" ,"Inclusao" , "Exclusao")
		cNome += "_"
		cNome += cSeqMov+"_"
		cNome += Substr(dtAux,1,4) +"."+ Substr(dtAux,5,2) +"."+ Substr(dtAux,7,2)
		cNome += ".."
		cNome += tmAux
		cNome += ".txt"

	ElseIf cTipo == "R" //| Arquivo de Retorno

		cNome += "Retorno
		cNome += "_"
		cNome += cSeqMov+"_"
		cNome += Substr(dtAux,1,4) +"."+ Substr(dtAux,5,2) +"."+ Substr(dtAux,7,2)
		cNome += ".."
		cNome += tmAux
		cNome += ".txt"

	EndIf

Return(cNome)
*********************************************************************
User Function ImdSerCo()
*********************************************************************
	Local cCaption	:= "N Sequencia SERASA-PEFIN"
	Local cSubTit	:= "Alteração"
	Local aBotoes	:= {"OK","SAIR"}
	Local cControle	:= StrZero(GetMv("IM_NSERASA"),6)
	Local cMensagem	:= "Este Numero é utilizado no controle das Remessas SERASA-PEFIN. Informar o Próximo Numero:"
	Local xGet		:= cControle
	Local lAut		:= .T.
	Local aRetorno  := {}

//³ cCaption   	:Titulo da Janela
//³ cSubTit  	:Sub Titulo da Janela
//³ cMensagem  	:Texto da Janela (400 caracteres)
//³ aBotoes    	:Array com titulo dos botoes  ( Max.5 )
//³ xGet		:Valor Padaro do Get
//³ cValida		:Validacao para o Get
	aRetorno := U_Men(cCaption, cSubTit, cMensagem, aBotoes, xGet, lAut)

	If aRetorno[1] == 2
		DbSelectArea("SX6")
		If DbSeek(xFilial("SX6")+"IM_NSERASA",.F.)
			RecLock("SX6",.F.)
			X6_CONTEUD := 	aRetorno[2]
			MsUnlock()
		EndIf
		IW_MsgBox("Alterado com Sucesso !!!", "Atenção", "INFO" )
	EndIf

Return()
