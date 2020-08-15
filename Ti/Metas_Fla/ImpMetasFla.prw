#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Tbiconn.ch"

#Define  ORD_NAME  	1
#Define  ENTER   	CHR(13)+CHR(10)

/// Estrutura csv Robson 2020
/*
01 - FILIAL				= 09			;
02 - GERENTE_DE_VENDAS  = 010121		;
03 - CODIGO_CLIENTE		= N0449B		;
04 - LOJA				= 01			;
05 - GRUPO_SEGMENTO		= AG1			;
06 - GRUPO_MARCAS_3		= 001811		;
07 - CODIGO_PRODUTO		= 000000023373A ;
08 - DATA    			= 20190101		;
09 - META_PECA			= 0.45			;
10 - META_VALOR			= 6.26			;
11 - META_MC			= 1.91			;
12 - META_IMC			= 30.43         ;
*/

//| CAMPOS ARQUIVO CSV  // 2020
#Define F_FILIAL   	 1  //  Filial
#Define F_VEND	 	 2  //  Vendedor
#Define F_CLIENTE	 3  //  Cliente
#Define F_LOJACLI	 4  //  Loja
#Define F_GRPSEGT    5  //  Grupo de Segmento
#Define F_MARCA3	 6  //  Grupo de Marcas 3
#Define F_PRODUTO	 7  //  Produto
#Define F_DATA		 8  //  Data
#Define F_QUANT	 	 9  //  Quantidade Pecas
#Define F_VALOR	 	 10 //  Valor Pecas
#Define F_MARGVLR 	 11 //  Metas Margem Contribuicao
#Define F_MARGEM 	 12 //  Metas Indice Margem Contribuicao


// Parametros de Data
#Define CPERINI      '20200701' // Periodo Inicial que sera Limpo na Tabela SCT
#Define CPERFIM      '20201231' // Periodo Final que sera Limpo na Tabela SCT
#Define CANO         Alltrim( cValToChar( YEAR( dDatabase ) ) )

// Parametros Limpar ou Salvar MEta Antiga no Periodo
#Define CLEAR 	.T.   // Define se vai ser feito alguma limpeza com a META Antiga... 
#Define SAVE 	.T.	  // Define se Salva a Meta Antiga como Ct_RELAUTO = 0 an invés de remover os registros... 

// Parametro Local dos Arquivos 
#Define _DIRFILE "C:\protheus\metas\2020\"

//| CAMPOS TABELA SCT010 INSERT
#Define TCT_FILIAL   1
#Define TCT_DOC		 2
#Define TCT_SEQUEN	 3
#Define TCT_DESCRI	 4
#Define TCT_VEND	 5
#Define TCT_DATA	 6
#Define TCT_PRODUTO	 7
#Define TCT_QUANT	 8
#Define TCT_VALOR	 9
#Define TCT_MOEDA	 10
#Define TCT_CLIENTE	 11
#Define TCT_LOJACLI	 12
#Define TCT_RELAUTO	 13

#Define TAMDOC 9 // Tamanho do Campos CT_DOC
#Define TAMSEQ 3 // Tamanho do Campos CT_SEQUEN

#Define TLININS 3 // Numero de Linhas a ser inseridas por Lote
#Define NLPSHOW 15000 // Numero de Linhas para Apresentar no LOG

// Arquivo Grupo de Marcas 3
#Define GER 1
#Define GM3 2
#Define IMC 3

