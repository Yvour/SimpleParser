# Written by I. Urvanov in the name of Sir Walter Scott

class SimpleParserController < ApplicationController
  # level information
  def index

  end

  def search
    param_str = params[:params];
    param_obj = JSON.parse(param_str);

    res = case param_obj['mode'];

      when 'get_brands'
        then get_object_list(get_level_config, [{}])
      when 'get_models_by_brand'
        then get_object_list(get_level_config ,[{'name'=> param_obj['brand']}, {}])
      when 'get_model_info'
        then get_model_info(param_obj['brand'], param_obj['model'])
      when 'search_by_query'
        then get_object_list_by_query(param_obj['query'])
        
    else
    {}
    end
    
    render :json=>res;
  end

  require 'open-uri'
  require 'nokogiri';

  private

  def get_object_list_by_query(query)

    query = query.to_s.downcase;
    words = query.split(/\s+/);
    brands = get_object_list(get_level_config, [{}]);

    matched_brands = brands.find_all{|brand| words.include?(brand['name'].downcase)};
    matched_brands = brands if matched_brands.empty?
    matched_models_total = [];
    brand_match_total = [];
    matched_brands.map do |brand|

      brand_models = get_object_list(get_level_config, [{'name'=>brand['name']}, {}])
      brand_models.map!{|x| x['brand'] = brand['name'];x['words'] = 0; x;}
      brand_match_total += brand_models
      matched_models = brand_models.map{|model| model['words'] = (words & model['name'].downcase.split(/\s+/)).size; model}.find_all{|model| model['words'] > 0};
       matched_models.map{|x| x['brand'] = brand['name']}
      matched_models_total += matched_models;
    end
    matched_models_total.sort_by{|model| -model['words']} + brand_match_total;
  end


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

      ],
      :object_info=>{
        :container => '#specs-list > table',
        :group_name=> './/th',
        :param_name=> './/td[@class="ttl"]',
        :param_value=>'.//td[@class="nfo"]'
       } 
    }
    return level_config
  end

  def get_model_info(brand, model )

    info = get_object_list(get_level_config, [{'name'=>brand}, {'name'=>'model'}])
    model_params = {};
    add_path = info[0]['path']
      doc = Nokogiri::HTML(open(get_level_config[:main_path]+add_path));
      doc.css(get_level_config[:object_info][:container]).each do |list_obj|

        param_group = list_obj.xpath(get_level_config[:object_info][:group_name]).inner_html.to_s;
        model_params[param_group] = [];
 
        list_obj.xpath('.//tr').each do |add_list_obj|
     
           param_name  = add_list_obj.xpath(get_level_config[:object_info][:param_name]).inner_text.to_s;
           param_value = add_list_obj.xpath(get_level_config[:object_info][:param_value]).inner_text.to_s;
           model_params[param_group].push({'name'=>param_name, 'value'=>param_value})
       
        end

      end  

     return {'brand'=>brand, 'model'=>model, 'model_params'=>model_params}
  end
  
  

  def get_object_list(level_config, the_way)
  
    add_path = ''
    prev_object_list = [];
    

    for i in 0..(the_way.length-1) do

      if the_way[i]['name'] == '' 
        return [];
      end
      object_list = [];
      if i == 0
        if session[:brands]
          object_list = session[:brands].clone;
        end
      end
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
      if (i == 0)&&(!session[:brands])
        session[:brands] = object_list.clone;
      end

    end #of for



    return object_list.sort_by{|x| x['name'].downcase}.uniq
  end #of function


end
