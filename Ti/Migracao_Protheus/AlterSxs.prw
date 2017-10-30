#Include 'protheus.ch'
#Include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : AlterSxs.prw | AUTOR : Cristiano Machado | DATA : 19/10/2017**
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  **
**---------------------------------------------------------------------------**
** USO : Especifico para   **
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
User function AlterSxs()
*******************************************************************************


Private aPreComp =: {}
Private aPosComp =: {}

CadPre(aPreComp)

CadPos(aPosComp)

//Pre Alteracoes
PreAlt()


// Pós Alteracoes
PosAlt()
	
return


Static Function PreAlt()



Return()
*******************************************************************************
Static Function CadPre(aPreComp)  // Efetua o Cadastro das Alteracoes que devem ser efetuadas Pre Compatibilizador
*******************************************************************************

AADD( aPreComp , {  TABELA , CAMPO , CONTEUDO } )
AADD( aPreComp , {  TABELA , CAMPO , CONTEUDO } )
AADD( aPreComp , {  TABELA , CAMPO , CONTEUDO } )
AADD( aPreComp , {  TABELA , CAMPO , CONTEUDO } )

Return()
*******************************************************************************
Static Function CadPos(aPosComp) // Efetua o Cadastro das Alteracoes que devem ser efetuadas Pos Compatibilizador
*******************************************************************************
//| Estrutura Array:
//| Array { TAB , CPO , OPE , IND , CON } 
//| TAB := Tabela SX em questão.
//| CPO := Campo SX que deve ser alimentado.
//| OPE := Tipo de Operacao, atualizacao ou inclusao.
//| IND := Chave a ser utilizada com indice para posicionar registro no SX em questao.
//| CON := Conteudo a ser utilizado.

