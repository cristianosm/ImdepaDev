
User function TsTmail()

//Exemplo TMailMessage com Imagem
//Este exemplo de uso da classe TMailMessage, visa o uso e explica��o de dois m�todos da classe:
//SetConfirmRead() e AddAttHTag().
//SetConfirmRead() tem como objetivo, mandar uma solicita��o de resposta de Leitura para a pessoa
//que receber o e-mail, podendo ela optar por mandar ou n�o.
//AddAttHTag() tem como objetivo incluir tags no cabe�alho(header) da mensagem. Obs: este cabe�alho
//n�o � cabe�alho do corpo da mensagem.
//Neste exemplo da fun��o usaremos uma tag para colocarmos a imagem no corpo do texto, ap�s
//carregar a imagem, atribuimos um ID para ele, da seguinte forma: 'Content-ID: &lt;ID_siga.jpg&gt;'
//A parte em negrito significa o ID que atribuimos para a imagem, o que est� entre as aspas deve
//ser seguido por padr�o com o protocolo.
//Note que quando criamos o html que comp�e a mensagem usamos esse ID:
//oMessage:cBody   := 'Teste&lt;br&gt;&lt;img src='cid:ID_siga.jpg'&gt;'
//Assim a imagem ser� carregada normalmente.

  Local oMailServer := TMailManager():New()
  Local oMessage := TMailMessage():New()
  Local nErro := 0
  oMailServer:Init( "", "smtp.imdepa.com.br", "", "", 0, 25 )
  If( (nErro := oMailServer:SmtpConnect()) != 0 )
    alert( "N�o conectou.", oMailServer:GetErrorString( nErro ) )
    Return
  EndIf
  oMessage:Clear()
  oMessage:cFrom           := "protheus@imdepa.com.br"
   
  //Altere
  oMessage:cTo             := "cristiano.machado@imdepa.com.br"
   
  //Altere
  oMessage:cCc             := ""
  oMessage:cBcc            := ""
  oMessage:cSubject        := "Teste de envio d e-mail"
  oMessage:cBody           := "Teste&lt;br&gt;&lt;img src='cid:ID_siga.jpg'&gt;"
  oMessage:MsgBodyType( "text/html" )
   
  // Para solicitar confima��o de envio
  //oMessage:SetConfirmRead( .T. )
   
  // Adiciona um anexo, nesse caso a imagem esta no root
 // oMessage:AttachFile( 'c:\mp11\sc632720.pdf' )
  oMessage:AttachFile( 'system\anexos\sc638600.pdf' ) 
  // Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
  //oMessage:AddAttHTag( 'Content-ID: &lt;ID_siga.jpg&gt;' )
  nErro := oMessage:Send( oMailServer )
  If( nErro != 0 )
    alert( "N�o enviou o e-mail.", oMailServer:GetErrorString( nErro ) )
    Return
  EndIf
  nErro := oMailServer:SmtpDisconnect()
  If( nErro != 0 )
    alert( "N�o desconectou.", oMailServer:GetErrorString( nErro ) )
    Return
  EndIf

Return()