*********************************************************************
User Function ImpMetasFla() // Importa Metas para Tabela SCT apartir de Arquivo CSV
*********************************************************************

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'ImpMetasFla'  TABLES 'SM0'

	Conout('IMPMETAS : ' + PadR('Inicio...', 100 ) + Dtoc(ddatabase) + " " + time() )
	
	SetVar() 	//| Define as Variaveis Privadas 

	CleanPeriodo(CLEAR, SAVE) //| Limpa o Periodo a ser Importado

	MntDocSeq()	//| Monta a Sequencia de Doc e Seq por Filial
	
	MntRecno()	//| Monta o Recno a Ser Utilizado
	
	MntDesMet() //| Monta a Descricao por Filial da Meta
	
	//MntGM3() //| Monta grupo de marcas 3
	
	GetFiles() 	//| Obtem Lista e Tamanhos de Arquivos
	
	If nQtdFil > 0 // Caso tenha encontrado algum arquivo a ser importado
		
		Executa() // Inicia o processo ... 

	EndIF
	
	Conout('IMPMETAS : ' + PadR('Fim...', 100 ) + Dtoc(ddatabase) + " " + time() )

	RESET ENVIRONMENT

Return()
*********************************************************************
Static Function SetVar() // Definicao de Todas as Variaveis Privadas Envolvidas 
*********************************************************************
	
	Conout('IMPMETAS : ' + PadR('Entrou SetVar...', 100 ) + Dtoc(ddatabase) + " " + time() )
	
	_SetOwnerPrvt( 'cDirCsv' , _DIRFILE )
	_SetOwnerPrvt( 'MascFil' , "*.csv" 	) 
	_SetOwnerPrvt( 'aFilesN' , {} 		)	//| Armazena a Lista contendo o Nome dos Arquivos	
	_SetOwnerPrvt( 'aTamFil' , {}		)	//| Armazena o Tamanho dos Arquivos 
	_SetOwnerPrvt( 'nQtdFil' , 0		)	//| Armazena Quantos arquivos foram encontrados
	_SetOwnerPrvt( 'nPFiAtu' , 0 		)   //| Posicao do Arquivo em Uso
	_SetOwnerPrvt( 'nHdl'    , 0        )   //| Arquivo 
	
	// Tabelas Hash 
	_SetOwnerPrvt( 'oHashDS' , HMNew()  )   //| Hash Tabela Doc e Seq
	
	_SetOwnerPrvt( 'oHashFG' , HMNew()  ) 	//| Hash Table que Armazena Filial de Acordo com Gerente 
	
	_SetOwnerPrvt( 'oHashDM' , HMNew()  ) 	//| Hash Table que Armazena a Descricao da Meta 

	//_SetOwnerPrvt( 'oHashG3' , HMNew()  ) 	//| Hash Table que Armazena o Grupo de Marcas 3

	_SetOwnerPrvt( 'nRecno'  , 0  		) 	//| Hash Table que Armazena o Recno
	
	
	//| Estrutura para o Insert 
	_SetOwnerPrvt( 'cCpoSCT'  , "CT_FILIAL,CT_DOC,CT_SEQUEN,CT_DESCRI,CT_VEND,CT_DATA,CT_PRODUTO,CT_QUANT,CT_VALOR,CT_MOEDA,CT_MARGEM,CT_CLIENTE,CT_LOJACLI,CT_GRPSEGT,CT_MARCA3,CT_RELAUTO,CT_MARGVLR,R_E_C_D_E_L_,R_E_C_N_O_"	) // Estrutura de Campos SCT para o Insert
	_SetOwnerPrvt( 'aCpoSCT'  , StrTokArr(cCpoSCT,",") ) // Estrutura de Campos em Array

	_SetOwnerPrvt( 'cInsCab'  , ''  		) 	//| Cabecalho do Insert 
	
	cInsCab += "INSERT /* + append */ INTO SCT010 ( "+cCpoSCT+" ) "
	cInsCab += "WITH METAS AS ( "
	cInsCab += "SELECT " + cCpoSCT + " "	
	cInsCab += "FROM ( "
	
	_SetOwnerPrvt( 'cInsLin'  , ''  		) 	//| Linhas  do Insert
	_SetOwnerPrvt( 'cInsRod'  , " ) METAS ) SELECT * FROM METAS" ) //| Rodape do Insert 
	
	
Return Nil 
*********************************************************************
Static Function MntDocSeq() //| Monta a Sequencia de Doc e Seq por Filial
*********************************************************************

