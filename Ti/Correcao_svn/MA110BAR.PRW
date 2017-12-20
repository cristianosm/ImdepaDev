#include "totvs.ch"
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³MA110BAR  ºAUTOR  ³CRISTIANO MACHADO   º DATA ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³Inclui Botao para importacao de arquivo .CSV na solicitacao º±±
±±º          ³de compras. o arquivo deve ter dois campos [codigo de produ-º±±
±±º          ³to] e [quantidade]                                          º±±
±±º          ³PE PARA MATA110.PRX                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ MP8 IMDEPA ROLAMENTOS                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
USER FUNCTION MA110BAR()
*********************************************************************

ABOTAO := {}
AADD( ABOTAO, { "S4WB001N", { || ARQUIVO() }, "IMP. CSV" } )

RETURN(ABOTAO)


*********************************************************************
STATIC FUNCTION ARQUIVO()
*********************************************************************
PRIVATE CALIAS  	:= ALIAS()
PRIVATE CINDEXORD	:= INDEXORD()
PRIVATE CRECNO		:= RECNO()

PRIVATE NORDSB1	:= SB1->( INDEXORD() )
PRIVATE NRECSB1 := SB1->( RECNO() )
SB1->( DBSETORDER( 1 ) )

PRIVATE NORDSB2	:= SB2->( INDEXORD() )
PRIVATE NRECSB2 := SB2->( RECNO() )
SB2->( DBSETORDER( 1 ) )

//CONVARQ()

CTIPO := ""
CTIPO := CTIPO + "ARQUIVOS DE DADOS (*.CSV)  | *.CSV | "
CFILE := CGETFILE( CTIPO , "DIALOGO DE SELECAO DE ARQUIVOS /.CSV",,"C:\EXCEL") //,,GETF_MULTISELECT+GETF_LOCALHARD+GETF_NETWORKDRIVE ) //,.T.,GETF_NOCHANGEDIR+GETF_NETWORKDRIVE)//GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
CARQ  := ALLTRIM(CFILE)

IF !EMPTY(CARQ)
	PROCESSA( {|| CONVARQ() } , "PROCESSANDO DADOS" 		, "PROCESSANDO DADOS ... /AGUARDE... ", .T. )
	PROCESSA( {|| MIGRA() }   , "IMPORTACAO PED.COMPRA" 	, "IMPORTANDO DADOS ... /AGUARDE...  ", .T. )
ENDIF

DBSELECTAREA("SB1")
DBSETORDER(NORDSB1)
DBGOTO(NRECSB1)

DBSELECTAREA("SB2")
DBSETORDER(NORDSB2)
DBGOTO(NRECSB2)

DBSELECTAREA(CALIAS)
DBSETORDER(CINDEXORD)
DBGOTO(CRECNO)

RETURN()
*********************************************************************
STATIC FUNCTION CONVARQ()
*********************************************************************
Local _cProduto := ""

//PRIVATE	CPATH 	:= "C:\EXCEL\PEDIDO.csv"
PRIVATE	CPATH 	:= CARQ
PRIVATE ASTRU 	:= {}
PRIVATE NDEL 	:= 0
PRIVATE lPrim   := .F.
PRIVATE aDados  := {}
PRIVATE nCols   := 0
PRIVATE cCab    :=''
PRIVATE PUsaCab :=.F.
PRIVATE aCSV    := {}
PRIVATE I       := 0

/*
IF !INCLUI
	ALERT("Somente Disponivel na Inclusao/Alteração da Solicitação!!")
	RETURN()
ENDIF
*/

IF !FILE(CPATH)
	ALERT("O Arquivo " + CPATH + " não existe !!!")
    RETURN()
ENDIF


//CRIA DBF PARA SER ALIMENTADO PELO ARQUIVO CSV
AADD(ASTRU,{"PRODUTO" ,"C",15,0})
AADD(ASTRU,{"QUANT"   ,"N",14,2})

///02/12/2011 - JULIO JACOVENKO, modificacao solicitada pelo chamado AAZU2A (usuario Everton)
///solicitado importador data
AADD(ASTRU,{"DATAE" ,"D",08,0})   //NO CVS, TEM DE SER DD/MM/AA
AADD(ASTRU,{"OBS"   ,"C",60,0})   //MAXIMO DE CARACTERES QUE PEGA DO CVS
///////////////////////////////////////////////////

CARQ := CRIATRAB(ASTRU,.T.)

USE &CARQ EXCLUSIVE ALIAS TRAB NEW
INDEX ON  PRODUTO TAG 1 TO &CARQ

