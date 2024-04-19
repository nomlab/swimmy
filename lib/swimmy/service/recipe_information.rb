require "json"
require "uri"
require 'open-uri'

module Swimmy
  module Service
    class RecipeInfomation

      class HttpException < StandardError; end

      def initialize(api_id)
        @api_id = api_id
      end

      def get_recipeinfo(food)
        begin
          category_id_hash = CookCategory.new(@api_id).get_category_id_hash
        rescue
          raise HttpException.new
        end

        begin
          recipe_ranking = get_recipe_ranking(food, category_id_hash)
          return nil if recipe_ranking.nil?
        rescue
          raise HttpException.new
        end

        top_ranking = recipe_ranking["result"][0]
        title = top_ranking["recipeTitle"]
        description = top_ranking["recipeDescription"]
        url = top_ranking["recipeUrl"]

        recipe_info = Resource::CookResource.new(title, description, url)

        return recipe_info
      end

      private
      def get_recipe_ranking(food, category_id_hash)
        recipe_candidates = category_id_hash.find_all{|key, value| key.include?(food)}
        return nil if recipe_candidates.empty?
        random_recipe_id = recipe_candidates.sample[1]
        # assigns the Id of a random category among the categories matching the argument

        begin 
          ranking_url = "https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&categoryId=#{random_recipe_id}&applicationId=" + @api_id
          # API仕様 : https://webservice.rakuten.co.jp/documentation/recipe-category-ranking
          recipe_ranking = JSON.parse(URI.open(ranking_url, &:read))
        rescue => e
          p e
          raise HttpException.new
        end

        return recipe_ranking
      end
    end

    class CookCategory

      # 楽天カテゴリランキングAPIから得られるJSONを変換したRubyオブジェクトは例えば以下のようになっている

      # {"result"=>
      #   {"large"=>
      #     [{"categoryId"=>"10",
      #       "categoryName"=>"肉",
      #       ...
      #     ],
      #    "medium"=>
      #     [{"categoryId"=>275,
      #       "categoryName"=>"牛肉",
      #       "parentCategoryId"=>"10"},
      #      {"categoryId"=>67,
      #       "categoryName"=>"ハム",
      #       "parentCategoryId"=>"10"},
      #       ...
      #     ],
      #    "small"=>
      #     [{"categoryId"=>516,
      #       "categoryName"=>"牛肉薄切り",
      #       "parentCategoryId"=>"275"},
      #      {"categoryId"=>1491,
      #       "categoryName"=>"生ハム",
      #       "parentCategoryId"=>"67"},
      #       ...
      #     ]
      #   }
      # }

      # 楽天のAPIを用いてレシピのランキングを得るためにはカテゴリの ID が必要になる．
      # categoryName と，それに対応する categoryID を取り出してハッシュを作成する．
      # 上記のような例に対しては，以下のようなハッシュが作成される．
      # {"肉"=>"10",
      #  "牛肉"=>"10-275",
      #  "ハム"=>"10-67",
      #  "牛肉薄切り"=>"10-275-516",
      #  "生ハム"=>"10-67-1491",
      #  ...
      # }
      # 例えば生ハムというカテゴリのIDは"10-67-1491"となる．
      # parentCategoryId を基に親カテゴリを探索し，その親カテゴリの categoryId を取得する．
      # さらに親の親のカテゴリがある場合は，親カテゴリの parentCategoryId を基に更に親の親のカテゴリの categoryId を取得する．

      def initialize(api_id)
        @api_id = api_id
      end

      def get_category_id_hash
        begin
          category_url = "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&applicationId=" + @api_id
          # API仕様 : https://webservice.rakuten.co.jp/documentation/recipe-category-list
          result = JSON.parse(URI.open(category_url, &:read))
        rescue => e
          p e
          raise HttpException.new
        end

        category_id_hash = {}

        ["large","medium","small"].each do |s|
          result["result"][s].each do |entry|
            category_id_hash[entry["categoryName"]] = get_my_id(result, entry, s)
          end
        end

        return category_id_hash
      end

      def get_my_id(result, entry, categorytype)
        return get_parent_id(result, entry, categorytype) + entry["categoryId"].to_s
      end

      def get_parent_id(result, entry, categorytype)
        return "" if categorytype == "large"

        parent_categorytype = if categorytype == "small"
          "medium"
        else
          "large"
        end

        result["result"][parent_categorytype].each do |parent_entry|
          return get_parent_id(result, parent_entry, parent_categorytype) + parent_entry["categoryId"].to_s + "-" if parent_entry["categoryId"].to_s == entry["parentCategoryId"]
        end

      end

    end
  end
end
