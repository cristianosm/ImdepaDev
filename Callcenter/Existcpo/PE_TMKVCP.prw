/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �U_TMKVCP  � Autor � Expedito Mendonca Jr. � Data � 01/05/2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza variavel informando que o usuario ja passou pela    ���
���          � condicao de pagamento e atualiza os precos com acrescimo.    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function TMKVCP(cCodTransp,oCodTransp,cTransp,oTransp,cCob,oCob,cEnt,oEnt,cCidadeC,oCidadeC,cCepC,oCepC,cUfC,oUfC,cBairroE,oBairroE,cBairroC,oBairroC,cCidadeE,oCidadeE,cCepE,oCepE,cUfE,oUfE,nOpc,cNumTlv,cCliente,cLoja,cCodPagto)

	Local lCondPagOK := .T.


// Atualiza o codigo da condicao de pagamento
	IF !EMPTY(cCodPagto)
		M->UA_CONDPG  := cCodPagto
		M->UA_DESCOND := SE4->E4_DESCRI
	            //JULIO JACOVENKO, em 15/03/2013 - melhoria
	            //para forcar o gatilho da condicao
	            //pois 'algumas' vezes nao estava efetuando este
	            //procedimento.


		//lOk := CheckSX3('UA_CONDPG',M->UA_CONDPG)
		//IF lOk
			//RunTrigger(3,,,,PADR('UA_CONDPG',03))
		//ENDIF

                //U_GTMKVFIM()
		//RunTrigger(3,,,,PADR('UB_PRODUTO',03))
	ENDIF
	M->UA_TRANSP  := cCodTransp

// Flag para identificar que o usuario ja clicou no botao de condicao de pagamento neste atendimento
	__lJaBotCPag := .T.


//����������������������������������������������������������������Ŀ
//� Atualiza a coluna de preco com acrescimo automaticamente       �
//� Atualiza a coluna especifica de preco unitario com acrescimo   �
//� financeiro (para todas as linhas do aCols)                     �
//������������������������������������������������������������������
	If PROCNAME(6)!='TK271HISTORICO'
		SE4->(U_AtuPrcAcres(SE4->E4_ACRSFIN,.F.))
	EndIf


//Inserido por Edivaldo Gon�alves Cordeiro em 20/05/06
	If M->UA_OPER=='1' //Quando for Faturamento exibe mensagem de alerta ao usu�rio para se certificar das TES Definidas no Pedido
		Aviso('Defini��o de TES','Caro Usu�rio '+AllTrim(SUBSTR(cusuario,7,15))+ ';'+CHR(10)+CHR(13)+'Verifique se a TES Definida neste pedido est� correta !',{'OK'})
	Endif

            ///JULIO JACOVENKO, em 04/05/2013
            ///para gravacao do percentual do frete no campo
            ///UA_PERFRT (virtual)
	nMerc:= 0 //MaFisRet(, "NF_TOTAL")    //funcao para pegar o valor da venda (ja calculado os impostos)
	M->UA_PERFRT:= (M->UA_FRETCAL / nMerc) * 100

Return lCondPagOK