//ABRI ARQUIVO TEXTO
FT_FUSE(CPATH)
//PULA P/ LINHA 1
FT_FGOTOP()



    aDados := Array(0,5)



   //agora vamos alimentar o array
    FT_FGOTOP()
    WHILE !FT_FEOF()//ENQUANTO NAO FOR O FIM DO ARQUIVO TEXTO

		CLINHA 	:= FT_FREADLN()//LE A LINHA DO ARQUIVO

	 	IIF(AT(",",CLINHA) > 0, NDEL := AT(",",CLINHA), NDEL := AT(";",CLINHA) )

		IF 	VAL(SUBSTR(CLINHA,NDEL+1,LEN(CLINHA))) > 0 .OR. !empty(STRZERO(VAL(SUBSTR(CLINHA,001,NDEL-1)),8))
				If lPrim
					aCampos := Separa(cLinha,";",.T.) //CABECALHO SE HOUVER
					lPrim := .F.
				Else
					AADD(aDados,Separa(cLinha,";",.T.))
				EndIf
		ENDIF

		FT_FSKIP()//PULA UMA LINHA NO ARQUIVO

    ENDDO


	FOR X:=1 TO LEN(ADADOS)

		_cProduto := Iif( Len( AllTrim( ADADOS[X][1] ) ) < 10, STRZERO( VAL( ADADOS[X][1] ), 8 ), AllTrim( ADADOS[X][1] ) )

	    ///JULIO, em 08/04/2012
		// Jean Rehermann - Solutio IT - 22/09/2015 - Trato o tamanho do codigo do produto
		//IF DBSEEK(STRZERO(VAL(ADADOS[X][1]),8))
		IF DBSEEK(_cProduto)
			RECLOCK("TRAB",.F.)
			TRAB->QUANT += VAL(ADADOS[X][2])
		Else
			RECLOCK("TRAB",.T.)
			TRAB->QUANT := VAL(ADADOS[X][2])
		Endif

		// Jean Rehermann - Solutio IT - 22/09/2015 - Trato o tamanho do codigo do produto
		//TRAB->PRODUTO := STRZERO(VAL(ADADOS[X][1]),8)
		TRAB->PRODUTO := _cProduto
		//TRAB->QUANT 	:= VAL(ADADOS[X][2])

		cCOLUNA:=LEN(ADADOS[x])

	    If cColuna>=3 .and. ALLTRIM(ADADOS[X][3])<>''
	 		TRAB->DATAE     := CTOD(ADADOS[X][3])
		ElseIf cColuna>=3 .and. ALLTRIM(ADADOS[X][3])==''
			TRAB->DATAE     := dDataBase
		ElseIf cColuna<3
			//ALERT('<3 '+str(cColuna) )
			TRAB->DATAE     := dDataBase
		EndIf


		If cColuna>=4  .and. ALLTRIM(ADADOS[X][4])<>''
			TRAB->OBS       := ADADOS[X][4]
		ElseIf cColuna<4
			TRAB->OBS       :=' '
		EndIf

		MSUNLOCK()
	NEXT

	DBSELECTAREA("TRAB")
	DBCLOSEAREA()

RETURN()

*********************************************************************
STATIC FUNCTION MIGRA()
*********************************************************************
LOCAL NREG  	:= 0
LOCAL NPRECO	:= 0
LOCAL NCOUNT  	:= 0
LOCAL LPOS  	:= .T.

IF EMPTY(CARQ)
	ALERT("SELECIONE UM ARQUIVO !!")
	RETURN()
ELSE

	USE &CARQ ALIAS TRB NEW
	CID       := RETCODUSR()
	CSOLICIT  := SUBSTR(CUSUARIO,7,14)

	TRB->(PROCREGUA(LASTREC()))
	TRB->(DBGOTOP())


	N	:= 1
	WHILE !EOF()
		CPRODUTO  	:= ALLTRIM(TRB->PRODUTO)+SPACE(15-LEN(ALLTRIM(TRB->PRODUTO)))

		SB1->( DBSETORDER( 1 ) )
		IF SB1->(DBSEEK(XFILIAL("SB1")+CPRODUTO,.F.)) //SB1->(DBSEEK(XFILIAL("SB1")+TRB->PRODUTO,.F.))


			CDESCR   	:= SB1->B1_DESC
			NQUANT    	:= TRB->QUANT
			CUNID    	:= SB1->B1_UM
			CSEGUNID 	:= SB1->B1_SEGUM
			CARMAZEM 	:= SB1->B1_LOCPAD
			NPRECO	  	:= 0

           	IIF(LEN(ACOLS)>1,NREG:=LEN(ACOLS)+1,NREG:=NREG+1)
           	NCOUNT++

