
$(document).ready(
function(){
	var ajax_prefix = location.origin + '/simple_parser/search?params=';
	$('.search_start').on('click',
	function(){
		var query_text = $('.query_text')[9].val();
		if (true){
			var req_obj = {mode:'search_by_text', text:query_text};
			$.ajax(
				{
					url: ajax_prefix + JSON.stringify(req_obj),
					success: function(data){
						alert(JSON.stringify(data, null, 2));
					}
					}
			);
		}
	});
	$('.select_model').on('change',
	   function(){
	   	var model = $('.select_model')[0].val();
	   	var brand = $('.select_brand')[0].val();
	   	if ((model.length > 0)&&(brand.length>0)){
	   		req_obj = {mode:'get_model_info', model:model, brand:brand}
	   		$.ajax({
	   			url : ajax_prefix + JSON.stringify(req_obj),
	   			success: function(data){
	   				if (data.model_params){
	   					var txt = '';
	   					for (var key in data.model_params){
	   						txt += '<tr><th rowspan = ' + data.model_params[key].length + '>'+ key + '</th>';
	   						txt += '<td>' + data.model_params[key][0].name + '</td><td>' + data.model_params[key][0].value+ '</td>';
	   						txt += '</tr>';
	   						for (var i = 1; i< data.model_params[key].length;i++){
	   						txt += '<tr>'
	   						txt += '<td>' + data.model_params[key][i].name + '</td><td>' + data.model_params[key][i].value +'</td>';
	   						txt += '</tr>';
	   						}
	   					}//of key in
	   					txt = '<table border><tbody>' + txt + '</tbody></table>';
	   					$('.model_info').html(txt);
	   				}
	   			}
	   			
	   		}
	   		)
	   		
	   	}
	   }
);
    $('.select_brand').on('change',
              function(){
                var brand = $('.select_brand')[0].val();
                $('.select_model').html('');
                $('.model_info').html('');
        
	            if (brand.length > 0){
	
                var req_obj = {mode:'get_models_by_brand', brand:brand};
           
                $.ajax({
                  url: ajax_prefix+JSON.stringify(req_obj),
                 success: function(data){
                 	data.unshift({name:''});
			 $('.select_phone').html('');
                   for (var i = 0; i< data.length; i++){
                     $('.select_model').append('<option value = "' + data[i].name + '">' + data[i].name + '</option>');
                   }
                 }
                });
             }}
              
    );
    $.ajax({
      url: 'search?params={"mode":"get_brands"}',
   success: function(data){
   	data.unshift({name:''});
     for (var i = 0; i< data.length; i++){
       $('.select_brand').append('<option value = "' + data[i].name + '">' + data[i].name + '</option>');
     }
   }
    })
  }
)