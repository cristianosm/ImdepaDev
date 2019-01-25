#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 26/07/2016
PE para selecionar endereco destino (retorno NIL para não interferir no endereço de destino do SDB)
Estou utilizando este ponto de entrada não para alterar o endereço de destino, mas sim para gravar no SDB o DB_LOCAL com o conteúdo do campo
customizado DB_LOCEND para tratamento dos armazéns na conferência e endereçamento no recebimento de mercadorias.
Este ponto é exatamente antes de o programa alimentar o array aColetor com os itens a serem endereçados fisicamente (estoque)
*/

User Function DV080END()

    Local _cFilADB := SuperGetMV('IMD_ADBFIL', .F., '05') // Filiais onde deverá ser considerado o tratamento de armazéns 

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