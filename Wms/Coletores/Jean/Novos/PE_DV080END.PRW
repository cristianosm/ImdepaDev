#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 26/07/2016
PE para selecionar endereco destino (retorno NIL para n�o interferir no endere�o de destino do SDB)
Estou utilizando este ponto de entrada n�o para alterar o endere�o de destino, mas sim para gravar no SDB o DB_LOCAL com o conte�do do campo
customizado DB_LOCEND para tratamento dos armaz�ns na confer�ncia e endere�amento no recebimento de mercadorias.
Este ponto � exatamente antes de o programa alimentar o array aColetor com os itens a serem endere�ados fisicamente (estoque)
*/

User Function DV080END()

    Local _cFilADB := SuperGetMV('IMD_ADBFIL', .F., '05') // Filiais onde dever� ser considerado o tratamento de armaz�ns 

	If SDB->( FieldPos("DB_LOCEND") ) > 0 .And.;
		cFilAnt $ _cFilADB .And.;
		SDB->DB_LOCAL != SDB->DB_LOCEND .And.;
		SDB->DB_SERVIC =='003' .And.;
		SDB->DB_TAREFA == '009' .And.;
		SDB->DB_ATIVID == '042'
	
		Reclock( "SDB", .F. )
			SDB->DB_LOCAL  := SDB->DB_LOCEND
		SDB->( MsUnLock() )
		
	EndIf

Return( Nil )