Local cSql := ""
Local cDoc := "CP0000001"
Local cSeq := "000"
 
 	Conout('IMPMETAS : ' + PadR('Obtendo Documento e Sequencia...', 100 ) + Dtoc(ddatabase) + " " + time() )
 	
cSql += "SELECT SCT.CT_FILIAL FILIAL, Trim(SCT.CT_DOC) DOC, Trim(MAX(CT_SEQUEN)) SEQUEN " 
cSql += "FROM SCT010 SCT, ( SELECT CT_FILIAL, MAX(CT_DOC) CT_DOC FROM SCT010 WHERE SUBSTR(CT_DOC,1,2) = 'CP' GROUP BY CT_FILIAL ) DOC "
cSql += "WHERE DOC.CT_FILIAL = SCT.CT_FILIAL AND DOC.CT_DOC = SCT.CT_DOC AND SUBSTR(SCT.CT_DOC,1,2) = 'CP'  "
cSql += "GROUP BY SCT.CT_FILIAL, SCT.CT_DOC "
cSql += "ORDER BY SCT.CT_FILIAL, SCT.CT_DOC "

U_ExecMySql( cSql , cCursor := "TDS", cModo := 'Q', lMostra := .F., lChange := .F. )

DbSelectArea('TDS'); DbGotop()
While !EOF()
	
	cDoc := Soma1(TDS->DOC,TAMDOC,.F.,.F.)
	
	HMSet( oHashDS, FILIAL+'DOC', cDoc )
	HMSet( oHashDS, FILIAL+'SEQ', cSeq )

	ConOut( 'Filial: '+ FILIAL + ' Doc: ' + cDoc + ' Sequencia: ' + cSeq )
	
	DbSelectArea('TDS')
	DbSkip()
	
EndDo
DbSelectArea('TDS')
DbCloseArea()

Return Nil
*********************************************************************
Static Function MntRecno() 	//| Monta o Recno a Ser Utilizado
*********************************************************************

	Local cSql 		:= "SELECT ( MAX(R_E_C_N_O_) + 1 ) AS RECNO FROM SCT010  "

	Conout('IMPMETAS : ' + PadR('Obtendo Recno...', 100 ) + Dtoc(ddatabase) + " " + time() )
	
	U_ExecMySql(cSql, "REC", "Q", .F., .F.)

	DbSelectArea("REC");DbGotop()
	nRecno := REC->RECNO + 1
	ConOut( 'Recno Obtido: '+ ToC(nRecno))
	DbSelectArea("REC");DbCloseArea()

Return Nil
*********************************************************************
Static Function MntDesMet() // Monta a Descricao por Filial da Meta
*********************************************************************

	Local cSql 	:= "SELECT A3_COD, A3_CODFIL, TRIM(A3_DESCMOL) A3_DESCMOL, A3_NOME, R_E_C_N_O_ FROM SA3010 WHERE A3_MSBLQL <> '1' AND D_E_L_E_T_ = ' ' AND A3_GEREN = ' ' AND A3_CODFIL > ' ' AND A3_GERENTE = 'S' AND A3_DESCMOL > ' '"
	 
	//"SELECT A1_UFREC CUF, A1_LOJA FILIAL FROM SA1010 WHERE A1_COD = 'N00000' And D_E_L_E_T_ = ' ' "
	//Local cUF	:= ""

	Conout('IMPMETAS : ' + PadR('Monta Descricao por Filial...', 100 ) + Dtoc(ddatabase) + " " + time() )
	
	U_ExecMySql(cSql, "CUF", "Q", .F., .F.)

	DbSelectArea("CUF");DbGotop()
	While !EOF()
	
		HMSet(oHashDM, CUF->A3_COD, 'META ' + CANO + ' ' + Upper( Alltrim( CUF->A3_DESCMOL ) ) + ' PROD CLIENTE' ) // nova: META 2019 GERVEN SP-IND PROD CLIENTE
		
		ConOut( 'Filial : '+  CUF->A3_CODFIL + ' -> ' + 'META ' + CANO + ' ' + Upper( Alltrim( CUF->A3_DESCMOL ) ) + ' PROD CLIENTE' )
		
		DbSelectArea("CUF")
		DbSkip()
		
	EndDo
	
	DbSelectArea("CUF");DbCloseArea()

