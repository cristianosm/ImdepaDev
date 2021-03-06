#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DLGA150D  �Autor  �Edivaldo Goncalves  � Data �  10/19/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada no Estorno da OS. WMS                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Estorno da Impress�o do Pedido de Separacao                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function DLGA150D()
    Local   cProduto := PARAMIXB[1]
    Local   cLocal   := PARAMIXB[2]
    Local   cDocto   := PARAMIXB[3]
    Local   cSerie   := PARAMIXB[4]
    Local   RecnoDCF := PARAMIXB[5]
    Local   cOrigem  := DCF->DCF_ORIGEM     
    Local   lRet     := .T.    //--- Processamento... 
    Local   _lRadioF := ( SuperGetMV('MV_RADIOF', .F., 'N') == 'S' ) // Jean Rehermann - Solutio IT - 26/12/2018 - N�o executar quando RF OFF

   /*/
    PARAMIXB[1]			Array of Record			Produto					
    PARAMIXB[2]			Array of Record			Local										
	PARAMIXB[3]			Array of Record			Documento										
	PARAMIXB[4]			Array of Record			Serie										
	PARAMIXB[5]			Array of Record			Recno no DCF	
   /*/

    If cOrigem=='SC9'
      cAnPrintPedSep(cDocto)
    Endif 

    // Jean Rehermann - SOLUTIO IT - Reverte o local para o padr�o antes de estornar
    If cOrigem=='SD1' .And. _lRadioF .And. SDB->( FieldPos("DB_LOCEND") ) > 0
		RetLocPad(cDocto,cSerie,cProduto)
    Endif 

Return lRet 

 /*/ Funcao  : cAnPrintPedSep()
     Autor   : Edivaldo Goncalves Cordeiro
     Uso     : Estornar e liberar a Impressao do Pedido de separacao 
 /*/

Static Function cAnPrintPedSep(cNumPed)
      Local cSql:=' '
      
	  cSql := " UPDATE "+RetSqlName('SC6') //Estorna o pedido que ja havia sido impresso
	  cSql += " SET C6_IMPEMB = ' ' WHERE C6_FILIAL= '" + xFilial( 'SC6' ) + "'"
	  cSql += " AND C6_NUM = '"+cNumPed+"'"
	  cSql += " AND C6_IMPEMB='S'"
	  cSql += " AND D_E_L_E_T_=' '"
	  
	  TCSQLExec( cSql )
	  TCSQLExec('COMMIT')
Return

// Jean Rehermann - Solutio IT - Faz o ajuste do local padr�o antes de estornar
Static Function RetLocPad(cDocto,cSerie,cProduto)

      Local cSql:=' '
      
	  cSql := " UPDATE "+ RetSqlName('SDB')
	  cSql += " SET DB_LOCAL = DB_LOCEND "
	  cSql += " WHERE DB_FILIAL= '" + xFilial('SDB') + "'"
	  cSql += " AND DB_PRODUTO = '"+ cProduto +"'"
	  cSql += " AND DB_DOC     = '"+ cDocto   +"'"
	  cSql += " AND DB_SERIE   = '"+ cSerie   +"'"
	  cSql += " AND DB_NUMSEQ  = '"+ DCF->DCF_NUMSEQ +"'"
	  cSql += " AND DB_ESTORNO = ' '"
	  cSql += " AND DB_TIPO    = 'E'"
	  cSql += " AND D_E_L_E_T_ = ' '"

	  TCSQLExec( cSql )
	  TCSQLExec('COMMIT')

Return