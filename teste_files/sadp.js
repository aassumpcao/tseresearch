var atualLayer = "divProcesso";

function selectAll( el, tick ) { 
   var els = el.form.elements; 
   var x, i = els.length; 
   while ( i-- ) { 
     x = els[i]; 
     if ( 'input' == x.nodeName.toLowerCase() && 'checkbox' == x.type ) { 
       x.checked = tick; 
     } 
   } 
} 

function verificaTipoPesquisa() {
    if (document.PesquisaForm != null)
    for (var i=0; i < document.PesquisaForm.radioTipoPesquisa.length;i++){
      if(document.PesquisaForm.radioTipoPesquisa[i].checked){
        showHideLayerSwitch(document.PesquisaForm.radioTipoPesquisa[i].value);
      }
    }
}

function escolheTipoPesquisa(nomeLayer, acao) {
	showHideLayerSwitch(nomeLayer);
	document.PesquisaForm.acao.value = acao;
}

function checkAll( form, nome, quant ) {
	var arrayInput = document.getElementsByTagName('input');
	
	for ( i = 0; i < arrayInput.length ; i++  ) {
		var campoInput = arrayInput[i];
		if (campoInput.type == 'checkbox') {
			if (campoInput.checked) {
				campoInput.checked = false;
			} else {
				campoInput.checked = true;
			}			
		}
	}
}

function submitProcessos( form, nome, quant, msgError ){
   if( isChecked( form, nome, quant ) ){
   	if( msgError != null )
      	alert( msgError )
      return false
   }
   return true;
}

function isChecked( form, nome, quant ){
   for( i = 0; i < quant ; i++  )
      if( eval( 'form.' + nome + i ).checked )
         return true
	return false
}


function submitDelProcUsuario( form, numProc, numProt ){
   checado = false
   for( i = 0; i < numProc ; i++  )
      if( eval( "form.proc" + i  ).checked )
         checado = true
   for( i = 0; i < numProt ; i++  )
      if( eval( "form.prot" + i  ).checked )
         checado = true
   if( !checado  ){
      alert( "Selecione algo antes de submeter!" )
      return false
   }
   return true;
}

function isNewUserValid( form ){
	senha = form.senha.value;
	confirma_senha = form.confirma_senha.value;
	nome = form.nome.value;
	msg = ""
	if( nome == "" )
		msg += "O campo 'Nome' deve ser preenchido\n"
	if( senha == "" )
		msg += "O campo 'Senha' deve ser preenchido\n"
	if( confirma_senha == "" )
		msg += "O campo 'Confirme a Senha' deve ser preenchido\n"
	if( senha != confirma_senha )
		msg += "Os campos 'Senha' e 'Confirme a Senha' devem ser id\u00eanticos\n"
	if( ( form.email.value.indexOf("@") == -1 ) || ( form.email.value.indexOf(".") == -1 ) )
		msg += "Campo E-mail Inv\u00e1lido\n"
	if( msg != "" ){
		alert( msg )
		return false
	}else return true
}

function isLoginValid( form ){
	senha = form.senha.value
	email = form.email.value
	msg=""
	if( email == "")
		msg = msg + "O campo 'Email' deve ser preenchido!\n"
	else if( ( email.indexOf("@") == -1 ) || ( email.indexOf(".") == -1 ) )
		msg = msg + "Campo 'E-mail' Inv\u00e1lido!\n"
	if(senha == "")
		msg = msg + "O campo 'Senha' deve ser preenchido!\n"
	if( msg != "" ){
		alert( msg )
		return false
	}else return true
}

function isEmailValid( form ){
	email = form.email.value
	msg=""
	if( email == "")
		msg = msg + "O campo 'Email' deve ser preenchido!\n"
	else if( ( email.indexOf("@") == -1 ) || ( email.indexOf(".") == -1 ) )
		msg = msg + "Campo 'E-mail' Inv\u00e1lido!\n"
	if( msg != "" ){
		alert( msg )
		return false
	}else return true	
}

function isNumber( text ){
	for( var i = 0; i <= (text.length - 1); i++ )
		if( isNaN( parseInt( text.substring( i, i + 1 ) ) ) )
			return false;
		return true;
}

function newWindow( url ){
	newWindow( url, 'print', 600, 440, "no" )
}

function newWindow( url, name, width, height, toolbar ){
	window.open( url, name, 'width=' + width + ",height=" + height + ",toolbar=" + toolbar + ",menubar=yes,resizable=yes,maximize=yes,scrollbars=yes,top=40,left=40,alwaysRaised=yes");
}

function showClasses( tribunal ){
	urlClasse = "ServletPesquisa.do?action=classes&tribunal=" + tribunal
	var hWnd = window.open( urlClasse, "classes","width=400,height=325,resizable=yes,scrollbars=yes,menubar=yes" );
	if( ( document.window != null ) && !hWnd.opener ){
		hWnd.opener = document.window;
	}
}

// Tratamento do menu
var visibleVar = "null";

function showHideLayerSwitch(layerName){
	var visibilidade;
	
	if(atualLayer != null) hideLayer(atualLayer)

	atualLayer = layerName;
	
    visibilidade = document.getElementById(layerName).style.visibility;

	if (visibilidade == "visible") {
		hideLayer( layerName );
	} else {
		showLayer( layerName );
	}
}

function showLayer( layerName ){
    document.getElementById(layerName).style.visibility = "visible";
}

function hideLayer(layerName){
	document.getElementById(layerName).style.visibility = "hidden";
}

function setTribunal( form, valor ){
	form.tribunal.value = valor
}