// SX2 -> INDICE 1 -> X2_CHAVE
AADD( aPosComp , { "SX2"	, "X2_UNICO" 	,.F. , "ADB" 	, "ADB_FILIAL+ADB_NUMCTR+ADB_ITEM+ADB_CODPRO" } )
AADD( aPosComp , { "SX2"	, "X2_UNICO" 	,.F. , "SU2" 	, "U2_FILIAL+U2_COD+U2_CONCOR+U2_SEQID" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ1" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ2" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ3" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ4" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ5" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ6" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ7" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ8" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQ9" 	, "C" } )
AADD( aPosComp , { "SX2"	, "X2_MODO" 	,.F. , "CQA" 	, "C" } )


// SX3 -> INDICE 2 -> X3_CAMPO
AADD( aPosComp , { "SX3"	, "X3_VLDUSER" 	, .F. , "DA1_PERDES" 	, "U_GATFAT()" } )
AADD( aPosComp , { "SX3"	, "X3_VLDUSER"	, .F. , "DA1_PERDES"	, "U_GATFAT()" } )                                                                                                                
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_BAIRROC"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_BANCO1"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_BLEMAIL"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_VALID"	, .F. , "A1_CGC"		, "Vazio() .Or. IIF( M->A1_TIPO == 'X', .T., (CGC(M->A1_CGC) .And. A030CGC(M->A1_PESSOA, M->A1_CGC) .And. A020VldUCod()))" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_CIFDEST"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_CLASSE"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_DTENVIO"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_ESTQFIL"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_LC"		, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_LCFIN"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_MAILNFE"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_RISCO"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_ULTCOM"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_USADDA"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_VENCLC"	, "2" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_VMAIPRD"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_VMAIPRD"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "A1_VMAIREC"	, "5" } )
AADD( aPosComp , { "SX3"	, "X3_VALID"	, .F. , "A2_CGC"		, "Vazio() .Or. IIF( M->A2_TIPO == 'X', .T., (CGC(M->A2_CGC) .And. A020CGC(M->A2_TIPO, M->A2_CGC) .And. A030VldUCod()))" } )
AADD( aPosComp , { "SX3"	, "X3_RELACAO"	, .F. , "A4_COD"		, "GETSXENUM('SA4','A4_COD')" } ) 
AADD( aPosComp , { "SX3"	, "X3_FOLDER"	, .F. , "B1_CEST"		, "2" } )
AADD( aPosComp , { "SX3"	, "X3_CBOX"		, .F. , "B1_CLASSVE"	, "1=Normal;2=Especial;3=Manual(Desc Filial);4=Eliminado" } )                                                                                      
AADD( aPosComp , { "SX3"	, "X3_TAMANHO"	, .F. , "B1_CODITE"	, "35" } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "B1_CODITE"	, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_RESERV"	, .F. , "B1_CODITE"	, "þA" } )
AADD( aPosComp , { "SX3"	, "X3_RELACAO"	, .F. , "B1_CODITE"	, "SB1->B1_CODITE" } )                                                                                                                  
AADD( aPosComp , { "SX3"	, "X3_PICTVAR"	, .F. , "B1_CODITE"	, " " } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "B1_GRPTIDC"	, "€€€€€€€€€€€€€€€" } )
AADD( aPosComp , { "SX3"	, "X3_CONTEXT"	, .F. , "B2_CODITE"	, "R" } )
AADD( aPosComp , { "SX3"	, "X3_TAMANHO"	, .F. , "B2_CODITE"	, "35" } )
AADD( aPosComp , { "SX3"	, "X3_RELACAO"	, .F. , "C1_FILENT"	, "cFilAnt" } )       
AADD( aPosComp , { "SX3"	, "X3_RELACAO"	, .F. , "C1_UNIDREQ"	, "cFilAnt" } )  
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "D1_DOC"		, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "D1_FORNECE"	, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "D1_LOJA"		, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_NIVEL"	, .F. , "D1_ORDEM"	, "1" } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "D1_SERIE"	, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "E2_FILIAL"	, "€€€€€€€€€€€€€€ " } )
AADD( aPosComp , { "SX3"	, "X3_F3"		, .F. , "UA_CLIENTE"	, "CLTVEN" } )
AADD( aPosComp , { "SX3"	, "X3_F3"		, .F. , "UA_CODMOT"	, "MOTSUA" } )
AADD( aPosComp , { "SX3"	, "X3_F3"		, .F. , "UC_CODCONT"	, "SU5IMD" } )
AADD( aPosComp , { "SX3"	, "X3_RELACAO"	, .F. , "W2_MOEDA"	, "GETMV('MV_SIMB2')" } )
AADD( aPosComp , { "SX3"	, "X3_USADO"	, .F. , "W9_SEGINC"	, "€€?€€€€€€€€€€€€" } )

// SX6 -> INDICE 1 -> X6_FILIAL + X6_VAR
AADD( aPosComp , { "SX6"	, "X6_CONTEUDO" 	, "  MV_INTWMS" 	, ".T." } )
AADD( aPosComp , { "SX6"	, "X6_CONTEUDO" 	, "  MV_INTTAF" 	, "N" 	} )
AADD( aPosComp , { "SX6"	, "X6_CONTEUDO" 	, "  MV_CANCEXT" 	, "30" 	} )
AADD( aPosComp , { "SX6"	, "X6_CONTEUDO" 	, "  MV_INTWMS" 	, ".T." } )

// SX7 -> INDICE 1 -> X6_FILIAL + X6_VAR
AADD( aPosComp , { "SX7"	, "X7_CONDIC" 	, "D1_COD    003" 	, "Found() .And. INTDL(M->D1_COD) " } )
AADD( aPosComp , { "SX7"	, "X7_CONDIC" 	, "E5_BANCO  002" 	, "PROCNAME(12)='FA100PAG'" } )
AADD( aPosComp , { "SX7"	, "X7_CONDIC" 	, "E5_BANCO  003" 	, "PROCNAME(12)='FA100REC'" } )



Return()