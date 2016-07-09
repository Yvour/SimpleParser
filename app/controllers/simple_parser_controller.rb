class SimpleParserController < ApplicationController
  # level information
  def index

  end

  def search
    param_str = params[:params];
    param_obj = JSON.parse(param_str);
 #   get_model_info('Acer', 'Liquid X2')
    puts 'i am here'
    res = case param_obj['mode'];

      when 'get_brands'
        then get_object_list(get_level_config, [{}])
      when 'get_models_by_brand'
        then get_object_list(get_level_config ,[{'name'=> param_obj['brand']}, {}])
      when 'get_model_info'
        then get_model_info(param_obj['brand'], param_obj['model'])
    else
    {}
    end
    
    render :json=>res;
  end

  require 'open-uri'
  require 'nokogiri';

  private

  def get_level_config
    level_config = {:main_path => 'http://www.gsmarena.com/',
      :levels => [
        { :level_name => 'brand',
          :container=>'.brandmenu-v2 > ul > li > a',
          :object_name => '.',
          :object_link => '@href'},
        {
          :level_name => 'model',
          :container =>'.makers > ul> li > a',
          :object_name => './/strong//span',
          :object_link => '@href'
        }

      ]
    }
    return level_config
  end

  def get_model_info(brand, model )
    puts 'get_model_info starts'
    info = get_object_list(get_level_config, [{'name'=>brand}, {'name'=>'model'}])
    model_params = {};
    add_path = info[0]['path']
      doc = Nokogiri::HTML(open(get_level_config[:main_path]+add_path));
      doc.css('#specs-list > table').each do |list_obj|

        param_group = list_obj.xpath('.//th').inner_html.to_s;
        model_params[param_group] = [];
    #    param_name  = list_obj.xpath('.//td[@class="tt//a').inner_text.to_s;
     #   param_value = list_obj.xpath('.//td[@class="nfo"]').inner_text.to_s;
      #  model_params[param_group].push({'name'=>param_name, 'value'=>param_value})
        list_obj.xpath('.//tr').each do |add_list_obj|
          puts 'Sir Walter Scott'
           param_name  = add_list_obj.xpath('.//td[@class="ttl"]').inner_text.to_s;
           param_value = add_list_obj.xpath('.//td[@class="nfo"]').inner_text.to_s;
           model_params[param_group].push({'name'=>param_name, 'value'=>param_value})
       
        end

      end  
     puts 'get_model_info ends with ' + model_params.to_s
     return {'brand'=>brand, 'model'=>model, 'model_params'=>model_params}
  end
  
  

  def get_object_list(level_config, the_way)
    puts 'get_object_list starts with ' + the_way.to_s
    add_path = ''
    prev_object_list = [];

    for i in 0..(the_way.length-1) do
      puts 'the i is ' + i.to_s
      if the_way[i]['name'] == '' 
        return [];
      end
      object_list = [];
      if i > 0
        obj =  prev_object_list.find_all{|x| x['name'] == the_way[i-1]['name']};
        add_path = obj[0]['path']
      end
      doc = Nokogiri::HTML(open(level_config[:main_path]+add_path));
      doc.css(level_config[:levels][i][:container]).each do |list_obj|
        object_obj = {}
        object_obj['name'] = list_obj.xpath(level_config[:levels][i][:object_name]).inner_html.to_s;
        object_obj['path'] = list_obj.xpath('@href').to_s;
        object_list.push(object_obj);
      end
      prev_object_list = object_list.clone;
    end #of for

    puts 'get_object_list ends with ' + object_list.to_s
    return object_list
  end #of function


end