Return Nil
/*********************************************************************
Static Function MntGM3() //| Monta grupo de marcas 3
*********************************************************************
	Local cFileGM3 	:= cDirCsv + "file_gm3.txt"
	Local nHdlGM3  	:= FT_FUSE(cFileGM3) //| fOpen(cDircsv,68)
	Local cLinGm3 	:= ""
	Local aLinGm3   := {} 
	
	FT_FGOTOP() // Aponta para Inicio do Arquivo
	
	While !FT_FEOF()
	
		
		cLinGm3	:= StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String
		aLinGm3	:= StrTokArr(cLinGm3,";") 	//| Converte a Linha para Array
		
		Conout("Gerente: " + aLinGm3[GER] + "GM3: " + aLinGm3[GM3] + "Meta: " + ToC(aLinGm3[IMC]))
		
		//HmSet( oHashG3 , aLinGm3[GER] + aLinGm3[GM3], aLinGm3[IMC] )
		
		FT_FSKIP()

	EndDo
	FT_FUSE()// O a

Return Nil */
*********************************************************************
Static Function GetFiles(aFiles) // Tela com Diretorio dos arquivos para carga dos files
*********************************************************************
	Conout('IMPMETAS : ' + PadR('Verificando Arquivos a Importar...', 100 ) + Dtoc(ddatabase) + " " + time() )
	
	nQtdFil := ADir( cDirCsv+MascFil,@aFilesN,@aTamFil) //Directory( cDircsv+"*.csv", Nil, Nil, Nil, ORD_NAME)
	
	//VarInfo('',aFilesN,0,.F.,.T.)
	//VarInfo('',aTamFil,0,.F.,.T.)
	
Return Nil
*********************************************************************
Static Function CleanPeriodo(lClear, lSave) // Obtem o atual RECNO na Tabela SCT - METAS
*********************************************************************

	Local cSql := ""

	iF lClear 

		if lSave 

			cSql := "UPDATE SCT010 SET CT_RELAUTO = '0' WHERE CT_FILIAL > ' ' AND CT_RELAUTO = '9' AND CT_DATA BETWEEN '" + CPERINI + "' AND '" + CPERFIM + "'  "
			Conout('IMPMETAS : ' + PadR('Salvando Periodo: ' + CPERINI + " - "+ CPERFIM, 100 ) + Dtoc(ddatabase) + " " + time() )

		Else 

			cSql := "DELETE SCT010 WHERE CT_FILIAL > ' ' AND CT_RELAUTO = '9' AND CT_DATA BETWEEN '" + CPERINI + "' AND '" + CPERFIM + "' "
			Conout('IMPMETAS : ' + PadR('Removendo Periodo: ' + CPERINI + " - "+ CPERFIM, 100 ) + Dtoc(ddatabase) + " " + time() )
			
		EndIf

		U_ExecMySql(cSql, "", "E", .F., .F.)

	EndIf

Return Nil
*********************************************************************
Static Function Executa() // Inicia o Processo 
*********************************************************************

	Local cNomFile		:= ''
	Local nTamFile 	:= 0 
	
	For nPFiAtu := 1 To nQtdFil // Percorre os Arquivos .... 

		cNomFile := cDircsv + aFilesN[nPFiAtu]
		nTamFile := aTamFil[nPFiAtu]
		
		LeCsv( cNomFile ) // Efetua a Leitura do Arquivo
		
		If nHdl > 0
			ImpFile(cNomFile,  nTamFile   )
		EndIf
		
	Next

