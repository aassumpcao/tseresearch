// JavaScript Document
$(function(){
    $(".box").click(function()
        {
            $(".box").hide(500);
        });
});
$(function(){
		   	   $("a.definicao").click(function ()
										{ 
										$(this).next().toggle(500);
										})	  
		   })
		   
$(function(){
		   	   $(".fechar").click(function ()
										{ 
										$(this).parent().hide(500);
										
										})	  
		   })

