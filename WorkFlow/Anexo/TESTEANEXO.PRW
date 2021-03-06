#INCLUDE "RWMAKE.CH"
#INCLUDE 'TBICONN.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO3     � Autor � AP6 IDE            � Data �  09/07/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

******************************************************************************
User Function TESTEANEXO()
******************************************************************************
Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         	:= "de acordo com os parametros informados pelo usuario."
Local cDesc3         	:= "TESTE"
Local cPict          	:= ""
Local titulo       	:= "TESTE"
Local nLin         	:= 80
Local Cabec1       	:= "CABEC1"
Local Cabec2       	:= "CABEC2"
Local imprime      	:= .T.

Private aOrd         	:= {"A1_COD"}
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private limite       	:= 80
Private tamanho      	:= "P"
Private nomeprog     	:= "RELTST" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        	:= 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 2, 1, 1,"", 1}
Private nLastKey   	:= 0
Private cPerg      	:= "A1_COD"
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "RELTST" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 		:= "SA1"

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" MODULO "FAT" USER "WORK" PASSWORD "WORK" FUNNAME 'TESTE'  TABLES 'SA1'

DbSelectArea("SF2");DbSetOrder(1)

Pergunte(cPerg,.F.)

//� Monta a interface padrao com o usuario...                           �
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.,.F.,,,.T.,)
		 // SetPrint("RELTST",cPergunte [ cTitle ] [ cDesc1 ] [ cDesc2 ] [ cDesc3 ] [ lDic ] [ aOrd ] [ lCompres ] [ cSize ] [ uParm12 ] [ lFilter ] [ lCrystal ] [ cNameDrv ] [ uParm16 ] [ lServer ] [ cPortPrint ] ) --> cReturn
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)


Reset Environment


Return()
******************************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
******************************************************************************
Local nOrdem
Local Codigo := "N00000"
DbSelectArea(cString)

nOrdem := aReturn[8]
dbSetOrder(nOrdem)


SetRegua(RecCount())

DbGoTop()
DbSeek(xFilial("SA1")+"N00000",.F.)

While !EOF() .And. ( Codigo == SA1->A1_COD )

   //� Verifica o cancelamento pelo usuario...                             �

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //� Impressao do cabecalho do relatorio. . .                            �
   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

  	@nLin,10 PSAY SA1->A1_COD
	@nLin,20 PSAY SA1->A1_LOJA
	@nLin,30 PSAY SA1->A1_NOME

   	nLin := nLin + 1 // Avanca a linha de impressao

   	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//� Finaliza a execucao do relatorio...                                 �

SET DEVICE TO SCREEN

//� Se impressao em disco, chama o gerenciador de impressao...          �
//If aReturn[5] == 3


   cChave := Substr(dtos(dDatabase) + StrTran(Time(),':',''),1,12)
   aFile := ''

   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)

   	aFiles := Directory("\Relato\WorkFlow\*.spl")
	//cChave := dToc(dDatabase) + Time()

	For n :=1 To Len(aFiles)

		If Substr(dTos(aFiles[n][3]) + StrTran(aFiles[n][4],':',''),1,12) == cChave
			aFile := 	aFiles[n][1]
			exit
		EndIF
	Next

	fRename('\Relato\WorkFlow\'+aFile ,'\Relato\WorkFlow\reltst.##r' )


   //, { |aFile| FERASE(aFile[F_NAME]) })


//Endif

MS_FLUSH()

Return()