Return Nil
*********************************************************************
Static Function LeCsv(cFile )
*********************************************************************

	nHdl    := FT_FUSE(cFile) //| fOpen(cDircsv,68)

	If nHdl == -1
		MsgAlert("O arquivo de nome " + cDircsv + " nao pode ser aberto! Verifique os parametros.","Atencao!")
		nHdl := 0
		Return()
	Endif

Return Nil
*********************************************************************
Static Function ImpFile(cFile, nTamFile) // Importa Arquivo
*********************************************************************
	
	//| Variaveis Referente ao Arquivo
	Local   cLinha	:= ""  // Recebe Linha em texto
	Local 	aLinha  := {}	//| Recebe a Linha em formato de Array 
//	Local 	aLin 	:= {}  // Recebe Linha em Array 
	Local   nLPerc 	:= 0   // Numero Atual de Linhas Percorridas 
	Local   nTLin   := 101 /// Tamanho Medio da linha baseado em mil Linhas (Bytes)
	Local   nQLIns  := 0	//| Quantidades de Linhas para o Insert 
	Local 	TLFile  := Round( nTamFile / nTLin , 0 )
	Local 	nShow	:= NLPSHOW
	Local 	nNext	:= nShow
	Local 	cNomeF	:= cFile //Substr(cFile,23)
	Private cDataMeta	:= ""
	
	Conout('IMPMETAS : ' + PadR('Iniciando Importacao do Arquivo : ' + cNomeF + 'Recno: ' + ToC(nRecno), 130 ) + Dtoc(ddatabase) + " " + time() )
	

	FT_FGOTOP() // Aponta para Inicio do Arquivo

	While !FT_FEOF()
		
		
		nLPerc += 1 //| Numero Atual de Linhas Percorridas
		
		//|Salva o Buffer de Linha em Array
		cLinha 	:= StrTran(FT_FREADLN(),'"',"") //| Retira as aspas duplas da String
		aLinha 	:= StrTokArr(cLinha,";") 	//| Converte a Linha para Array
		
		//VarInfo('',aLinha,0,.F.,.T.)

		//| Validacoes Diversas para Efetuar o Salto de Linha
		//| Valida ANO Metas	
		//If CANO <> Substr(StrTran(aLinha[F_DATA],'-',''),1,4) .Or. Val(StrTran(aLinha[F_QUANT],',','.')) == 0
		If Val( ( aLinha[F_VALOR] ) ) == 0
			//| Estes Casos Deve Desconsiderar o Registro 
		Else
	
			If TLININS == nQLIns
				SendInsert() 	//| Envia ao Banco o Inseert
				nQLIns 	:= 0		//| Quantidade de Linhas a serem inseridas por vez 
				cInsLin := ""
			EndIf
			
			nQLIns += 1 //| Quantidade de Linhas a serem inseridas por vez 
		
			MntLinIns(aLinha, nQLIns) // Monta a Linha do Insert
				
		Endif		

		//| Apresenta Mensagens do Status e posicao do Processamento
		If( nNext == nLPerc )
	
			Conout('IMPMETAS : ' + PadR("Linha: "+ToC(nLPerc)+" de "+ToC(TLFile)+" File: "+cNomeF  + ' U.Recno: ' + ToC(nRecno-1), 130 ) + Dtoc(ddatabase) + " " + time() )
	
			nNext += nShow

		elseIf( TLFile == nLPerc )
	
			Conout('IMPMETAS : ' + PadR("Linha: "+ToC(nLPerc)+" de "+ToC(TLFile)+" File: "+cNomeF + ' U.Recno: ' + ToC(nRecno-1), 130 ) + Dtoc(ddatabase) + " " + time() )
	
		Endif
		
		// Salta para a Proxima Linha do Arquivo
		FT_FSKIP()

	EndDo
	
	//| Insere as Linhas Restantes, quanto terminou o arquivo mas nÃ£o atingiu o Lote Necessario de Envio (TLININS) 
	If nQLIns > 0
		SendInsert() // Envia ao Banco o Inseert
		nQLIns 	:= 0
		cInsLin := ""	
	EndIf
	
	Conout('IMPMETAS : ' + PadR("Finalizado Arquivo : "+cNomeF+" - Total Linhas: "+ToC(nLPerc) + ' U.Recno: ' + ToC(nRecno-1), 130 ) + Dtoc(ddatabase) + " " + time() )
	

	FT_FUSE()// O arquivo texto deve ser fechado, bem como o dialogo criado na funcao anterior.