function validaProcesso(){
	msg = ""
	if( document.processo.numero.value == "" ){
        msg += "- Favor preencher o n\u00famero ou a classe e n\u00famero do processo";
        document.processo.classe.focus();
	}
	if( msg != "" ){
		alert( msg );
		document.processo.classe.focus();
		return false;
	}
	return true;
}

function validaProtocolo(){
	if( document.protocolo.numero.value == "" ){
		alert( "Favor preencher o n\u00famero do protocolo" );
		document.protocolo.numero.focus();
		return false;
	}
	return true;
}

function validaNome( nome ){
	form = eval( 'document.' + nome );
	if( form.nome.value == "" ){
		alert( "Favor preencher o nome que se deseja consultar" );
		form.nome.focus();
		return false;
	}
	return true;
}

function validaNumeroNaOrigem(){
	msg = ""
	if( document.origem.numero.value == "" ){
        msg += "- Favor preencher o n\u00famero na origem";
        document.origem.numero.focus();
	}
	if( msg != "" ){
		alert( msg );
		document.origem.numero.focus();
		return false;
	}
	return true;
}

function validaMunicipo(){
	msg = ""
	if( document.municipio.nome.value == "" ){
        msg += "- Favor preencher o nome do munic\u00edpio";
        document.origem.numero.focus();
	}
	if( msg != "" ){
		alert( msg );
		document.municipio.nome.focus();
		return false;
	}
	return true;
}

function check(layerName){
	idForm = layerName.substring(3);
	formulario = document.getElementById(idForm);
	for (var i = 0 ; i < formulario.check.length; i++){
		if (formulario.check[i].value == layerName){
			formulario.check[i].checked = true;
		}
	}
}

function setaTribunal() {
	document.PesquisaForm.siglaTribunal.value = document.PesquisaForm.comboTribunal.value;
	document.PesquisaForm.nomeTribunal.value  = document.PesquisaForm.comboTribunal.options[document.PesquisaForm.comboTribunal.selectedIndex].text;	
}

function mudaTribunal(valor, indice) {
	document.PesquisaForm.siglaTribunal.value = valor;
	document.PesquisaForm.nomeTribunal.value = document.PesquisaForm.comboTribunal.options[indice].text;
    var tituloPagina = document.getElementById("tituloPagina");
    tituloPagina.innerHTML = 'Acompanhamento Processual e PUSH - ' + retornaNomeTribunal(valor.toUpperCase());
}

function retornaNomeTribunal(valor) {
  var retorno = "";
  
  if (valor == "RO") {
  	retorno = "Tribunal Regional Eleitoral - Rondônia"; 
  } else if (valor == "AC") {
	retorno = "Tribunal Regional Eleitoral - Acre";
  } else if (valor == "AM") {
	retorno = "Tribunal Regional Eleitoral - Amazonas";
  } else if (valor == "RR") {
	retorno = "Tribunal Regional Eleitoral - Roraima";
  } else if (valor == "PA") {
	retorno = "Tribunal Regional Eleitoral - Pará";
  } else if (valor == "AP") {
	retorno = "Tribunal Regional Eleitoral - Amapá";
  } else if (valor == "TO") {
	retorno = "Tribunal Regional Eleitoral - Tocantins";
  } else if (valor == "MA") {
	retorno = "Tribunal Regional Eleitoral - Maranhão";
  } else if (valor == "PI") {
	retorno = "Tribunal Regional Eleitoral - Piauí";
  } else if (valor == "CE") {
	retorno = "Tribunal Regional Eleitoral - Ceará";
  } else if (valor == "RN") {
	retorno = "Tribunal Regional Eleitoral - Rio Grande do Norte";
  } else if (valor == "PB") {
	retorno = "Tribunal Regional Eleitoral - Paraíba";
  } else if (valor == "PE") {
	retorno = "Tribunal Regional Eleitoral - Pernambuco";
  } else if (valor == "AL") {
	retorno = "Tribunal Regional Eleitoral - Alagoas";
  } else if (valor == "SE") {
	retorno = "Tribunal Regional Eleitoral - Sergipe";
  } else if (valor == "BA") {
	retorno = "Tribunal Regional Eleitoral - Bahia";
  } else if (valor == "MG") {
	retorno = "Tribunal Regional Eleitoral - Minas Gerais";
  } else if (valor == "ES") {
	retorno = "Tribunal Regional Eleitoral - Espírito Santo";
  } else if (valor == "RJ") {
	retorno = "Tribunal Regional Eleitoral - Rio de Janeiro";
  } else if (valor == "SP") {
	retorno = "Tribunal Regional Eleitoral - São Paulo";
  } else if (valor == "PR") {
	retorno = "Tribunal Regional Eleitoral - Paraná";
  } else if (valor == "SC") {
	retorno = "Tribunal Regional Eleitoral - Santa Catarina";
  } else if (valor == "RS") {
	retorno = "Tribunal Regional Eleitoral - Rio Grande do Sul";
  } else if (valor == "MS") {
	retorno = "Tribunal Regional Eleitoral - Mato Grosso do Sul";
  } else if (valor == "MT") {
	retorno = "Tribunal Regional Eleitoral - Mato Grosso";
  } else if (valor == "GO") {
	retorno = "Tribunal Regional Eleitoral - Goiás";
  } else if (valor == "DF") {
    retorno = "Tribunal Regional Eleitoral - Distrito Federal";
  } else if (valor == "TSE") {
    retorno = "Tribunal Superior Eleitoral";  
  }
  return retorno;  
}





function showDocDigitalizados(value)
{
	window.open("/DigiDocSadp/documentos.jsf?prot="+value, "_blank", "toolbar=no, scrollbars=yes, resizable=no, top=200, left=500, width=700, height=450");
}