//    		NREG	:= NREG + 1

		ELSE

			ALERT("PRODUTO " +TRB->PRODUTO+" NAO ENCONTRADO NESTA FILIAL!!!")
			DBSELECTAREA("TRB")
			TRB->(DBSKIP())
			INCPROC()
			LOOP

		ENDIF

		IF NREG > 0

			IF NREG > 1
				AADD(ACOLS,ARRAY(LEN(AHEADER)+1))
			ENDIF

			// INICIALIZA CAMPOS DEFAULT COM INICIALIZADOR PADRAO
			FOR I := 1 TO LEN(AHEADER)
				IF !(ALLTRIM(AHEADER[I][2]) $ "C1_ITEM/C1_PRODUTO/C1_DESCRI/C1_UM/C1_QUJE/C1_EMISSAO/C1_DATPRF/C1_LOCAL/C1_SEGUM/C1_OBS/C1_ALI_WT/C1_REC_WT")
					If I < 32 // Nao faz o criavar para os campos ALIAS E RECNO WT
						ACOLS[LEN(ACOLS)][I] := CRIAVAR(AHEADER[I][2])
					EndIf
				ENDIF
			NEXT I



			IF NREG > 1
				N := NREG
				GDFIELDPUT("C1_ITEM"	, STRZERO(N,4)		,N)
			ENDIF

			DBSELECTAREA("SB2");DBSETORDER(1)
			DBSEEK(XFILIAL("SB2")+CPRODUTO+CARMAZEM,.F.)
			GDFIELDPUT("C1_PRODUTO"	, CPRODUTO	,N)//;IIF(EXISTTRIGGER( "C1_PRODUTO" )	, RUNTRIGGER(2, N),"")


			IF LPOS
				__READVAR:="M->C1_PRODUTO"
				POSICIONE("SX3",2,"C1_PRODUTO","X3_CAMPO")
				LPOS := .F.
			ENDIF

			CHECKSX3("C1_PRODUTO",CPRODUTO)
			RUNTRIGGER(2, N,"C1_PRODUTO")

			GDFIELDPUT("C1_DESCRI"	, CDESCR	,N)//;IIF(EXISTTRIGGER( "C1_DESCRI" 	)	, RUNTRIGGER(2, N),"")
			GDFIELDPUT("C1_UM"		, CUNID		,N)//;IIF(EXISTTRIGGER( "C1_UM" 		)	, RUNTRIGGER(2, N),"")
			GDFIELDPUT("C1_QUANT"	, NQUANT	,N)//;IIF(EXISTTRIGGER( "C1_QUANT" 	)	, RUNTRIGGER(2, N),"")//LIMPA PRODUTO

			//			MAFISREF( 'IT_QUANT', 'MT120', GDFIELDGET( 'C1_QUANT', N ) )//LIMPA PRODUTO
			//			NPRECO := BUSCAPR(NPRECO)
			SB1->(DBSEEK(XFILIAL("SB1")+ACOLS[N,2],.F.))
			NPRECO := SB1->B1_PRV1

			GDFIELDPUT( 'C1_VUNIT', NPRECO, N )
			//			GDFIELDPUT( 'C1_QUJE', NOROUND( GDFIELDGET( 'C1_VUNIT', N ) * GDFIELDGET( 'C1_QUANT', N ), TAMSX3( 'C1_QUJE' )[ 2 ] ), N )


			GDFIELDPUT("C1_EMISSAO"	, DDATABASE	,N)//;IIF(EXISTTRIGGER( "C1_EMISSAO" 	)	, RUNTRIGGER(2, N),"")

			///02/12/2011 - Julo Jacovenko - chamado AAZU2A
			///pegar data
			GDFIELDPUT("C1_DATPRF"	, TRB->DATAE	,N)//;IIF(EXISTTRIGGER( "C1_EMISSAO" 	)	, RUNTRIGGER(2, N),"")

			GDFIELDPUT("C1_LOCAL"	, CARMAZEM	,N)//;IIF(EXISTTRIGGER( "C1_LOCAL" 	)	, RUNTRIGGER(2, N),"")
			GDFIELDPUT("C1_SEGUM"	, CSEGUNID	,N)

			//02/12/2011 - Julio Jacovenko - chamado AAZU2A
            ///COLOCA A C1_OBS
			GDFIELDPUT("C1_OBS"	, TRB->OBS  	,N)//;IIF(EXISTTRIGGER( "C1_DESCRI" 	)	, RUNTRIGGER(2, N),"")

			//Inserido por Edivaldo Goncalves Cordeiro - Tratamento para novos campos
			GDFIELDPUT("C1_TPSC"	, '1'   	,N)
   		    GDFIELDPUT("C1_MODAL"	, SPACE(1)	,N)
   		    GDFIELDPUT("C1_TPMOD"	, ' '   	,N)
   		    GDFIELDPUT("C1_CODED"   , SPACE(1)	,N)
   		    GDFIELDPUT("C1_NUMPR"   , SPACE(1)	,N)
   		    GDFIELDPUT("C1_ORCAM"   , SPACE(1)	,N)
   	        GDFIELDPUT("C1_ORIGEM"  , SPACE(1)	,N)
   	        GDFIELDPUT("C1_FLAGGCT"  , SPACE(1)	,N)
   	        GDFIELDPUT("C1_PROGRAM"  , SPACE(1)	,N)


			ACOLS[LEN(ACOLS)][LEN(AHEADER)+1] := .F.

		ENDIF
		DBSELECTAREA("TRB")
		TRB->(DBSKIP())
		INCPROC()


	ENDDO

	IF NREG == 0
		ALERT("NENHUM REGISTRO IMPORTADO!!!")
	ELSE
		ALERT("IMPORTADOS "+STR(NCOUNT)+"  REGISTROS!!!")
	ENDIF

ENDIF

TRB->(DBCLOSEAREA())
SB1->(DBSEEK(XFILIAL("SB1")+ACOLS[1,2],.F.))

//DBSELECTAREA(CALIAS)

RETURN()