Return()
*******************************************************************************
Static Function MntLinIns(aLinha, nQLIns) // Monta a Linha do Insert
*******************************************************************************
	Local cSql 		:= ""  //| Salva o Sql 
	Local cDoc 		:= ""  //| Numero Documento 
	Local cSeq 		:= ""  //| Sequencia do Documento
	Local cDescMetas:= ""  //| Descricao das Metas
	//Local cDataMeta := ""  //| Data da Meta
	Local cFilGer	:= ""  //| Filial do Gerente
	Local lAchou	:= .F. //| Se encontrou a Filial do Gerente 
	//Local cCliente	:= ""  //| Monta codigo do Cliente
	//Local cLojaCli	:= ""  //| Monta Loja do Cliente
	//Local cQuant 	:= StrTran(aLinha[F_QUANT],',','.') //
	//Local cValor 	:= StrTran(aLinha[F_VALOR],',','.') //
	//Local nPMGM3	:= 0 	//| Percentual Meta GM3
	//Local cPMGM3	:= '0'
	
	/// Tratamento Para Encontrar Filial do Gerente a ser utilizada na Meta
	lAchou := HMGet( oHashFG, aLinha[F_VEND], @cFilGer )
	If !lAchou
		cFilGer := Posicione("SA3",1,xFilial("SA3")+aLinha[F_VEND],"A3_CODFIL")
		HMSet( oHashFG, aLinha[F_VEND], cFilGer )
	EndIf

	// Obtem Descricao das Metas Conforme Filial 
	HMGet(oHashDM, aLinha[F_VEND], @cDescMetas )
	
	//| Tratamento de Formato de Data
	//cDataMeta := StrTran(aLinha[F_DATA],'-','')
	
	//| Prepara Codigo e Loja Cliente 
	//cCliente := aLinha[F_CLIENTE] //Substr(aLinha[F_CLIENTE],1,6)
	//cLojaCli := aLinha[F_LOJACLI] //Substr(aLinha[F_CLIENTE],7,2)
		
	
	// Obtem e Incrementa DOC e SEQ
	If !HMGet( oHashDS, cFilGer+'DOC', @cDoc )
		cDoc := 'CP0000001'
		cSeq := '001'
	Else
		HMGet( oHashDS, cFilGer+'SEQ', @cSeq )
	EndIf
	
	cSeq := Alltrim(cSeq)
	cDoc := Alltrim(cDoc)
	
	If cSeq == "ZZZ"
		cSeq := "001"
		cDoc := Soma1(cDoc,TAMDOC,.F.,.F.)
	Else
		cSeq := Soma1(cSeq,TAMSEQ,.F.,.F.)
	EndIf
	
	// Obtem Margem e Calcula 
	//If !HMGet( oHashG3, aLinha[F_VEND] + aLinha[F_MARCA3], @cPMGM3 )
	//	cPMGM3 := "0"
	//	nPMGM3 := 0
	//Else
		//conout("cValor : " + ValType(cValor) )
		//conout("nPMGM3 : " + ValType(nPMGM3) )
	//	cPMGM3 := Alltrim(cPMGM3)
	//	nPMGM3 := Round( Val(cValor) * Val(cPMGM3) / 100 , 4 ) 
		
	//EndIf
	
	
	// Apartir da Segunda Linha deve Inserir o UNION ALL
	If nQLIns > 1
		cSql += " FROM DUAL UNION ALL "
	EndIf
	
	//| Registro a Ser Inserido 
	cSql += " SELECT " 	
	cSql += " '"+cFilGer+"' "					+ aCpoSCT[1]  + "," //| CT_FILIAL,
	cSql += " '"+ cDoc +"' "					+ aCpoSCT[2]  + "," //| CT_DOC,
	cSql += " '"+ cSeq +"' "					+ aCpoSCT[3]  + "," //| CT_SEQUEN,
	cSql += " '"+cDescMetas+"' "				+ aCpoSCT[4]  + "," //| CT_DESCRI,
	cSql += " '"+aLinha[F_VEND]+"' "			+ aCpoSCT[5]  + "," //| CT_VEND,
	cSql += " '"+aLinha[F_DATA]+"' "     	   	+ aCpoSCT[6]  + "," //| CT_DATA,
	cSql += " '"+aLinha[F_PRODUTO]+"' "			+ aCpoSCT[7]  + "," //| CT_PRODUTO,
	cSql += "  "+Toc(aLinha[F_QUANT],.T.)+" "   + aCpoSCT[8]  + "," //| CT_QUANT,
	cSql += "  "+Toc(aLinha[F_VALOR],.T.)+" "	+ aCpoSCT[9]  + "," //| CT_VALOR,
	cSql += " '1' "								+ aCpoSCT[10] + "," //| CT_MOEDA,
	cSql += "  "+Toc(aLinha[F_MARGEM],.T.)+" "	+ aCpoSCT[11] + "," //| CT_MARGEM,
	cSql += " '"+aLinha[F_CLIENTE]+"' "			+ aCpoSCT[12] + "," //| CT_CLIENTE,
	cSql += " '"+aLinha[F_LOJACLI]+"' "			+ aCpoSCT[13] + "," //| CT_LOJACLI,
	cSql += " '"+aLinha[F_GRPSEGT]+"' "			+ aCpoSCT[14] + "," //| CT_GRPSEGT,
	cSql += " '"+aLinha[F_MARCA3]+"' "			+ aCpoSCT[15] + "," //| CT_MARCA3
	cSql += " '9' "								+ aCpoSCT[16] + "," //| CT_RELAUTO,
	cSql += "  "+Toc(aLinha[F_MARGVLR],.T.)+" "	+ aCpoSCT[17] + "," //| CT_MARGVLR,
	cSql += " '0' "								+ aCpoSCT[18] + "," //| R_E_C_D_E_L_,
	cSql += "  "+ToC(nRecno)+" "				+ aCpoSCT[19] + " " //| R_E_C_N_O_
	
	
	
	// Atualiza DOC e SEQ Utilizados
	HMSet( oHashDS, cFilGer+'DOC', @cDoc )
	HMSet( oHashDS, cFilGer+'SEQ', @cSeq )	
	
	//| Atualiza Recno
	nRecno += 1
	
	
	
	// Adiciona a Linha a Variavel que armazena as linhas
	cInsLin += cSql

Return Nil 

*********************************************************************
Static Function SendInsert()
*********************************************************************
	
	
	Local cError := U_ExecMySql( cInsCab + cInsLin + " FROM DUAL " + cInsRod , '' , cModo := "E" , lMostra := .F. , lChange := .F. )
	
	//Conout('IMPMETAS : ' + PadR('Inserindo Registros na Tela de Metas: ' + cFile, 100 ) + Dtoc(ddatabase) + " " + time() )
	
	
	If Alltrim(cError) <> 'Executado Com Sucesso'
		 conout(" METAS - cError: "+ cError + " " )
	EndIf
	
	
Return Nil 
*********************************************************************
Static Function ToC(cval,lCViPo) // Converte para caracter qualquer tipo de variavel
*********************************************************************
	Default lCViPo := .F. // Converte Virgula em Ponto 

	If lCViPo
		cval := StrTran( cval, ',', '.', )
	EndIf

Return( cValToChar(cval) )
